#!/usr/bin/env bash
set -euo pipefail

if [ -f dots.lock ]; then
  test -s dots.lock || { echo "dots.lock is empty"; exit 1; }
fi

rg -n "schema_version" core/config runtime/common/config.vit cmd/dots/config.vit >/dev/null || {
  echo "missing schema_version in config modules"
  exit 1
}

echo "lock/config schema gate ok"
