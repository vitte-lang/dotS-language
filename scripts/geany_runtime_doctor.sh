#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}/geany"
fail=0

check() {
  local f="$1"
  if [[ -f "$f" ]]; then
    echo "[ok] $f"
  else
    echo "[fail] missing $f"
    fail=1
  fi
}

echo "== geany runtime source assets =="
check "$ROOT/editor/geany/README.md"
check "$ROOT/editor/geany/filedefs/filetypes.DOTS.conf"
check "$ROOT/editor/geany/filedefs/filetypes.VIT.conf"
check "$ROOT/editor/geany/filedefs/snippets.DOTS.conf"
check "$ROOT/editor/geany/filedefs/snippets.VIT.conf"
check "$ROOT/editor/geany/tools/geany.conf"
check "$ROOT/editor/geany/tools/keybindings.conf"
check "$ROOT/editor/geany/tools/plugins/geanylsp.conf"
check "$ROOT/editor/geany/dotS-language.runtime.geany"
check "$ROOT/editor/geany/dotS-language.strict-runtime.geany"


echo "== scripts =="
for s in \
  "$ROOT/scripts/geany_sync_runtime_profile.sh" \
  "$ROOT/scripts/install_geany_runtime.sh" \
  "$ROOT/scripts/uninstall_geany_runtime.sh" \
  "$ROOT/scripts/geany_runtime_bootstrap.sh" \
  "$ROOT/scripts/geany_goto_definition.sh" \
  "$ROOT/scripts/geany_find_references.sh"; do
  check "$s"
  [[ -x "$s" ]] || { echo "[fail] not executable: $s"; fail=1; }
done

echo "== runtime =="
command -v dots >/dev/null 2>&1 && echo "[ok] dots in PATH" || echo "[warn] dots not found"
command -v rg >/dev/null 2>&1 && echo "[ok] rg in PATH" || echo "[warn] rg not found"

echo "== user config =="
[[ -d "$CFG" ]] && echo "[ok] geany config dir: $CFG" || echo "[warn] geany config dir missing: $CFG"

echo "== gate =="
bash "$ROOT/scripts/ci_geany_assets_gate.sh" || fail=1

if [[ $fail -ne 0 ]]; then
  echo "geany runtime doctor: failed"
  exit 1
fi

echo "geany runtime doctor: ok"
