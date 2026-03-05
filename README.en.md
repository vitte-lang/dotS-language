# dotS-language

`dotS-language` is an experimental language + runtime + CLI project.

Goal: build a coherent technical foundation to write, analyze, execute, and test `.dotS` / `.vit` code.

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

## Mini `.dotS` example (theoretical)

```dotS
proc main() -> i32
{
    const n: i32 = 3
    if n > 0
    {
        give 0
    }
    give 1
}
```

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
