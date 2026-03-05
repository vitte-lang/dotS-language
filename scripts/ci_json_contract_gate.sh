#!/usr/bin/env bash
set -euo pipefail

for f in cmd/dots/install.vit cmd/dots/update.vit cmd/dots/publish.vit; do
  rg -n 'print_json_response_ex\(' "$f" >/dev/null || { echo "missing json contract output in $f"; exit 1; }
  rg -n '"1\.1\.0"|print_json_response_ex\("1\.' "$f" >/dev/null || { echo "missing explicit schema version in $f"; exit 1; }
  rg -n 'print_json_response_ex\("1\.1\.0"' "$f" >/dev/null || { echo "network command must emit schema_version>=1.1.0 in $f"; exit 1; }
done

rg -n 'error_type|error_message' cmd/dots/common/output.vit >/dev/null || { echo "missing error fields in common output"; exit 1; }

echo "json contract gate ok"
