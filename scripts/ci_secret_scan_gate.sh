#!/usr/bin/env bash
set -euo pipefail

if command -v gitleaks >/dev/null 2>&1; then
  gitleaks detect --source . --no-git --redact || exit 1
  echo "secret scan gate ok (gitleaks)"
  exit 0
fi

# fallback lightweight patterns
rg -n "AKIA[0-9A-Z]{16}|-----BEGIN (RSA|EC|OPENSSH) PRIVATE KEY-----|ghp_[A-Za-z0-9]{36}" . && {
  echo "secret-like pattern found"
  exit 1
}

echo "secret scan gate ok (fallback)"
