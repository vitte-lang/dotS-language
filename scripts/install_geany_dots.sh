#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/geany"
BK="$CFG/.dots-backup-$(date +%Y%m%d-%H%M%S)"

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

backup_copy "$ROOT/filedefs/filetypes.DOTS.conf" "$CFG/filedefs/filetypes.DOTS.conf"
backup_copy "$ROOT/filedefs/filetypes.VIT.conf" "$CFG/filedefs/filetypes.VIT.conf"
backup_copy "$ROOT/tools/geany/geany.conf" "$CFG/geany.conf"
backup_copy "$ROOT/tools/geany/keybindings.conf" "$CFG/keybindings.conf"
backup_copy "$ROOT/tools/geany/plugins/geanylsp.conf" "$CFG/plugins/geanylsp.conf"
backup_copy "$ROOT/filedefs/templates/files/new_command.vit" "$CFG/filedefs/templates/files/new_command.vit"
backup_copy "$ROOT/filedefs/templates/files/new_benchmark.dotS" "$CFG/filedefs/templates/files/new_benchmark.dotS"
backup_copy "$ROOT/filedefs/templates/files/new_parser_test.vit" "$CFG/filedefs/templates/files/new_parser_test.vit"

if [[ -f "$CFG/snippets.conf" ]]; then
  cp "$CFG/snippets.conf" "$BK/snippets.conf"
fi
cat "$ROOT/filedefs/snippets.DOTS.conf" >> "$CFG/snippets.conf"

echo "geany DotS/Vit config installed"
echo "backup: $BK"
