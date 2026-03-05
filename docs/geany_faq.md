# Geany FAQ

## Geany vs Vim/Emacs/Nano
- Format current file:
  - Geany: Build `Fmt` (or keybinding Ctrl+Shift+I)
  - Vim: `:DotsFmt`
  - Emacs: save hook + `dots fmt --stdin`
  - Nano: external command only
- Go to definition:
  - Geany: GeanyLSP or `scripts/geany_goto_definition.sh`
  - Vim/Emacs: LSP integration preferred
  - Nano: grep/rg manual
- Lint/check/run:
  - All use `dots lint`, `dots check`, `dots run`.
