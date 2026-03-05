#!/usr/bin/env bash
set -euo pipefail
bash "$(cd "$(dirname "$0")" && pwd)/gen_completion_from_registry.sh"
