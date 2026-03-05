#!/usr/bin/env bash
set -euo pipefail

f="modules/package/backend/transport_real.vit"

rg -n 'protocol_real_field\(' "$f" >/dev/null || { echo "real protocol parser not used"; exit 1; }
rg -n 'protocol_real_supported\(' "$f" >/dev/null || { echo "protocol version check missing"; exit 1; }
rg -n 'REAL_BACKEND_PROTOCOL' "$f" >/dev/null || { echo "typed protocol error missing"; exit 1; }

if rg -n 'key=value|field_kv|error_code' "$f" >/dev/null 2>&1; then
  echo "legacy key=value parsing forbidden in transport_real"
  exit 1
fi

echo "real protocol gate ok"

