#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

rg -n "jsonrpc\":\"2.0|error_response|result_response" "$ROOT/lsp/server.vit" >/dev/null
rg -n "completion_result_json|hover_result_json|definition_result_json_workspace|rename_workspace_edit_json|publish_diagnostics_notification" "$ROOT/lsp/"*.vit >/dev/null
test -f "$ROOT/docs/lsp_protocol_contract.md"

echo "lsp schema gate ok"
