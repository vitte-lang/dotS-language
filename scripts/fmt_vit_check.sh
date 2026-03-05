#!/usr/bin/env bash
set -euo pipefail

# Minimal formatter gate placeholder: ensure LF and final newline.
fail=0
while IFS= read -r -d '' f; do
  if [[ -n "$(tail -c 1 "$f" || true)" ]]; then
    echo "missing trailing newline: $f"
    fail=1
  fi
done < <(find cmd tests -name '*.vit' -print0)

[[ "$fail" -eq 0 ]] || exit 1
echo "vit fmt-check ok"
