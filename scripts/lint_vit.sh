#!/usr/bin/env bash
set -euo pipefail

fail=0
while IFS= read -r -d '' f; do
  if rg -n "\t" "$f" >/dev/null; then
    echo "tab found in $f"
    fail=1
  fi
  if rg -n " +$" "$f" >/dev/null; then
    echo "trailing spaces in $f"
    fail=1
  fi
done < <(find cmd tests -name '*.vit' -print0)

[[ "$fail" -eq 0 ]] || exit 1
echo "vit lint ok"
