#!/usr/bin/env bash
set -euo pipefail

git diff --exit-code tests/cli/parser_each_command.test.vit completions tests/snapshots/cli_help tests/snapshots/cli_json >/dev/null || {
  echo "generated files are not up to date"
  exit 1
}

echo "generated freshness gate ok"
