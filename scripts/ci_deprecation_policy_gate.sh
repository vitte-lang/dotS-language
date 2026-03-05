#!/usr/bin/env bash
set -euo pipefail

test -f docs/cli_deprecation_policy.md || { echo "missing docs/cli_deprecation_policy.md"; exit 1; }
rg -n "deprecat|removal|date" docs/cli_deprecation_policy.md >/dev/null || { echo "deprecation policy incomplete"; exit 1; }

echo "deprecation policy gate ok"
