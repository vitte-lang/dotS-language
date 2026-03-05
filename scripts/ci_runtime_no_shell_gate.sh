#!/usr/bin/env bash
set -euo pipefail

if rg -n "process\.exec\(\"bash\"|process\.exec\(\"sh\"|process\.exec\(\"zsh\"" runtime; then
  echo "runtime shell exec usage is forbidden"
  exit 1
fi

if rg -n "process\.exec\(.*runtime/" cmd scripts | rg -n "\"bash\"|\"sh\"|\"zsh\"" ; then
  echo "indirect runtime shell exec usage is forbidden"
  exit 1
fi

echo "runtime no-shell gate ok"
