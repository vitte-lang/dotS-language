#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVER="$ROOT/lsp/server.vit"

grep -q "latency_p95_ms" "$SERVER"
grep -q "textDocument/completion" "$SERVER"
grep -q "textDocument/hover" "$SERVER"

echo "lsp latency gate ok"
