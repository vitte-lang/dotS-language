#!/usr/bin/env bash
set -euo pipefail

iters="${1:-20}"
budget_ms="${2:-120}"

start_ns() { date +%s%N; }

sum=0
for _ in $(seq 1 "$iters"); do
  s=$(start_ns)
  dots help >/dev/null 2>&1 || true
  e=$(start_ns)
  d=$((e-s))
  sum=$((sum+d))
done

avg_ns=$((sum/iters))
avg_ms=$(awk -v n="$avg_ns" 'BEGIN{printf "%.3f", n/1000000}')

echo "startup_avg_ms=${avg_ms}"

cmp=$(awk -v a="$avg_ms" -v b="$budget_ms" 'BEGIN{if (a>b) print 1; else print 0}')
if [[ "$cmp" == "1" ]]; then
  echo "startup budget exceeded: avg=${avg_ms}ms budget=${budget_ms}ms" >&2
  exit 1
fi

echo "startup budget ok"
