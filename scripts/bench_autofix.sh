#!/usr/bin/env bash
set -euo pipefail

# Simple textual autofixes for bench files.
for f in bench/*_bench.dotS; do
  [[ -f "$f" ]] || continue
  sed -i 's/\$duration\./\$duration_ms\./g' "$f"
  sed -i 's/\$throughput\./\$ops_per_s\./g' "$f"
done

echo "autofix pass complete"
