#!/usr/bin/env bash
set -euo pipefail

rg -n 'fake_registry' tests/cli >/dev/null || { echo "missing fake registry e2e tests"; exit 1; }
rg -n 'install --json' tests/cli/e2e_fake_registry.test.vit >/dev/null || { echo "missing install e2e"; exit 1; }
rg -n 'publish --json' tests/cli/e2e_fake_registry.test.vit >/dev/null || { echo "missing publish e2e"; exit 1; }
rg -n 'real_mode' tests/cli/e2e_registry_real_mode.test.vit >/dev/null || { echo "missing real mode e2e tests"; exit 1; }

echo "package coverage gate ok"
