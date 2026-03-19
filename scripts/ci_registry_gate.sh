#!/usr/bin/env bash
set -euo pipefail

reg="cmd/dots/registry.vit"

# commands defined in registry
mapfile -t cmds < <(rg -o 'CommandDef\("([a-z-]+)"' "$reg" | sed -E 's/.*"([a-z-]+)"/\1/' | sort -u)

fail=0
for c in "${cmds[@]}"; do
  [[ "$c" =~ ^(help|version|completion|plugins|verify|status|whoami|login|logout|self|ffi|lsp|runtime)$ ]] && continue
  f="cmd/dots/${c}.vit"
  if [[ ! -f "$f" ]]; then
    echo "missing command file for registry command: $c"
    fail=1
  fi
done

# each command file should be registered
for f in cmd/dots/*.vit; do
  b="$(basename "$f" .vit)"
  [[ "$b" =~ ^(main|registry|_command_template)$ ]] && continue
  if ! printf '%s\n' "${cmds[@]}" | grep -qx "$b"; then
    echo "command file not registered: $b"
    fail=1
  fi

done

[[ "$fail" -eq 0 ]] || exit 1

echo "registry gate ok"
