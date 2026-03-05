#!/usr/bin/env bash
set -euo pipefail

metrics_file=".dots/runtime_metrics.v1.jsonl"
if [ ! -f "$metrics_file" ]; then
  echo "no runtime metrics found: $metrics_file"
  exit 0
fi

echo "runtime dashboard"
echo "--------------"
echo "ops_total entries: $(rg -n '"k":"ops_total"' "$metrics_file" | wc -l | tr -d ' ')"
echo "errors_total entries: $(rg -n '"k":"errors_total"' "$metrics_file" | wc -l | tr -d ' ')"
echo "latency entries: $(rg -n '"k":"latency_ms"' "$metrics_file" | wc -l | tr -d ' ')"
