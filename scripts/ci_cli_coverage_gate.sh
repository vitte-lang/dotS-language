#!/usr/bin/env bash
set -euo pipefail

fail=0
for f in cmd/dots/*.vit; do
  b="$(basename "$f" .vit)"
  [[ "$b" =~ ^(main|registry|_command_template)$ ]] && continue
  if ! rg -n "\b${b}\b" tests/cli >/dev/null 2>&1; then
    echo "missing cli tests referencing command: $b"
    fail=1
  fi
done

[[ "$fail" -eq 0 ]] || exit 1
echo "cli coverage gate ok"
