#!/usr/bin/env bash
set -euo pipefail

# Fast local benchmark for lexer-heavy source scanning.
# It builds a synthetic DotS file with many token types and runs `dots build --emit ast`
# multiple times, then prints avg/p95 in milliseconds.

iters="${1:-15}"
lines="${2:-50000}"
warmup="${3:-3}"

if ! command -v dots >/dev/null 2>&1; then
  echo "missing command: dots" >&2
  exit 2
fi

if ! [[ "$iters" =~ ^[0-9]+$ ]] || ! [[ "$lines" =~ ^[0-9]+$ ]] || ! [[ "$warmup" =~ ^[0-9]+$ ]]; then
  echo "usage: scripts/lexer_hotpath_bench.sh [iters:int] [lines:int] [warmup:int]" >&2
  exit 2
fi

tmp="$(mktemp /tmp/dots-lexer-bench-XXXXXX.dotS)"
trap 'rm -f "$tmp"' EXIT

{
  echo ".module.bench.lexer_hotpath."
  i=0
  while [[ "$i" -lt "$lines" ]]; do
    echo ".let.\$v${i}.0xFF."
    echo ".let.\$s${i}.\"line\\nvalue\\u0041\\x42\"."
    echo ".call.work.unit.\$v${i}.6.02e23."
    i=$((i + 1))
  done
} >"$tmp"

measure_once() {
  local s e
  s="$(date +%s%N)"
  dots build --emit ast "$tmp" >/dev/null 2>&1 || true
  e="$(date +%s%N)"
  echo $(((e - s) / 1000000))
}

for _ in $(seq 1 "$warmup"); do
  measure_once >/dev/null
done

vals=()
sum=0
for _ in $(seq 1 "$iters"); do
  ms="$(measure_once)"
  vals+=("$ms")
  sum=$((sum + ms))
done

avg=$((sum / iters))
sorted="$(printf '%s\n' "${vals[@]}" | sort -n)"
idx=$(( (95 * iters + 99) / 100 ))
if [[ "$idx" -lt 1 ]]; then idx=1; fi
p95="$(echo "$sorted" | sed -n "${idx}p")"

echo "lexer_hotpath_bench_ms_avg=${avg}"
echo "lexer_hotpath_bench_ms_p95=${p95:-0}"
echo "iters=${iters} lines=${lines} warmup=${warmup}"
