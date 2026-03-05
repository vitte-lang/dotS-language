# CLI Contribution Guide

## Rules
1. Every command implements `parse`, `validate`, `execute`.
2. Every command supports `--help` and `--json`.
3. Errors must be prefixed with `dots:`.
4. Use shared modules from `cmd/dots/common/*`.
5. Add tests in `tests/cli/` for flags + exit codes.

## Adding a command
- Add file from `cmd/dots/_command_template.vit`
- Register in `cmd/dots/registry.vit`
- Add docs and tests
