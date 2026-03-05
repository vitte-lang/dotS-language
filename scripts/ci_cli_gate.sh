#!/usr/bin/env bash
set -euo pipefail

reg="cmd/dots/registry.vit"
main="cmd/dots/main.vit"

[[ -f "$reg" ]] || { echo "missing registry"; exit 2; }
[[ -f "$main" ]] || { echo "missing main"; exit 2; }

# ensure command defs have usage/examples/options fields via constructor shape
count_defs=$(grep -c 'CommandDef("' "$reg" || true)
[[ "$count_defs" -gt 0 ]] || { echo "no command definitions"; exit 2; }

# ensure generated parser_each_command test is up to date
scripts/gen_parser_each_command_test.sh >/dev/null

# ensure each command file contains usage proc and --help handling
fail=0
for f in cmd/dots/*.vit; do
  [[ "$f" == "cmd/dots/main.vit" || "$f" == "cmd/dots/registry.vit" || "$f" == "cmd/dots/_command_template.vit" ]] && continue
  if ! grep -q 'proc usage' "$f"; then
    echo "missing usage in $f"
    fail=1
  fi
  if ! grep -q 'proc parse' "$f"; then
    echo "missing parse in $f"
    fail=1
  fi
  if ! grep -q 'proc validate' "$f"; then
    echo "missing validate in $f"
    fail=1
  fi
  if ! grep -q 'proc execute' "$f"; then
    echo "missing execute in $f"
    fail=1
  fi
  if ! grep -q -- '--help' "$f"; then
    echo "missing --help in $f"
    fail=1
  fi
done

[[ "$fail" -eq 0 ]] || exit 1

echo "cli gate ok"
