#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REG="$ROOT/cmd/dots/registry.vit"
OUT="$ROOT/tests/cli/parser_each_command.test.vit"

cmds=()
while IFS= read -r cmd; do
  [[ -n "$cmd" ]] && cmds+=("$cmd")
done < <(
  rg -o 'CommandDef\("([a-z0-9-]+)"' "$REG" \
    | sed -E 's/.*"([a-z0-9-]+)"/\1/' \
    | sort -u
)

{
  echo ".test.cli.parser.each.command.help.generated."
  echo ".begin."
  for c in "${cmds[@]}"; do
    echo ".assert.parse.ok.\"dots ${c} --help\"."
  done
  echo ".ret."
  echo ".end."
  echo

  echo ".test.cli.parser.each.command.json.generated."
  echo ".begin."
  for c in "${cmds[@]}"; do
    echo ".assert.parse.ok.\"dots --json ${c} --help\"."
    echo ".assert.parse.ok.\"dots ${c} --json --help\"."
  done
  echo ".ret."
  echo ".end."
  echo

  echo ".test.cli.parser.global.bool_list.generated."
  echo ".begin."
  echo ".assert.parse.ok.\"dots --no-color help\"."
  echo ".assert.parse.ok.\"dots --include=a,b,c check file.dotS\"."
  echo ".assert.parse.ok.\"dots --include a,b,c check file.dotS\"."
  echo ".ret."
  echo ".end."
} > "$OUT"

echo "generated $OUT (${#cmds[@]} commands)"
