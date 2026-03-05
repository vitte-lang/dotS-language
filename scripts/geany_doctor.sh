#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/geany"
fail=0

check_file() {
  local f="$1"
  if [[ -f "$f" ]]; then
    echo "[ok] $f"
  else
    echo "[fail] missing $f"
    fail=1
  fi
}

echo "== geany assets =="
check_file "$ROOT/filedefs/filetypes.DOTS.conf"
check_file "$ROOT/filedefs/filetypes.VIT.conf"
check_file "$ROOT/filedefs/snippets.DOTS.conf"
check_file "$ROOT/tools/geany/geany.conf"
check_file "$ROOT/tools/geany/keybindings.conf"
check_file "$ROOT/tools/geany/plugins/geanylsp.conf"
check_file "$ROOT/scripts/geany_goto_definition.sh"

echo "== runtime =="
if command -v dots >/dev/null 2>&1; then echo "[ok] dots in PATH"; else echo "[warn] dots not found"; fi
if command -v rg >/dev/null 2>&1; then echo "[ok] rg in PATH"; else echo "[warn] rg not found"; fi

echo "== user config =="
if [[ -d "$CFG" ]]; then
  echo "[ok] geany config dir: $CFG"
else
  echo "[warn] geany config dir missing: $CFG"
fi

echo "== gate checks =="
bash "$ROOT/scripts/ci_geany_assets_gate.sh" || fail=1

if [[ $fail -ne 0 ]]; then
  echo "geany doctor: failed"
  exit 1
fi

echo "geany doctor: ok"
