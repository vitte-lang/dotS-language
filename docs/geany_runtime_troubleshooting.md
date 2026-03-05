# Geany Runtime Troubleshooting

## Common failures

1. `dots` command not found
- Fix PATH used by Geany terminal.

2. Geany tools fail with missing script
- Run `bash scripts/ci_geany_assets_gate.sh`.
- Run `bash scripts/geany_sync_runtime_profile.sh`.

3. LSP diagnostics not shown
- Check `editor/geany/tools/plugins/geanylsp.conf`.
- Check `.dots/logs/geanylsp.log`.

4. Runtime strict gates fail unexpectedly
- Verify env:
  - `DOTS_RUNTIME_STRICT=1`
  - `DOTS_CLI_STRICT=1`
  - `DOTS_RUNTIME_SEED=424242`

5. Shell-risky command gate fails
- Remove direct network calls from Geany assets.
