#!/usr/bin/env bash
set -euo pipefail

fail=0
for f in cmd/dots/*.vit; do
  b="$(basename "$f")"
  [[ "$b" =~ ^(main.vit|registry.vit|_command_template.vit)$ ]] && continue
  if ! grep -q -- '--json' "$f"; then
    echo "command without --json support: $b"
    fail=1
  fi
done

[[ "$fail" -eq 0 ]] || exit 1
echo "json flag gate ok"
