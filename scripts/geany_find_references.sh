#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || -z "${1:-}" ]]; then
  echo "usage: geany_find_references.sh <symbol> [path]" >&2
  exit 2
fi

symbol="$1"
root="${2:-$(pwd)}"

if ! command -v rg >/dev/null 2>&1; then
  echo "rg not found" >&2
  exit 1
fi

rg --line-number --column --hidden --glob '*.vit' --glob '*.dotS' "\\b${symbol}\\b" "$root" || true
