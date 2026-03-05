#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RESULTS_DIR="${ROOT_DIR}/bench/results"
ARCHIVE_DIR="${RESULTS_DIR}/archive"
mkdir -p "${RESULTS_DIR}" "${ARCHIVE_DIR}"

BENCHES=(json interpreter http concurrency)

usage() {
  cat <<'USAGE'
Usage:
  scripts/bench.sh list-bench
  scripts/bench.sh list-scenarios <bench>
  scripts/bench.sh run <bench>
  scripts/bench.sh run-all
  scripts/bench.sh compare <bench>
  scripts/bench.sh dashboard

Environment overrides:
  DOTS_BENCH_MODE=smoke|quick|stress|nightly
  DOTS_BENCH_RUNS=<int>=7
  DOTS_BENCH_WARMUP=<int>=2
  DOTS_BENCH_SEED=<int>=424242
  DOTS_BENCH_OUTPUT=json|human|both (default both)
  DOTS_BENCH_FAIL_ON_REGRESSION=true|false (default true)
  DOTS_BENCH_BASELINE_FILE=bench/baseline.json
  DOTS_BENCH_TAG=<string>
  DOTS_BENCH_NOTES=<string>
  DOTS_BENCH_TIMEOUT_MS=<int>=30000
  DOTS_BENCH_COOLDOWN_MS=<int>=100
  DOTS_BENCH_PARALLEL=<int>=2
  DOTS_BENCH_DRY_RUN=true|false
  DOTS_BENCH_CPU_AFFINITY=<cpu-list>  # taskset, if available
  DOTS_BENCH_MACHINE_PROFILE=<profile> # baseline profile override
  DOTS_HTTP_URL=http://127.0.0.1:8080
USAGE
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "missing command: $1" >&2; exit 2; }
}

norm_bool() {
  case "${1:-}" in
    1|true|TRUE|yes|YES|on|ON) echo true ;;
    0|false|FALSE|no|NO|off|OFF|"") echo false ;;
    *) echo "invalid bool: $1" >&2; exit 2 ;;
  esac
}

norm_int() {
  local v="${1:-}"
  [[ "$v" =~ ^[0-9]+$ ]] || { echo "invalid int: $v" >&2; exit 2; }
  echo "$v"
}

validate_url() {
  local url="$1"
  [[ "$url" =~ ^https?://[^/:]+:[0-9]+$ ]] || {
    echo "invalid URL (expected http[s]://host:port): $url" >&2
    exit 2
  }
}

contains_bench() {
  local target="$1"
  local b
  for b in "${BENCHES[@]}"; do
    [[ "$b" == "$target" ]] && return 0
  done
  return 1
}

list_bench() {
  printf '%s\n' "${BENCHES[@]}"
}

list_scenarios() {
  local bench="$1"
  case "$bench" in
    json) printf '%s\n' parse stringify mix large_payload deeply_nested ;;
    interpreter) printf '%s\n' rand_add_accumulate arithmetic branch_heavy function_call_heavy allocation_heavy ;;
    http) printf '%s\n' get_keepalive_rate_limited keepalive_a_b with_payload mixed_status_codes ;;
    concurrency) printf '%s\n' spsc mpsc spmc mpmc burst steady asym_heavy_producer asym_heavy_consumer ;;
    *) echo "unknown bench: $bench" >&2; exit 2 ;;
  esac
}

load_env() {
  DOTS_BENCH_MODE="${DOTS_BENCH_MODE:-quick}"
  DOTS_BENCH_RUNS="${DOTS_BENCH_RUNS:-7}"
  DOTS_BENCH_WARMUP="${DOTS_BENCH_WARMUP:-2}"
  DOTS_BENCH_SEED="${DOTS_BENCH_SEED:-424242}"
  DOTS_BENCH_OUTPUT="${DOTS_BENCH_OUTPUT:-both}"
  DOTS_BENCH_FAIL_ON_REGRESSION="$(norm_bool "${DOTS_BENCH_FAIL_ON_REGRESSION:-true}")"
  DOTS_BENCH_BASELINE_FILE="${DOTS_BENCH_BASELINE_FILE:-${ROOT_DIR}/bench/baseline.json}"
  DOTS_BENCH_TAG="${DOTS_BENCH_TAG:-local}"
  DOTS_BENCH_NOTES="${DOTS_BENCH_NOTES:-}"
  DOTS_BENCH_TIMEOUT_MS="${DOTS_BENCH_TIMEOUT_MS:-30000}"
  DOTS_BENCH_COOLDOWN_MS="${DOTS_BENCH_COOLDOWN_MS:-100}"
  DOTS_BENCH_PARALLEL="${DOTS_BENCH_PARALLEL:-2}"
  DOTS_BENCH_DRY_RUN="$(norm_bool "${DOTS_BENCH_DRY_RUN:-false}")"
  DOTS_BENCH_CPU_AFFINITY="${DOTS_BENCH_CPU_AFFINITY:-}"
  DOTS_BENCH_MACHINE_PROFILE="${DOTS_BENCH_MACHINE_PROFILE:-}"
  DOTS_HTTP_URL="${DOTS_HTTP_URL:-}"

  DOTS_BENCH_RUNS="$(norm_int "$DOTS_BENCH_RUNS")"
  DOTS_BENCH_WARMUP="$(norm_int "$DOTS_BENCH_WARMUP")"
  DOTS_BENCH_SEED="$(norm_int "$DOTS_BENCH_SEED")"
  DOTS_BENCH_TIMEOUT_MS="$(norm_int "$DOTS_BENCH_TIMEOUT_MS")"
  DOTS_BENCH_COOLDOWN_MS="$(norm_int "$DOTS_BENCH_COOLDOWN_MS")"
  DOTS_BENCH_PARALLEL="$(norm_int "$DOTS_BENCH_PARALLEL")"

  [[ "$DOTS_BENCH_RUNS" -ge 3 ]] || { echo "DOTS_BENCH_RUNS must be >= 3" >&2; exit 2; }
  [[ "$DOTS_BENCH_WARMUP" -ge 1 ]] || { echo "DOTS_BENCH_WARMUP must be >= 1" >&2; exit 2; }

  case "$DOTS_BENCH_MODE" in
    smoke) DOTS_BENCH_RUNS=3; DOTS_BENCH_WARMUP=1 ;;
    quick) : ;;
    stress) DOTS_BENCH_RUNS="${DOTS_BENCH_RUNS}" ;;
    nightly) DOTS_BENCH_RUNS=15; DOTS_BENCH_WARMUP=5 ;;
    *) echo "invalid DOTS_BENCH_MODE: $DOTS_BENCH_MODE" >&2; exit 2 ;;
  esac

  case "$DOTS_BENCH_OUTPUT" in
    json|human|both) : ;;
    *) echo "invalid DOTS_BENCH_OUTPUT: $DOTS_BENCH_OUTPUT" >&2; exit 2 ;;
  esac
  if [[ -n "$DOTS_HTTP_URL" ]]; then
    validate_url "$DOTS_HTTP_URL"
  fi

  export DOTS_BENCH_MODE DOTS_BENCH_RUNS DOTS_BENCH_WARMUP DOTS_BENCH_SEED DOTS_BENCH_OUTPUT
  export DOTS_BENCH_FAIL_ON_REGRESSION DOTS_BENCH_BASELINE_FILE DOTS_BENCH_TAG DOTS_BENCH_NOTES
  export DOTS_BENCH_TIMEOUT_MS DOTS_BENCH_COOLDOWN_MS DOTS_BENCH_CPU_AFFINITY DOTS_BENCH_MACHINE_PROFILE
  export DOTS_HTTP_URL
}

rotate_results() {
  local ts
  ts="$(date +%Y%m%d-%H%M%S)"
  shopt -s nullglob
  local f
  for f in "${RESULTS_DIR}"/*.jsonl; do
    gzip -c "$f" >"${ARCHIVE_DIR}/$(basename "$f").${ts}.gz"
    : >"$f"
  done
  shopt -u nullglob
}

extract_json_line() {
  awk '/^\{.*\}$/{line=$0} END{if(line) print line; else exit 1}'
}

json_get_num() {
  local json="$1" key="$2"
  echo "$json" | sed -nE "s/.*\"${key}\":([0-9]+(\.[0-9]+)?).*/\1/p" | head -n1
}

json_get_str() {
  local json="$1" key="$2"
  echo "$json" | sed -nE "s/.*\"${key}\":\"([^\"]*)\".*/\1/p" | head -n1
}

machine_fingerprint() {
  local host kernel cpu
  host="$(hostname 2>/dev/null || echo unknown)"
  kernel="$(uname -sr 2>/dev/null || echo unknown)"
  cpu="$(uname -m 2>/dev/null || echo unknown)"
  printf '%s|%s|%s' "$host" "$kernel" "$cpu" | sha256sum | awk '{print $1}'
}

append_csv() {
  local bench="$1" json="$2"
  local csv="${RESULTS_DIR}/${bench}.csv"
  if [[ ! -f "$csv" ]]; then
    echo "timestamp,run_id,bench,mode,tag,avg_ms,p50_ms,p90_ms,p95_ms,p99_ms,min_ms,max_ms,stddev_ms,cv_pct,ops_per_s,req_per_s,msg_per_s,status" >"$csv"
  fi
  local ts run_id mode tag avg p50 p90 p95 p99 min max stddev cv ops req msg status
  ts="$(json_get_str "$json" timestamp)"
  run_id="$(json_get_str "$json" run_id)"
  mode="$(json_get_str "$json" mode)"
  tag="$(json_get_str "$json" tag)"
  avg="$(json_get_num "$json" avg_ms)"
  p50="$(json_get_num "$json" p50_ms)"
  p90="$(json_get_num "$json" p90_ms)"
  p95="$(json_get_num "$json" p95_ms)"
  p99="$(json_get_num "$json" p99_ms)"
  min="$(json_get_num "$json" min_ms)"
  max="$(json_get_num "$json" max_ms)"
  stddev="$(json_get_num "$json" stddev_ms)"
  cv="$(json_get_num "$json" cv_pct)"
  ops="$(json_get_num "$json" ops_per_s)"
  req="$(json_get_num "$json" req_per_s)"
  msg="$(json_get_num "$json" msg_per_s)"
  status="$(json_get_str "$json" status)"
  echo "${ts},${run_id},${bench},${mode},${tag},${avg},${p50},${p90},${p95},${p99},${min},${max},${stddev},${cv},${ops},${req},${msg},${status}" >>"$csv"
}

append_prom() {
  local bench="$1" json="$2"
  local f="${RESULTS_DIR}/${bench}.prom"
  local avg p95 status
  avg="$(json_get_num "$json" avg_ms)"
  p95="$(json_get_num "$json" p95_ms)"
  status="$(json_get_str "$json" status)"
  cat >"$f" <<PROM
# TYPE dots_bench_avg_ms gauge
dots_bench_avg_ms{bench="${bench}"} ${avg:-0}
# TYPE dots_bench_p95_ms gauge
dots_bench_p95_ms{bench="${bench}"} ${p95:-0}
# TYPE dots_bench_status gauge
dots_bench_status{bench="${bench}"} $([[ "$status" == "ok" ]] && echo 1 || echo 0)
PROM
}

compare_with_last() {
  local bench="$1" current_json="$2"
  local f="${RESULTS_DIR}/${bench}.jsonl"
  [[ -s "$f" ]] || return 0
  local last_json current_val last_val
  last_json="$(tail -n1 "$f")"
  current_val="$(json_get_num "$current_json" ops_per_s)"
  [[ -n "$current_val" ]] || current_val="$(json_get_num "$current_json" req_per_s)"
  [[ -n "$current_val" ]] || current_val="$(json_get_num "$current_json" msg_per_s)"
  last_val="$(json_get_num "$last_json" ops_per_s)"
  [[ -n "$last_val" ]] || last_val="$(json_get_num "$last_json" req_per_s)"
  [[ -n "$last_val" ]] || last_val="$(json_get_num "$last_json" msg_per_s)"
  if [[ -n "$current_val" && -n "$last_val" ]]; then
    awk -v c="$current_val" -v l="$last_val" 'BEGIN{d=((c-l)/l)*100; printf "compare_last_delta_pct=%.2f\n", d}'
  fi
}

compare_with_baseline() {
  local bench="$1" current_json="$2"
  local baseline_file="$DOTS_BENCH_BASELINE_FILE"
  [[ -f "$baseline_file" ]] || return 0
  local key current_val base_val profile threshold
  profile="$DOTS_BENCH_MODE"
  [[ -n "${DOTS_BENCH_MACHINE_PROFILE:-}" ]] && profile="$DOTS_BENCH_MACHINE_PROFILE"
  [[ "$profile" == "stress" ]] && profile="default"
  [[ "$profile" == "smoke" ]] && profile="quick"
  case "$bench" in
    json|interpreter) key="ops_per_s" ;;
    http) key="req_per_s" ;;
    concurrency) key="msg_per_s" ;;
    *) return 0 ;;
  esac
  current_val="$(json_get_num "$current_json" "$key")"
  base_val="$(
    awk -v p="\"${profile}\"" -v b="\"${bench}\"" -v k="\"${key}\"" '
      $0 ~ p {in_profile=1}
      in_profile && $0 ~ b {in_bench=1}
      in_profile && in_bench && $0 ~ k {
        gsub(/[^0-9.]/,"",$0); print $0; exit
      }
      in_profile && in_bench && $0 ~ /^\s*}/ {in_bench=0}
    ' "$baseline_file"
  )"
  threshold="$(
    awk -v p="\"${profile}\"" -v b="\"${bench}\"" '
      $0 ~ p {in_profile=1}
      in_profile && $0 ~ b {in_bench=1}
      in_profile && in_bench && $0 ~ /"threshold_pct"/ {
        gsub(/[^0-9.]/,"",$0); print $0; exit
      }
      in_profile && in_bench && $0 ~ /^\s*}/ {in_bench=0}
    ' "$baseline_file"
  )"
  if [[ -n "$current_val" && -n "$base_val" ]]; then
    awk -v c="$current_val" -v b="$base_val" -v t="${threshold:-15}" '
      BEGIN{
        d=((c-b)/b)*100;
        a=(d<0?-d:d);
        printf "compare_baseline_delta_pct=%.2f\n", d;
        printf "compare_baseline_threshold_pct=%.2f\n", t;
        if (a>t) print "compare_baseline_budget=failed"; else print "compare_baseline_budget=ok";
      }'
  fi
}

run_one() {
  local bench="$1"
  contains_bench "$bench" || { echo "unknown bench: $bench" >&2; exit 2; }
  require_cmd dots

  local bench_file="${ROOT_DIR}/bench/${bench}_bench.dotS"
  [[ -f "$bench_file" ]] || { echo "missing file: $bench_file" >&2; exit 2; }

  local ts run_id machine_id cmd output json_line status
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  run_id="$(date +%s)-$RANDOM"
  machine_id="$(machine_fingerprint)"

  export DOTS_BENCH_TAG DOTS_BENCH_NOTES DOTS_BENCH_MACHINE_ID="$machine_id"
  export DOTS_BENCH_RUN_ID="$run_id" DOTS_BENCH_TIMESTAMP="$ts"

  cmd=(dots run "$bench_file")
  if [[ -n "$DOTS_BENCH_CPU_AFFINITY" ]] && command -v taskset >/dev/null 2>&1; then
    cmd=(taskset -c "$DOTS_BENCH_CPU_AFFINITY" "${cmd[@]}")
  fi

  if [[ "$DOTS_BENCH_DRY_RUN" == true ]]; then
    echo "dry-run config:"
    env | grep '^DOTS_BENCH_' | sort
    printf 'command: '; printf '%q ' "${cmd[@]}"; echo
    return 0
  fi

  output="$("${cmd[@]}")"

  if [[ "$DOTS_BENCH_OUTPUT" == "human" || "$DOTS_BENCH_OUTPUT" == "both" ]]; then
    echo "$output"
  fi

  json_line="$(echo "$output" | extract_json_line || true)"
  if [[ -z "$json_line" ]]; then
    echo "no JSON line found in bench output" >&2
    exit 2
  fi

  json_line="$(echo "$json_line" | sed -E "s/\}\$/,\"tag\":\"${DOTS_BENCH_TAG}\",\"notes\":\"${DOTS_BENCH_NOTES//\"/}\",\"machine_id\":\"${machine_id}\"}/")"

  if [[ "$DOTS_BENCH_OUTPUT" == "json" || "$DOTS_BENCH_OUTPUT" == "both" ]]; then
    echo "$json_line"
  fi

  echo "$json_line" >>"${RESULTS_DIR}/${bench}.jsonl"
  append_csv "$bench" "$json_line"
  append_prom "$bench" "$json_line"

  compare_with_last "$bench" "$json_line"
  compare_with_baseline "$bench" "$json_line"

  status="$(json_get_str "$json_line" status)"
  if [[ "$DOTS_BENCH_FAIL_ON_REGRESSION" == true && "$status" == regression ]]; then
    echo "regression detected" >&2
    exit 3
  fi

  sleep "$(awk -v ms="$DOTS_BENCH_COOLDOWN_MS" 'BEGIN{printf "%.3f", ms/1000}')"
}

run_all() {
  local pids=()
  local b
  for b in "${BENCHES[@]}"; do
    (
      run_one "$b"
    ) &
    pids+=("$!")
    while [[ "$(jobs -rp | wc -l)" -ge "$DOTS_BENCH_PARALLEL" ]]; do
      sleep 0.1
    done
  done
  local rc=0 pid
  for pid in "${pids[@]}"; do
    wait "$pid" || rc=$?
  done
  return "$rc"
}

compare_cmd() {
  local bench="$1"
  local f="${RESULTS_DIR}/${bench}.jsonl"
  [[ -s "$f" ]] || { echo "no results for $bench" >&2; exit 2; }
  local current
  current="$(tail -n1 "$f")"
  compare_with_last "$bench" "$current"
  compare_with_baseline "$bench" "$current"
}

dashboard_cmd() {
  local md="${RESULTS_DIR}/dashboard.md"
  {
    echo "# Bench Dashboard"
    echo
    echo "Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo
    echo "| bench | last status | avg_ms | p95_ms | throughput |"
    echo "|---|---:|---:|---:|---:|"
    local b f j status avg p95 t
    for b in "${BENCHES[@]}"; do
      f="${RESULTS_DIR}/${b}.jsonl"
      if [[ -s "$f" ]]; then
        j="$(tail -n1 "$f")"
        status="$(json_get_str "$j" status)"
        avg="$(json_get_num "$j" avg_ms)"
        p95="$(json_get_num "$j" p95_ms)"
        t="$(json_get_num "$j" ops_per_s)"
        [[ -n "$t" ]] || t="$(json_get_num "$j" req_per_s)"
        [[ -n "$t" ]] || t="$(json_get_num "$j" msg_per_s)"
        echo "| $b | ${status:-na} | ${avg:-na} | ${p95:-na} | ${t:-na} |"
      else
        echo "| $b | na | na | na | na |"
      fi
    done
  } >"$md"
  echo "$md"
}

main() {
  local cmd="${1:-}"
  [[ -n "$cmd" ]] || { usage; exit 1; }
  load_env

  case "$cmd" in
    list-bench) list_bench ;;
    list-scenarios) shift; list_scenarios "${1:-}" ;;
    run) shift; run_one "${1:-}" ;;
    run-all) run_all ;;
    compare) shift; compare_cmd "${1:-}" ;;
    rotate) rotate_results ;;
    dashboard) dashboard_cmd ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
