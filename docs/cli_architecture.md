# DotS CLI Architecture

## Layers
1. `cmd/dots/main.vit`: single dispatcher, global parser, command registry, middleware.
2. `cmd/dots/<command>.vit`: command parse/validate/execute.
3. `cmd/dots/plugins/*`: plugin API/loader/sandbox.

## Dispatcher responsibilities
- Parse global flags (`--config`, `--cwd`, `--json`, `--quiet`, `--verbose`, `--trace`, `--timeout-ms`, `--profile`, `--color`, `--yes`, `--dry-run`, `--include`)
- Normalize paths
- Standardize exit codes and diagnostics
- Generate help from registry
- Suggest nearest command on typo
- Fallback `dots <file.dotS>` => `dots run <file.dotS>`
- Timing/logging middleware with correlation ID

## Command contract
Each command should implement:
- `parse(argv)`
- `validate(parsed)`
- `execute(parsed)`

## Security
- Prefix errors with `dots:`
- Redact secrets in logs
- Keep plugin sandbox default-deny
- Require explicit `--yes` or `--force` for destructive actions
