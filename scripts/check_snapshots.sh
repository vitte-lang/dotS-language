#!/usr/bin/env bash
set -euo pipefail

SNAPSHOT="tests/snapshots/bench_output.snapshot.jsonl"
[[ -f "$SNAPSHOT" ]] || { echo "missing snapshot file" >&2; exit 2; }

grep -q '"bench"' "$SNAPSHOT" || { echo "snapshot missing bench key" >&2; exit 2; }
grep -q '"status"' "$SNAPSHOT" || { echo "snapshot missing status key" >&2; exit 2; }

echo "snapshot checks passed"
