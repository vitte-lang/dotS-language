#!/usr/bin/env bash
set -euo pipefail

test -f runtime/status.vit
rg -n "runtime_status_json|runtime_status_prom|runtime_status_table" runtime/status.vit >/dev/null
rg -n "schema_version" tests/snapshots/runtime/status.json >/dev/null

echo "runtime status contract gate ok"
