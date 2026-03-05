#!/usr/bin/env bash
set -euo pipefail

RESULTS_DIR="bench/results"
[[ -d "$RESULTS_DIR" ]] || { echo "no results directory"; exit 2; }

rc=0
for f in "$RESULTS_DIR"/*.jsonl; do
  [[ -f "$f" ]] || continue
  last="$(tail -n1 "$f")"
  status="$(echo "$last" | sed -nE 's/.*"status":"([^"]+)".*/\1/p')"
  bench="$(basename "$f" .jsonl)"
  if [[ "$status" == "regression" ]]; then
    echo "perf budget failed: $bench status=regression"
    rc=1
  fi
  if [[ "$status" == "unstable" ]]; then
    echo "perf budget unstable: $bench"
    rc=1
  fi
done
exit "$rc"
