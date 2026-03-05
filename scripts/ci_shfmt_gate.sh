#!/usr/bin/env bash
set -euo pipefail

if ! command -v shfmt >/dev/null 2>&1; then
  echo "shfmt not available; skipping"
  exit 0
fi

shfmt -d scripts/*.sh

echo "shfmt gate ok"
