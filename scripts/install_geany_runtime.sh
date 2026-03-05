#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/geany"
BK="$CFG/.dots-runtime-backup-$(date +%Y%m%d-%H%M%S)"
SRC="$ROOT/editor/geany"

bash "$ROOT/scripts/geany_sync_runtime_profile.sh"

mkdir -p "$CFG/filedefs/templates/files" "$CFG/plugins" "$BK"

backup_copy() {
  local src="$1" dst="$2"
  if [[ -f "$dst" ]]; then
    mkdir -p "$BK/$(dirname "${dst#$CFG/}")"
    cp "$dst" "$BK/${dst#$CFG/}"
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

backup_copy "$SRC/filedefs/filetypes.DOTS.conf" "$CFG/filedefs/filetypes.DOTS.conf"
backup_copy "$SRC/filedefs/filetypes.VIT.conf" "$CFG/filedefs/filetypes.VIT.conf"
backup_copy "$SRC/filedefs/snippets.DOTS.conf" "$CFG/filedefs/snippets.DOTS.conf"
backup_copy "$SRC/filedefs/snippets.VIT.conf" "$CFG/filedefs/snippets.VIT.conf"
backup_copy "$SRC/tools/geany.conf" "$CFG/geany.conf"
backup_copy "$SRC/tools/keybindings.conf" "$CFG/keybindings.conf"
backup_copy "$SRC/tools/plugins/geanylsp.conf" "$CFG/plugins/geanylsp.conf"
backup_copy "$SRC/templates/files/new_runtime_module.vit" "$CFG/filedefs/templates/files/new_runtime_module.vit"
backup_copy "$SRC/templates/files/new_runtime_test.vit" "$CFG/filedefs/templates/files/new_runtime_test.vit"

cat "$SRC/filedefs/snippets.DOTS.conf" >> "$CFG/snippets.conf"
cat "$SRC/filedefs/snippets.VIT.conf" >> "$CFG/snippets.conf"

echo "geany runtime assets installed"
echo "backup: $BK"
