#!/usr/bin/env bash
set -euo pipefail

fail=0
for f in completions/dots.bash completions/_dots completions/dots.fish scripts/gen_completion_from_registry.sh; do
  if rg -n 'curl|wget|http://|https://' "$f" >/dev/null 2>&1; then
    echo "network call/reference forbidden in completion path: $f"
    fail=1
  fi
done

[[ "$fail" -eq 0 ]] || exit 1
echo "completion no-network gate ok"

