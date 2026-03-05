#!/usr/bin/env bash
set -euo pipefail

# Backward-compatible wrapper.
bash "$(cd "$(dirname "$0")" && pwd)/geany_sync_runtime_profile.sh"
