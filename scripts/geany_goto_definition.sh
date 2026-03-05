#!/usr/bin/env bash
set -euo pipefail

sym="${1:-}"
if [[ -z "$sym" ]]; then
  echo "usage: geany_goto_definition.sh <symbol>" >&2
  exit 2
fi

if command -v rg >/dev/null 2>&1; then
  rg -n "^(proc|form|space)[[:space:]]+${sym}\\b" . -g '*.dotS' -g '*.vit' > /tmp/dots_defs.$$ || true
else
  grep -RnsE "^(proc|form|space)[[:space:]]+${sym}\\b" -- *.dotS *.vit > /tmp/dots_defs.$$ || true
fi

if [[ ! -s /tmp/dots_defs.$$ ]]; then
  exit 1
fi

awk -F: '
function score(path,line){
  s=0
  if (line ~ /^proc[[:space:]]+/) s+=50
  else if (line ~ /^form[[:space:]]+/) s+=30
  else if (line ~ /^space[[:space:]]+/) s+=20
  if (path ~ /cmd\//) s+=5
  return s
}
{ sc=score($1,$3); print sc "|" $0 }
' /tmp/dots_defs.$$ | sort -t'|' -k1,1nr | head -n1 | cut -d'|' -f2-

rm -f /tmp/dots_defs.$$
