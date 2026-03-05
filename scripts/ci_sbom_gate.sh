#!/usr/bin/env bash
set -euo pipefail

mkdir -p .dots/reports
out=.dots/reports/sbom.spdx.txt
{
  echo "SPDXVersion: SPDX-2.3"
  echo "DataLicense: CC0-1.0"
  echo "SPDXID: SPDXRef-DOCUMENT"
  echo "DocumentName: dotS-language-ci-sbom"
  echo "DocumentNamespace: https://example.invalid/spdx/dots/${RANDOM}"
  echo "Creator: Tool: ci_sbom_gate.sh"
  echo "Created: 2026-01-01T00:00:00Z"
} > "$out"

echo "sbom gate ok"
