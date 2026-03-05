#!/usr/bin/env bash
set -euo pipefail

bash scripts/gen_completion_from_registry.sh >/dev/null

git diff --exit-code -- completions/dots.bash completions/_dots completions/dots.fish completions/registry.json >/dev/null || {
  echo "completion files are stale; run scripts/gen_completion_from_registry.sh"
  exit 1
}

echo "completion up-to-date gate ok"

