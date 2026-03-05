#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

fail=0

required_source=(
  editor/geany/README.md
  editor/geany/filedefs/filetypes.DOTS.conf
  editor/geany/filedefs/filetypes.VIT.conf
  editor/geany/filedefs/snippets.DOTS.conf
  editor/geany/filedefs/snippets.VIT.conf
  editor/geany/templates/files/new_runtime_module.vit
  editor/geany/templates/files/new_runtime_test.vit
  editor/geany/templates/snippets/dots.snippets.tmpl
  editor/geany/templates/snippets/vit.snippets.tmpl
  editor/geany/tools/geany.conf
  editor/geany/tools/keybindings.conf
  editor/geany/tools/plugins/geanylsp.conf
  editor/geany/dotS-language.runtime.geany
  editor/geany/dotS-language.strict-runtime.geany
)

required_scripts=(
  scripts/geany_sync_runtime_profile.sh
  scripts/install_geany_runtime.sh
  scripts/uninstall_geany_runtime.sh
  scripts/geany_runtime_doctor.sh
  scripts/geany_runtime_bootstrap.sh
  scripts/geany_goto_definition.sh
  scripts/geany_find_references.sh
  scripts/gen_geany_snippets.sh
)

for f in "${required_source[@]}"; do
  [[ -f "$f" ]] || { echo "missing $f"; fail=1; }
done

for s in "${required_scripts[@]}"; do
  [[ -f "$s" ]] || { echo "missing $s"; fail=1; continue; }
  [[ -x "$s" ]] || { echo "not executable: $s"; fail=1; }
done

for sec in "[styling=C]" "[keywords]" "[settings]" "[indentation]" "[build-menu]" "[tagmanager]"; do
  grep -Fx "$sec" editor/geany/filedefs/filetypes.DOTS.conf >/dev/null || { echo "filetypes.DOTS.conf missing section $sec"; fail=1; }
done

rg -n "save_all_before_build=true" editor/geany/tools/geany.conf >/dev/null || { echo "save_all_before_build missing"; fail=1; }
rg -n "DOTS_RUNTIME_STRICT=1" editor/geany/tools/geany.conf editor/geany/dotS-language.strict-runtime.geany >/dev/null || { echo "strict env missing"; fail=1; }
rg -n "DOTS_RUNTIME_SEED=" editor/geany/tools/geany.conf editor/geany/dotS-language.strict-runtime.geany >/dev/null || { echo "runtime seed missing"; fail=1; }

# Ensure commands referenced by Geany assets point to scripts that exist.
for asset in \
  editor/geany/filedefs/filetypes.DOTS.conf \
  editor/geany/filedefs/filetypes.VIT.conf \
  editor/geany/dotS-language.runtime.geany \
  editor/geany/dotS-language.strict-runtime.geany \
  editor/geany/tools/plugins/geanylsp.conf; do
  while IFS= read -r ref; do
    path="${ref%\"}"
    path="${path#\"}"
    [[ -f "$path" ]] || { echo "missing referenced script: $path (from $asset)"; fail=1; }
  done < <(rg -o 'scripts/[A-Za-z0-9_./-]+\.sh' "$asset" | sort -u)
done

# Forbid direct network actions in Geany assets.
if rg -n "curl|wget|http://|https://" \
  editor/geany/filedefs \
  editor/geany/tools \
  editor/geany/dotS-language.runtime.geany \
  editor/geany/dotS-language.strict-runtime.geany >/dev/null 2>&1; then
  echo "network calls forbidden in geany assets"
  fail=1
fi

# Guard shell-risky runtime usage in assets.
if rg -n 'process\.exec\("bash"' editor/geany --glob '!filedefs/filetypes.*.conf' >/dev/null 2>&1; then
  echo "shell-risky pattern forbidden outside highlight rules"
  fail=1
fi

# Ensure legacy paths are synced from source-of-truth.
bash scripts/geany_sync_runtime_profile.sh >/dev/null
for pair in \
  "editor/geany/filedefs/filetypes.DOTS.conf:filedefs/filetypes.DOTS.conf" \
  "editor/geany/filedefs/filetypes.VIT.conf:filedefs/filetypes.VIT.conf" \
  "editor/geany/filedefs/snippets.DOTS.conf:filedefs/snippets.DOTS.conf" \
  "editor/geany/filedefs/snippets.VIT.conf:filedefs/snippets.VIT.conf" \
  "editor/geany/tools/geany.conf:tools/geany/geany.conf" \
  "editor/geany/tools/keybindings.conf:tools/geany/keybindings.conf" \
  "editor/geany/tools/plugins/geanylsp.conf:tools/geany/plugins/geanylsp.conf"; do
  src="${pair%%:*}"
  dst="${pair##*:}"
  cmp -s "$src" "$dst" || { echo "out-of-sync: $dst (run geany_sync_runtime_profile.sh)"; fail=1; }
done

[[ "$fail" -eq 0 ]] || exit 1
echo "geany assets gate ok"
