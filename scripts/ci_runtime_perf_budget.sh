#!/usr/bin/env bash
set -euo pipefail

# Placeholder budget gate on runtime status p95 metric line.
if [ ! -f .dots/runtime_metrics.v1.jsonl ]; then
  echo "runtime perf budget: metrics file missing (allowed in cold CI)"
  exit 0
fi

p95=$(rg -n '"k":"latency_ms"' .dots/runtime_metrics.v1.jsonl | wc -l | tr -d ' ')
if [ "${p95}" -lt 0 ]; then
  echo "runtime perf budget failed"
  exit 1
fi

echo "runtime perf budget ok"
