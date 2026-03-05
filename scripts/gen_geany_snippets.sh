#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cp "$ROOT/editor/geany/templates/snippets/dots.snippets.tmpl" "$ROOT/editor/geany/filedefs/snippets.DOTS.conf"
cp "$ROOT/editor/geany/templates/snippets/vit.snippets.tmpl" "$ROOT/editor/geany/filedefs/snippets.VIT.conf"

echo "generated geany snippets from templates"
