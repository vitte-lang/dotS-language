#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

RUNS="${1:-15}"
BUDGET_MS="${2:-120}"
vals=()

for _ in $(seq 1 "$RUNS"); do
  s=$(date +%s%3N)
  DOTS_REGISTRY_MODE=fake dots registry doctor --json >/dev/null 2>&1 || true
  e=$(date +%s%3N)
  vals+=($((e - s)))
done

IFS=$'\n' sorted=($(sort -n <<<"${vals[*]}"))
unset IFS
idx=$(( (${#sorted[@]} * 95) / 100 ))
if (( idx >= ${#sorted[@]} )); then idx=$((${#sorted[@]}-1)); fi
p95="${sorted[$idx]}"
echo "state_bootstrap/jsonl_get p95=${p95}ms budget=${BUDGET_MS}ms"
if (( p95 > BUDGET_MS )); then
  echo "state perf budget failed"
  exit 1
fi
echo "state perf budget ok"
