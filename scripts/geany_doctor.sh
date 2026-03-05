#!/usr/bin/env bash
set -euo pipefail

# Backward-compatible wrapper.
bash "$(cd "$(dirname "$0")" && pwd)/geany_runtime_doctor.sh"
