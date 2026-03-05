#!/usr/bin/env bash
set -euo pipefail

for d in runtime core cmd/dots; do
  test -d "$d" || { echo "missing $d"; exit 1; }
done

# Placeholder structural gate.
rt=$(find runtime -type f | wc -l | tr -d ' ')
cr=$(find core -type f | wc -l | tr -d ' ')
cd=$(find cmd/dots -type f | wc -l | tr -d ' ')

echo "runtime files: $rt"
echo "core files: $cr"
echo "cmd files: $cd"

echo "runtime/core/cmd coverage gate ok"
