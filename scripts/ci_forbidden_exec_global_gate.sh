#!/usr/bin/env bash
set -euo pipefail

if rg -n "process\.exec\(\"bash\"|process\.exec\(\"sh\"|process\.exec\(\"zsh\"" cmd core modules runtime ffi lsp; then
  echo "forbidden shell exec pattern found"
  exit 1
fi

echo "forbidden exec global gate ok"
