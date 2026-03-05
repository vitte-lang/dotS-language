#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

bash "$ROOT/scripts/install_geany_runtime.sh"
bash "$ROOT/scripts/geany_sync_runtime_profile.sh"
bash "$ROOT/scripts/geany_runtime_doctor.sh"

echo "geany runtime bootstrap: ok"
