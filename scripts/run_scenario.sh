#!/usr/bin/env bash
set -euo pipefail

scenario_file="${1:-}"
bench="${2:-}"
[[ -f "$scenario_file" ]] || { echo "missing scenario file" >&2; exit 2; }
[[ -n "$bench" ]] || { echo "usage: scripts/run_scenario.sh <scenario.env> <bench>" >&2; exit 1; }

set -a
# shellcheck disable=SC1090
source "$scenario_file"
set +a

bash scripts/bench.sh run "$bench"
