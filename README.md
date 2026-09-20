# dotS-language

`dotS-language` is an experimental language + runtime + CLI project.

Goal: build a practical foundation to write, analyze, execute, and test `.dotS` code.

Implementation note: the compiler/tooling is written in **Vitte**.  
Vitte source: <https://github.com/vitte-lang/vitte>

## Current status

- maturity: **alpha / experimental**
- focus: architecture validation, CLI/runtime contracts, developer tooling
- API stability: not guaranteed yet

## Repository layout

- `core/`: lexer, parser, semantic, diagnostics, security, config
- `runtime/`: VM/JIT, concurrency, memory, events, status
- `cmd/`: `dots` CLI commands (run, test, lint, fmt, benchmark, doctor, etc.)
- `lsp/`: Language Server Protocol implementation
- `ffi/`: interoperability layer
- `bench/`: benchmark workloads
- `tests/`: unit, e2e, and snapshot tests
- `docs/`: runbooks, ADRs, JSON contracts, technical docs
- `editor/`: editor integrations (Geany, Vim, etc.)

## Architecture (simple)

```text
core (lexer/parser/semantic/config/security)
  -> runtime (vm/jit/concurrency/memory)
    -> cli (cmd/dots) + lsp
      -> editor integrations + ci gates
```

## Quick start (theoretical)

`dots` must be available in your `PATH`.

```bash
dots help
dots runtime status --json
dots runtime doctor --strict
```

CI/gate examples:

```bash
bash scripts/ci_cli_gate.sh
bash scripts/ci_runtime_status_contract_gate.sh
bash scripts/ci_geany_assets_gate.sh
```

## `.dotS` source examples

Canonical form is line-oriented and does not use leading or trailing dots.

```dotS
module.demo.quickstart
use.thread
set.$workers.4
thread.pool.create.$pool.$workers
call.thread.pool.start
```

```dotS
module.demo.json
set.$enabled.true
set.$name."dotS sample"
json.set.$obj."enabled".$enabled
json.set.$obj."name".$name
chan.create.$chan.int.64
```

## Common invalid patterns

```dotS
module..http
```
Invalid: empty module segment.

```dotS
set.iterations.1000
```
Invalid: variable must start with `$`.

```dotS
chan.create.$chan.integer.$n
```
Invalid: `integer` is not a valid `type_identifier` (`int` is valid).

```dotS
thread.pool.create..$workers
```
Invalid: empty qualified callable segment.

## Useful commands

| Command | Usage |
|---|---|
| `dots help` | list all commands |
| `dots run <file.dotS>` | run a script |
| `dots test` | execute tests |
| `dots lint --format json` | machine-readable lint output |
| `dots fmt --write <file>` | format a file |
| `dots runtime status --json` | runtime status as JSON |
| `dots runtime doctor --strict` | strict runtime diagnostics |
| `dots benchmark --mode quick` | quick benchmark run |

## Project principles

- stable JSON contracts (`schema_version`, `error_type`, `error_message`)
- reproducibility (seeds, snapshots)
- strict modes (`DOTS_*_STRICT=1`)
- clear parse / validate / execute separation
- readable `.dotS` examples first, internals second

## What works / what is in progress

Working:

- modular structure (`core`, `runtime`, `cmd`, `lsp`, `ffi`)
- primary CLI commands and base JSON contracts
- CI gates, snapshots, Geany integration

In progress:

- full runtime/LSP/FFI contract hardening
- broader e2e coverage and stricter performance budgets
- security hardening and strict-mode migration for remaining modules

## Key documentation

- Syntax reference: [`docs/syntax.md`](docs/syntax.md)
- CLI architecture: [`docs/cli_architecture.md`](docs/cli_architecture.md)
- LSP runbook: [`docs/lsp_runbook.md`](docs/lsp_runbook.md)
- Registry runbook: [`docs/registry_runbook.md`](docs/registry_runbook.md)
- Benchmark runbook: [`docs/bench_runbook.md`](docs/bench_runbook.md)
- Editor setup: [`docs/editor_setup.md`](docs/editor_setup.md)

## License

Repository license: **GNU GPL v3.0 (or later)**.

- full text: [`LICENSE`](LICENSE)
- legal overview: [`docs/legal/LICENSE_OVERVIEW.md`](docs/legal/LICENSE_OVERVIEW.md)
- license strategy options: [`docs/legal/LICENSE_OPTIONS.md`](docs/legal/LICENSE_OPTIONS.md)

## Attribution and ownership

- authors: [`AUTHORS.md`](AUTHORS.md)
- copyright: [`COPYRIGHT`](COPYRIGHT)
- notice: [`NOTICE`](NOTICE)
- maintainer statement: [`docs/legal/OWNERSHIP_DECLARATION.md`](docs/legal/OWNERSHIP_DECLARATION.md)

## Legal note

This repository documentation is not legal advice. For formal legal validation, consult a qualified legal professional.
