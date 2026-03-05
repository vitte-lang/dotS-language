#!/usr/bin/env bash
set -euo pipefail

fail=0

required=(
  filedefs/filetypes.DOTS.conf
  filedefs/filetypes.VIT.conf
  filedefs/snippets.DOTS.conf
  filedefs/templates/files/new_command.vit
  filedefs/templates/files/new_benchmark.dotS
  filedefs/templates/files/new_parser_test.vit
  tools/geany/geany.conf
  tools/geany/keybindings.conf
  tools/geany/plugins/geanylsp.conf
  scripts/install_geany_dots.sh
  scripts/uninstall_geany_dots.sh
  scripts/geany_sync_project.sh
  scripts/geany_doctor.sh
  scripts/geany_goto_definition.sh
)

for f in "${required[@]}"; do
  [[ -f "$f" ]] || { echo "missing $f"; fail=1; }
done

for s in scripts/install_geany_dots.sh scripts/uninstall_geany_dots.sh scripts/geany_sync_project.sh scripts/geany_doctor.sh scripts/geany_goto_definition.sh; do
  [[ -x "$s" ]] || { echo "not executable: $s"; fail=1; }
done

for sec in "[styling=C]" "[keywords]" "[settings]" "[indentation]" "[build-menu]" "[tagmanager]"; do
  grep -Fx "$sec" filedefs/filetypes.DOTS.conf >/dev/null || { echo "filetypes.DOTS.conf missing section $sec"; fail=1; }
done

rg -n "save_all_before_build=true" tools/geany/geany.conf >/dev/null || { echo "save_all_before_build missing"; fail=1; }
rg -n "DOTS_CLI_STRICT=1" tools/geany/geany.conf >/dev/null || { echo "strict terminal env missing"; fail=1; }

for cmd in \
  "bash scripts/gen_completion_from_registry.sh" \
  "bash scripts/ci_completion_up_to_date.sh" \
  "bash scripts/ci_real_protocol_gate.sh" \
  "bash scripts/cli_startup_bench.sh" \
  "bash scripts/bench.sh"; do
  rg -n "$cmd" filedefs/filetypes.DOTS.conf dotS-language.geany >/dev/null || { echo "missing external tool command: $cmd"; fail=1; }
done

if rg -n "curl|wget|http://|https://" filedefs/filetypes.DOTS.conf tools/geany/geany.conf tools/geany/keybindings.conf tools/geany/plugins/geanylsp.conf >/dev/null 2>&1; then
  echo "network calls forbidden in geany assets"
  fail=1
fi

[[ "$fail" -eq 0 ]] || exit 1
echo "geany assets gate ok"
