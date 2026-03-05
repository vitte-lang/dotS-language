#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/editor/geany"

copy_sync() {
  local src="$1"
  local dst="$2"
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

# Source-of-truth: editor/geany/*
copy_sync "$SRC/filedefs/filetypes.DOTS.conf" "$ROOT/filedefs/filetypes.DOTS.conf"
copy_sync "$SRC/filedefs/filetypes.VIT.conf" "$ROOT/filedefs/filetypes.VIT.conf"
copy_sync "$SRC/filedefs/snippets.DOTS.conf" "$ROOT/filedefs/snippets.DOTS.conf"
copy_sync "$SRC/filedefs/snippets.VIT.conf" "$ROOT/filedefs/snippets.VIT.conf"
copy_sync "$SRC/tools/geany.conf" "$ROOT/tools/geany/geany.conf"
copy_sync "$SRC/tools/keybindings.conf" "$ROOT/tools/geany/keybindings.conf"
copy_sync "$SRC/tools/plugins/geanylsp.conf" "$ROOT/tools/geany/plugins/geanylsp.conf"

copy_sync "$SRC/templates/files/new_runtime_module.vit" "$ROOT/filedefs/templates/files/new_runtime_module.vit"
copy_sync "$SRC/templates/files/new_runtime_test.vit" "$ROOT/filedefs/templates/files/new_runtime_test.vit"

# Keep repository root clean: Geany project profiles are stored under
# editor/geany/profiles only.
rm -f \
  "$ROOT/dotS-language.geany" \
  "$ROOT/dotS-language.strict-dev.geany" \
  "$ROOT/dotS-language.docs.geany" \
  "$ROOT/dotS-language.perf.geany" \
  "$ROOT/dotS-language.runtime.geany" \
  "$ROOT/dotS-language.strict-runtime.geany"

echo "synced geany runtime assets from editor/geany to legacy paths"
