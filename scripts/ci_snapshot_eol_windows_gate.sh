#!/usr/bin/env bash
set -euo pipefail

if rg -U -n "\r$" tests/snapshots >/dev/null; then
  echo "CRLF detected in snapshots"
  exit 1
fi

echo "windows snapshot eol gate ok"
