# LSP Troubleshooting

## Symptoms

1. No completion/hover in editor.
2. “Method not found” responses.
3. Broken framing (`Content-Length`).
4. Requests stuck after large `didChange`.

## Checks

1. `dots lsp doctor`
2. `dots lsp stats --json`
3. Inspect `.dots/logs/lsp.log`
4. Validate client uses stdio and JSON-RPC 2.0.

## Common fixes

1. Ensure command is `dots lsp serve --stdio`.
2. Disable any stdout logging from wrappers/scripts.
3. Increase timeout:
   - `DOTS_LSP_REQUEST_TIMEOUT_MS=5000`
4. Tune debounce:
   - `DOTS_LSP_DEBOUNCE_MS=120`

## Framing issues

- Each message must be:
  - `Content-Length: <n>\r\n\r\n<json>`
- No extra plain-text output on stdout.

## Cancellation

- `$/cancelRequest` marks request cancelled.
- If client retries, send a new id.
