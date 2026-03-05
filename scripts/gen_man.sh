#!/usr/bin/env bash
set -euo pipefail

mkdir -p docs/man

mapfile -t lines < <(rg 'CommandDef\(' cmd/dots/registry.vit)

{
  echo "DOTS(1)"
  echo "# NAME"
  echo "dots - DotS command line"
  echo "# SYNOPSIS"
  echo "dots [global options] <command> [command options]"
  echo "# COMMANDS"
} > docs/man/dots.1.txt

for l in "${lines[@]}"; do
  name=$(echo "$l" | sed -E 's/.*CommandDef\("([a-z0-9-]+)".*/\1/')
  usage=$(echo "$l" | sed -E 's/.*"dots[^\"]*".*"([^"]+)".*$/\1/' || true)
  desc=$(echo "$l" | sed -E 's/.*\], "([^"]+)", "dots.*/\1/' || true)

  [[ -z "$name" ]] && continue
  [[ "$usage" == "$l" || -z "$usage" ]] && usage="dots ${name}"
  [[ "$desc" == "$l" || -z "$desc" ]] && desc="DotS command ${name}"

  {
    echo "- ${name}: ${desc}"
  } >> docs/man/dots.1.txt

  {
    echo "DOTS-${name}(1)"
    echo "# NAME"
    echo "dots ${name}"
    echo "# USAGE"
    echo "$usage"
    echo "# DESCRIPTION"
    echo "$desc"
  } > "docs/man/dots-${name}.1.txt"
done

echo "manual pages generated from registry"
