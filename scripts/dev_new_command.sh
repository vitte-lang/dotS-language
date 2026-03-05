#!/usr/bin/env bash
set -euo pipefail

name="${1:-}"
[[ -n "$name" ]] || { echo "usage: scripts/dev_new_command.sh <command-name>"; exit 2; }

cmd_file="cmd/dots/${name}.vit"
test_file="tests/cli/${name}.command.test.vit"
doc_file="docs/cli/${name}.md"

[[ -f "$cmd_file" ]] && { echo "command file already exists: $cmd_file"; exit 2; }

mkdir -p cmd/dots tests/cli docs/cli
cp cmd/dots/_command_template.vit "$cmd_file"
sed -i "s/dots\/cmd\/template/dots\/cmd\/${name}/g" "$cmd_file"

cat > "$test_file" <<TEST
.test.cli.${name}.scaffold.
.begin.
.assert.parse.ok."dots ${name} --help".
.assert.parse.ok."dots ${name} --json --help".
.ret.
.end.
TEST

cat > "$doc_file" <<DOC
# dots ${name}

Usage:
- \\`dots ${name} --help\\`

Options:
- \\`--json\\`
- \\`--help\\`
DOC

echo "created: $cmd_file"
echo "created: $test_file"
echo "created: $doc_file"
echo "next: register command in cmd/dots/registry.vit"
