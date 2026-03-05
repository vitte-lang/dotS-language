#!/usr/bin/env bash
set -euo pipefail

CFG="${XDG_CONFIG_HOME:-$HOME/.config}/geany"
LATEST="$(ls -dt "$CFG"/.dots-backup-* 2>/dev/null | head -n1 || true)"

rm -f "$CFG/filedefs/filetypes.DOTS.conf" "$CFG/filedefs/filetypes.VIT.conf"
rm -f "$CFG/plugins/geanylsp.conf"
rm -f "$CFG/filedefs/templates/files/new_command.vit" "$CFG/filedefs/templates/files/new_benchmark.dotS" "$CFG/filedefs/templates/files/new_parser_test.vit"

if [[ -n "$LATEST" ]]; then
  while IFS= read -r -d '' f; do
    rel="${f#$LATEST/}"
    mkdir -p "$CFG/$(dirname "$rel")"
    cp "$f" "$CFG/$rel"
  done < <(find "$LATEST" -type f -print0)
  echo "restored from backup: $LATEST"
else
  echo "no backup found; removed DotS/Vit geany files only"
fi
