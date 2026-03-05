#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$ROOT/lsp/server.vit"

grep -q "DOTS_LSP_TTFO_BUDGET_MS" "$SERVER"
grep -q "ttfo_budget_exceeded" "$SERVER"

echo "lsp ttfo gate ok"
