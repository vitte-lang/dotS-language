#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$ROOT/lsp/server.vit"

COUNT=$(grep -n "io.print(" "$SERVER" | wc -l | tr -d ' ')
if [[ "$COUNT" -gt 1 ]]; then
  echo "lsp stdout gate failed: unexpected io.print usage in lsp/server.vit"
  grep -n "io.print(" "$SERVER"
  exit 1
fi

echo "lsp stdout gate ok"
