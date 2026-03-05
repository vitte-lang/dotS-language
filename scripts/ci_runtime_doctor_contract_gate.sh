#!/usr/bin/env bash
set -euo pipefail

rg -n "runtime_doctor\(" runtime/status.vit >/dev/null
rg -n "DOTS_RUNTIME_STRICT|DOTS_RUNTIME_SEED" runtime/common/config.vit >/dev/null

echo "runtime doctor contract gate ok"
