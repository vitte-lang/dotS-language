# LSP Protocol Contract (DotS)

## Transport

- JSON-RPC 2.0 over stdio.
- Framing: `Content-Length: <n>\r\n\r\n<payload>`.
- Server writes only JSON-RPC frames on stdout.

## Core Lifecycle

- `initialize`
- `initialized`
- `shutdown`
- `exit`
- `$/cancelRequest`

## Text Document Methods

- `textDocument/didOpen`
- `textDocument/didChange`
- `textDocument/didClose`
- `textDocument/didSave`
- `textDocument/completion`
- `completionItem/resolve`
- `textDocument/definition`
- `textDocument/hover`
- `textDocument/references`
- `textDocument/rename`
- `textDocument/prepareRename`
- `textDocument/formatting`
- `textDocument/rangeFormatting`
- `textDocument/semanticTokens/full`
- `textDocument/documentSymbol`
- `textDocument/codeAction`
- `textDocument/codeLens`
- `textDocument/signatureHelp`

## Workspace Methods

- `workspace/symbol`
- `workspace/applyEdit` (preview-only in server debug path)
- `workspace/didChangeWatchedFiles`
- `workspace/configuration`
- `workspace/workspaceFolders`

## Error Codes

- `-32700` Parse error
- `-32600` Invalid Request
- `-32601` Method not found
- `-32602` Invalid params
- `-32603` Internal error / cancellation / timeout

## Debug Endpoint

- `dots/debugStats` returns:
  - `requests_total`
  - `errors_total`
  - `latency_p95_ms`

## Notes

- URI normalization supports `file://` URIs and percent-decoding basics.
- Path traversal is rejected for unsafe local paths.
- TTFO budget env: `DOTS_LSP_TTFO_BUDGET_MS` (default 100ms).
