#!/usr/bin/env bash
set -euo pipefail

fail=0
files=(
  cmd/dots/install.vit
  cmd/dots/update.vit
  cmd/dots/publish.vit
  cmd/dots/doctor.vit
  modules/package/backend.vit
  modules/package/backend/core.vit
  modules/package/backend/transport_real.vit
  modules/package/backend/transport_fake.vit
  modules/package/install.vit
  modules/package/update.vit
  modules/package/remove.vit
)

for f in "${files[@]}"; do
  if rg -n 'process\.exec\("bash"' "$f" >/dev/null 2>&1; then
    echo "shell execution forbidden in package path: $f"
    fail=1
  fi
done

[[ "$fail" -eq 0 ]] || exit 1
echo "no shell network gate ok"
