#!/usr/bin/env bash
set -euo pipefail

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "shellcheck not available; skipping"
  exit 0
fi

shellcheck scripts/*.sh

echo "shellcheck gate ok"
