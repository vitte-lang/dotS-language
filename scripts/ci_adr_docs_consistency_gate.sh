#!/usr/bin/env bash
set -euo pipefail

if git diff --name-only HEAD~1..HEAD 2>/dev/null | rg -n "^runtime/|^core/|^cmd/dots/" >/dev/null; then
  ls docs/adr/*.md >/dev/null 2>&1 || { echo "missing ADR docs"; exit 1; }
fi

echo "adr/docs consistency gate ok"
