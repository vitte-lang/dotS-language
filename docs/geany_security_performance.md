# Geany Security & Performance

## Performance
- Prefer `rg` for symbol lookup.
- Limit huge workspace scans in fallback commands.
- Keep LSP timeouts finite (`request_timeout_ms`).

## Security
- Avoid shell commands with untrusted interpolated input.
- No direct network calls in Geany completion/build helper configs.
- Prefer repository scripts (`scripts/*.sh`) over ad-hoc shell snippets.

## Multi-OS paths
- Linux: `~/.config/geany`
- macOS: `~/.config/geany` (or app-specific config dir)
- Windows: `%APPDATA%\\geany`
