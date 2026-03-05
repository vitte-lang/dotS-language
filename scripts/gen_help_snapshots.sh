#!/usr/bin/env bash
set -euo pipefail

mkdir -p tests/snapshots/cli_help tests/snapshots/cli_json

mapfile -t cmds < <(rg -o 'CommandDef\("([a-z0-9-]+)"' cmd/dots/registry.vit | sed -E 's/.*"([a-z0-9-]+)"/\1/' | sort -u)

cat > tests/snapshots/cli_help/main.snapshot.txt <<MAIN
DotS CLI
Usage: dots [global options] <command> [command options]
Global options: --config --cwd --json --quiet --verbose --trace --timeout-ms --profile --color --no-color --yes --force --dry-run --include
MAIN

for c in "${cmds[@]}"; do
  cat > "tests/snapshots/cli_help/${c}.snapshot.txt" <<CMD
Command: ${c}
Usage: dots ${c}
Command options: see registry
CMD

  cat > "tests/snapshots/cli_json/${c}.snapshot.json" <<JSON
{"command":"${c}","schema_version":"1"}
JSON
done

echo "help/json snapshots generated from registry"
