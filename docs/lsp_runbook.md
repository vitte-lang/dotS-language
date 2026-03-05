# LSP Runbook

## Launch

```bash
dots lsp --stdio
```

Fallback:

```bash
dots run lsp/server.vit --stdio
```

## Supported Methods

- `initialize`, `initialized`, `shutdown`, `exit`
- `$/cancelRequest`
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
- `workspace/symbol`
- `textDocument/codeAction`
- `textDocument/codeLens`
- `textDocument/signatureHelp`
- `workspace/applyEdit`
- `workspace/didChangeWatchedFiles`
- `workspace/configuration`
- `workspace/workspaceFolders`

## Diagnostics

- Incremental diagnostics with debounce (`DOTS_LSP_DEBOUNCE_MS`)
- Max diagnostics per file (`DOTS_LSP_MAX_DIAGNOSTICS`, default 200)
- Stable diagnostic codes: `DOTS001+`

## Logs

- `.dots/logs/lsp.log`
- Structured events: timestamp, method, duration, request_id, status.

## Doctor

```bash
dots doctor --lsp
```

## Stats

```bash
dots lsp stats --json
dots lsp stats --prom
```

## Benchmarks

```bash
dots benchmark --bench lsp_open_file
dots benchmark --bench lsp_completion
dots benchmark --bench lsp_diagnostics
dots benchmark --bench lsp_rename_workspace
```

## Client Notes

- Use stdio transport.
- Ensure no non-protocol text is printed on stdout.
- In case of failures, inspect `.dots/logs/lsp.log`.

## Editor Examples

Vim (`coc.nvim`/LSP client):

```json
{
  "command": "dots",
  "args": ["lsp", "--stdio"]
}
```

Emacs (`lsp-mode`):

```elisp
(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection '("dots" "lsp" "--stdio"))
                  :major-modes '(dots-mode vit-mode)
                  :server-id 'dots-lsp))
```

GeanyLSP:

- Command: `dots lsp --stdio`
- Root patterns: `.git`, `dots.json`.

Troubleshooting:

- `docs/lsp_troubleshooting.md`
- `docs/lsp_protocol_contract.md`
