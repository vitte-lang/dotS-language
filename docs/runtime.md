# DotS Runtime

The runtime layer currently focuses on execution support, status reporting, logs, traces and events.

Major runtime surfaces:

- `runtime/status.vit`
- `runtime/common/log.vit`
- `runtime/common/events.vit`
- `runtime/common/trace.vit`
- `runtime/memory/*`
- `runtime/vm/*`
- `runtime/jit/*`

What `dots run` does today:

1. resolve file or `--entry`
2. load optional env file
3. parse and run semantic preflight
4. resolve Vitte imports
5. report diagnostics or preflight success

Current limitation:

- `dots run` is still preflight-oriented and not a fully lowered execution engine for Vitte-backed imports

Runtime contracts worth stabilizing:

- status output shape
- event log rotation
- trace persistence
- cancellation/env handling
