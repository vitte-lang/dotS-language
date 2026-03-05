#!/usr/bin/env bash
set -euo pipefail

test -d tests/snapshots || { echo "missing tests/snapshots"; exit 1; }
rg -n "schema_version" tests/snapshots/**/*.json >/dev/null || { echo "missing schema_version in json snapshots"; exit 1; }

echo "snapshot freshness gate ok"
