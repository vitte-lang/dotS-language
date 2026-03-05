# How To Add A Command

1. Copy `cmd/dots/_command_template.vit` to `cmd/dots/<name>.vit`.
2. Implement `parse`, `validate`, `execute`.
3. Register it in `cmd/dots/main.vit` `command_registry()`.
4. Add usage/examples/options metadata.
5. Add tests in `tests/cli/`:
   - parser
   - invalid args
   - help snapshot
   - exit code
