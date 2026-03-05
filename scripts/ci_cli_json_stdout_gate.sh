#!/usr/bin/env bash
set -euo pipefail

# Static guard: core JSON emitters should use structured printers.
rg -n "print_json_response_ex\(|\"schema_version\"" cmd/dots >/dev/null || { echo "no CLI json emitters found"; exit 1; }

echo "cli json stdout gate ok"
