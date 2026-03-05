# ADR 0001: Central CLI Dispatcher

## Status
Accepted

## Decision
Use `cmd/dots/main.vit` as single entrypoint with:
- centralized global flag parsing
- command registry in `cmd/dots/registry.vit`
- shared context/logger/exit codes in `cmd/dots/common/*`

## Consequences
- consistent UX and error model
- easier completion/help/man generation
- strict parse/validate/execute contract per command
