#!/usr/bin/env bash
set -euo pipefail

# Backward-compatible wrapper.
bash "$(cd "$(dirname "$0")" && pwd)/uninstall_geany_runtime.sh"
