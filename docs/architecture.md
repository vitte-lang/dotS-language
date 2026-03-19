# DotS Architecture

DotS is organized around a small layered pipeline:

- `core/`: source handling, lexer, parser, semantic analysis, diagnostics, config, security
- `runtime/`: execution support, status, events, traces, VM/JIT scaffolding
- `cmd/dots/`: CLI entrypoints such as `check`, `run`, `build`, `fmt`, `lint`, `doc`
- `lsp/`: editor-facing completion, diagnostics, symbols, references, hover
- `modules/`: package backend, manifest handling, Vitte package loader integration
- `stdlib/`: user-facing helpers layered over core/runtime primitives
- `tools/`: formatter, linter, docgen, profiler, debugger

High-level flow:

1. read source
2. lex and parse `.dotS`
3. run semantic checks
4. resolve `use/import`, including `../vitte/src/vitte/packages`
5. hand results to CLI/LSP/runtime/build tooling

Core contracts that should stay stable:

- `core/fs`: file existence, reads/writes, path and directory helpers, timestamps
- `core/io`: human output and stdin capture
- `core/process`: args, env, cwd, child process bridge

Current project direction:

- DotS acts as a script/frontend layer
- Vitte packages can be resolved as external modules
- CLI and LSP are first-class surfaces, not afterthoughts
