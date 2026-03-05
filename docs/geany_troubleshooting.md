# Geany Troubleshooting

## Plugin LSP absent
- Verify plugin installed in Geany.
- Check `~/.config/geany/plugins/geanylsp.conf` exists.
- Fallback: `bash scripts/geany_goto_definition.sh <symbol>`.

## Mauvais path runtime dots
- Run: `command -v dots`.
- If missing, fix PATH in shell and restart Geany.

## Regex erreurs non cliquables
- Verify `compiler_regex` in `filedefs/filetypes.DOTS.conf`.
- Example expected: `path/file.vit:42: message`.

## Snippets non chargés
- Ensure `[DOTS]` section appended to `~/.config/geany/snippets.conf`.
- Restart Geany after update.

## Templates non visibles
- Ensure files are in `~/.config/geany/filedefs/templates/files/`.
- Use `File -> New (from template)`.
