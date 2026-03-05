#!/usr/bin/env bash
set -euo pipefail

iters="${1:-20}"
reg="${2:-.dots/bench-reg}"

scripts/fake_registry.sh init "$reg" >/dev/null
scripts/fake_registry.sh add-pkg "$reg" demo 1.0.0 >/dev/null

sum=0
min=0
max=0
for _ in $(seq 1 "$iters"); do
  s=$(date +%s%N)
  DOTS_REGISTRY_MODE=fake DOTS_REGISTRY_DIR="$reg" dots install --json demo >/dev/null 2>&1 || true
  e=$(date +%s%N)
  d=$((e-s))
  sum=$((sum+d))
  [[ "$min" -eq 0 || "$d" -lt "$min" ]] && min="$d"
  [[ "$d" -gt "$max" ]] && max="$d"
done

avg_ns=$((sum/iters))
avg_ms=$(awk -v n="$avg_ns" 'BEGIN{printf "%.3f", n/1000000}')
min_ms=$(awk -v n="$min" 'BEGIN{printf "%.3f", n/1000000}')
max_ms=$(awk -v n="$max" 'BEGIN{printf "%.3f", n/1000000}')

echo "fake_registry_install_avg_ms=$avg_ms"
echo "fake_registry_install_min_ms=$min_ms"
echo "fake_registry_install_max_ms=$max_ms"
