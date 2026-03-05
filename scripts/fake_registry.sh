#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-}"
dir="${2:-.dots/fake_registry}"

init_registry() {
  mkdir -p "$dir"
  mkdir -p .dots/state
  cat > "$dir/packages.db" <<PKG
core@1.0.0|checksum=core-1.0.0|sig=SIG_CORE_1_0_0
stdlib@1.0.0|checksum=stdlib-1.0.0|sig=SIG_STDLIB_1_0_0
PKG
  cat > "$dir/failures.db" <<FAIL
install=0
update=0
publish=0
FAIL
  : > "$dir/published.log"
  : > .dots/state/installed.db
  cat > .dots/state/circuit_breaker.db <<CB
failures=0
opened_at_ms=0
CB
  echo "fake registry initialized at $dir"
}

set_failure() {
  local op="$3"
  local n="$4"
  [[ -f "$dir/failures.db" ]] || init_registry
  awk -F= -v op="$op" -v n="$n" 'BEGIN{OFS="="} $1==op{$2=n}1' "$dir/failures.db" > "$dir/failures.db.tmp"
  mv "$dir/failures.db.tmp" "$dir/failures.db"
  echo "set failure $op=$n"
}

add_pkg() {
  local name="$3"
  local ver="$4"
  [[ -f "$dir/packages.db" ]] || init_registry
  local sig_name
  sig_name=$(echo "$name" | tr '[:lower:]' '[:upper:]')
  local sig_ver
  sig_ver=$(echo "$ver" | tr '.' '_')
  local line="${name}@${ver}|checksum=${name}-${ver}|sig=SIG_${sig_name}_${sig_ver}"
  grep -qx "$line" "$dir/packages.db" || echo "$line" >> "$dir/packages.db"
  echo "added package ${name}@${ver}"
}

case "$cmd" in
  init)
    init_registry
    ;;
  set-fail)
    set_failure "$@"
    ;;
  add-pkg)
    add_pkg "$@"
    ;;
  clear)
    rm -rf "$dir"
    echo "cleared $dir"
    ;;
  *)
    echo "usage: scripts/fake_registry.sh <init|set-fail|add-pkg|clear> <dir> [args]" >&2
    exit 2
    ;;
esac
