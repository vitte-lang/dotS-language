#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  echo "usage: scripts/migrate_bench.sh <input.dotS> <output.dotS>"
}

in="${1:-}"
out="${2:-}"
[[ -n "$in" && -n "$out" ]] || { usage; exit 1; }
[[ -f "$in" ]] || { echo "missing input: $in" >&2; exit 2; }

cp "$ROOT_DIR/bench/_template.dotS" "$out"
bench_name="$(basename "$out" | sed -E 's/_bench\.dotS$//')"
sed -i "s/template/${bench_name}/g" "$out"

echo "migrated template written to $out"
