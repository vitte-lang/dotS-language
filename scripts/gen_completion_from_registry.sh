#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REG="$ROOT/cmd/dots/registry.vit"
OUT="$ROOT/completions"
SCHEMA="1.1.0"

mkdir -p "$OUT"

python3 - "$REG" "$OUT" "$SCHEMA" <<'PY'
import json
import re
import sys
from pathlib import Path

reg = Path(sys.argv[1]).read_text(encoding="utf-8")
out_dir = Path(sys.argv[2])
schema = sys.argv[3]

q = re.compile(r'"([^"]+)"')

def split_top_level_args(arg_str: str):
    out = []
    cur = []
    in_quote = False
    depth = 0
    i = 0
    while i < len(arg_str):
        ch = arg_str[i]
        if ch == '"' and (i == 0 or arg_str[i - 1] != "\\"):
            in_quote = not in_quote
            cur.append(ch)
        elif not in_quote and ch == '[':
            depth += 1
            cur.append(ch)
        elif not in_quote and ch == ']':
            depth -= 1
            cur.append(ch)
        elif not in_quote and depth == 0 and ch == ',':
            out.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)
        i += 1
    if cur:
        out.append("".join(cur).strip())
    return out

cmds = []
for line in reg.splitlines():
    if 'CommandDef("' not in line:
        continue
    start = line.find("CommandDef(")
    end = line.rfind(")")
    if start < 0 or end < 0 or end <= start:
        continue
    inside = line[start + len("CommandDef("):end]
    args = split_top_level_args(inside)
    if len(args) < 7:
        continue
    name_m = re.match(r'^"([^"]+)"$', args[0])
    if not name_m:
        continue
    name = name_m.group(1)
    aliases = q.findall(args[1])
    options = q.findall(args[5])
    cmds.append({"name": name, "aliases": aliases, "options": options})

if not cmds:
    raise SystemExit("no commands parsed from registry.vit")

cmd_names = [c["name"] for c in cmds]
alias_names = sorted({a for c in cmds for a in c["aliases"]})
global_opts = [
    "--config", "--cwd", "--json", "--quiet", "--verbose", "--trace",
    "--timeout-ms", "--profile", "--color", "--no-color", "--yes",
    "--force", "--dry-run", "--include",
]
cmd_opts = {c["name"]: c["options"] for c in cmds}

bash = f"""# completion_schema_version={schema}

_dots_bench_names() {{
  local root="${{DOTS_COMPLETION_ROOT:-.}}"
  if [ -d "$root/bench" ]; then
    ls "$root/bench"/*.dotS 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\\.dotS$//'
  fi
}}

_dots_symbol_names() {{
  local root="${{DOTS_COMPLETION_ROOT:-.}}"
  if command -v rg >/dev/null 2>&1; then
    rg -n '^(proc|form|space)\\s+[A-Za-z0-9_/]+' "$root" -g '*.dotS' -g '*.vit' 2>/dev/null | sed -E 's/.*(proc|form|space)\\s+([A-Za-z0-9_\\/]+).*/\\2/' | sort -u | head -n 200
  fi
}}

_dots_profile_names() {{
  local f=".dots/config.v2.conf"
  [ -f "$f" ] || return 0
  grep -E '^profile\\.' "$f" 2>/dev/null | sed -E 's/^profile\\.([^=]+)=.*/\\1/'
}}

_dots_plugins_names() {{
  if command -v dots >/dev/null 2>&1; then
    dots plugins list 2>/dev/null | awk '{{print $1}}'
  fi
}}

_dots_flag_values() {{
  local flag="$1"
  case "$flag" in
    --color) echo "auto always never" ;;
    --tag) echo "latest next" ;;
    --kind) echo "fn module type" ;;
    --bench) _dots_bench_names ;;
    --entry) _dots_symbol_names ;;
    --profile) _dots_profile_names ;;
    --format)
      case "$_dots_cmd" in
        lint) echo "stylish json sarif" ;;
        doc) echo "md html json" ;;
        graph) echo "mermaid dot json" ;;
        *) echo "json table prom csv jsonl md html sarif dot mermaid" ;;
      esac
      ;;
    --output)
      case "$_dots_cmd" in
        benchmark) echo "jsonl csv prom" ;;
        profile) compgen -f -- "$cur"; return ;;
        *) echo "json table" ;;
      esac
      ;;
    --mode) echo "smoke quick stress nightly" ;;
    --compare) echo "baseline last" ;;
    --config|--env-file) compgen -f -- "$cur"; return ;;
    --out-dir|--cwd) compgen -d -- "$cur"; return ;;
  esac
}}

_dots_resolve_alias() {{
  case "$1" in
    b) echo "build" ;;
    t) echo "test" ;;
    r) echo "run" ;;
    fmt) echo "fmt" ;;
    lint) echo "lint" ;;
    *) echo "$1" ;;
  esac
}}

_dots_complete(){{
  local cur prev words cword
  COMPREPLY=()
  _get_comp_words_by_ref -n : cur prev words cword

  for w in "${{words[@]}}"; do
    [[ "$w" == "--" ]] && return 0
  done

  local first_non_flag=""
  for ((i=1;i<${{#words[@]}};i++)); do
    if [[ "${{words[i]}}" != -* ]]; then
      first_non_flag="${{words[i]}}"
      break
    fi
  done

  if [[ -z "$first_non_flag" ]]; then
    COMPREPLY=( $(compgen -W "{' '.join(cmd_names)} {' '.join(alias_names)}" -- "$cur") )
    return 0
  fi

  _dots_cmd="$(_dots_resolve_alias "$first_non_flag")"

  if [[ "$cur" == *=* && "$cur" == --* ]]; then
    local k="${{cur%%=*}}"
    local v="${{cur#*=}}"
    local vals="$(_dots_flag_values "$k")"
    COMPREPLY=( $(compgen -W "$vals" -- "$v" | sed "s#^#$k=#") )
    return 0
  fi

  case "$prev" in
    --color|--tag|--kind|--bench|--entry|--profile|--format|--output|--mode|--compare|--config|--env-file|--out-dir|--cwd)
      COMPREPLY=( $(compgen -W "$(_dots_flag_values "$prev")" -- "$cur") )
      return 0
      ;;
    plugins)
      COMPREPLY=( $(compgen -W "list install remove $(_dots_plugins_names)" -- "$cur") )
      return 0
      ;;
  esac

  local cmd_opts=""
  case "$_dots_cmd" in
"""

for name in cmd_names:
    opts = " ".join(cmd_opts.get(name, []))
    if opts:
        bash += f'    {name}) cmd_opts="{opts}" ;;\n'
bash += f"""  esac

  if [[ "$cur" == --* ]]; then
    COMPREPLY=( $(compgen -W "{' '.join(global_opts)} $cmd_opts" -- "$cur") )
    return 0
  fi

  if [[ "$_dots_cmd" == "plugins" ]]; then
    COMPREPLY=( $(compgen -W "list install remove $(_dots_plugins_names)" -- "$cur") )
    return 0
  fi
  if [[ "$_dots_cmd" == "registry" ]]; then
    COMPREPLY=( $(compgen -W "status reset" -- "$cur") )
    return 0
  fi
  if [[ "$_dots_cmd" == "completion" ]]; then
    COMPREPLY=( $(compgen -W "bash zsh fish validate registry-json" -- "$cur") )
    return 0
  fi
}}
complete -F _dots_complete dots
"""

zsh = f"""#compdef dots
# completion_schema_version={schema}

_dots_bench_names() {{
  local root="${{DOTS_COMPLETION_ROOT:-.}}"
  if [[ -d "$root/bench" ]]; then
    local -a out
    out=(${{root}}/bench/*.dotS(N:t:r))
    print -l -- $out
  fi
}}

_dots_profiles() {{
  local f=".dots/config.v2.conf"
  [[ -f "$f" ]] || return 0
  sed -n 's/^profile\\.\\([^=]*\\)=.*/\\1/p' "$f"
}}

_dots_symbols() {{
  local root="${{DOTS_COMPLETION_ROOT:-.}}"
  if (( $+commands[rg] )); then
    rg -n '^(proc|form|space)\\s+[A-Za-z0-9_/]+' "$root" -g '*.dotS' -g '*.vit' 2>/dev/null | sed -E 's/.*(proc|form|space)\\s+([A-Za-z0-9_\\/]+).*/\\2/' | sort -u | head -n 200
  fi
}}

local -a cmds aliases
cmds=({' '.join(cmd_names)})
aliases=({' '.join(alias_names)})

_arguments -C \\
  '*--help[show help]' \\
  '*--json[machine output]' \\
  '*--color[output color]:mode:(auto always never)' \\
  '*--config[config file]:file:_files' \\
  '*--cwd[working directory]:dir:_files -/' \\
  '*--profile[profile name]:profile:->profiles' \\
  '1:command:->command' \\
  '*::args:->args'

case $state in
  command) _describe -t commands "dots commands" cmds aliases; return ;;
  profiles) _describe -t profiles "profiles" "$(_dots_profiles)"; return ;;
  args)
    local cmd="${{words[2]}}"
    case "$cmd" in
      completion) _values 'completion mode' bash zsh fish validate registry-json ;;
      registry) _values 'registry op' status reset ;;
      benchmark) _arguments '*--bench[bench name]:bench:->bench' '*--mode[benchmark mode]:mode:(smoke quick stress nightly)' '*--output[output format]:fmt:(jsonl csv prom)' ;;
      search) _arguments '*--kind[symbol kind]:kind:(fn module type)' ;;
      run) _arguments '*--entry[entry symbol]:symbol:->symbols' '*--env-file[env file]:file:_files' ;;
      publish) _arguments '*--tag[publish tag]:tag:(latest next)' ;;
      lint) _arguments '*--format[lint format]:fmt:(stylish json sarif)' ;;
      graph) _arguments '*--format[graph format]:fmt:(mermaid dot json)' ;;
      doc) _arguments '*--format[doc format]:fmt:(md html json)' ;;
    esac
    ;;
  bench) _describe -t bench "bench names" "$(_dots_bench_names)" ;;
  symbols) _describe -t symbols "symbols" "$(_dots_symbols)" ;;
esac
"""

fish_lines = [
    f"# completion_schema_version={schema}",
    "",
    "function __dots_bench_names",
    "  if test -d bench",
    "    for f in bench/*.dotS",
    "      if test -f $f",
    "        basename $f .dotS",
    "      end",
    "    end",
    "  end",
    "end",
    "",
    "function __dots_symbol_names",
    "  if type -q rg",
    "    rg -n '^(proc|form|space)\\s+[A-Za-z0-9_/]+' . -g '*.dotS' -g '*.vit' 2>/dev/null | sed -E 's/.*(proc|form|space)\\s+([A-Za-z0-9_\\/]+).*/\\2/' | sort -u | head -n 200",
    "  end",
    "end",
    "",
    "function __dots_profiles",
    "  if test -f .dots/config.v2.conf",
    "    sed -n 's/^profile\\.\\([^=]*\\)=.*/\\1/p' .dots/config.v2.conf",
    "  end",
    "end",
    "",
]
for c in cmd_names + alias_names:
    fish_lines.append(f"complete -c dots -f -a '{c}'")
for g in global_opts:
    fish_lines.append(f"complete -c dots -l {g[2:]}")
fish_lines += [
    "complete -c dots -n '__fish_seen_subcommand_from completion' -a 'bash zsh fish validate registry-json'",
    "complete -c dots -n '__fish_seen_subcommand_from registry' -a 'status reset'",
    "complete -c dots -n '__fish_seen_subcommand_from publish' -l tag -a 'latest next'",
    "complete -c dots -n '__fish_seen_subcommand_from benchmark' -l mode -a 'smoke quick stress nightly'",
    "complete -c dots -n '__fish_seen_subcommand_from benchmark' -l output -a 'jsonl csv prom'",
    "complete -c dots -n '__fish_seen_subcommand_from benchmark' -l bench -a '(__dots_bench_names)'",
    "complete -c dots -n '__fish_seen_subcommand_from run' -l entry -a '(__dots_symbol_names)'",
    "complete -c dots -n '__fish_seen_subcommand_from run' -l env-file -F",
    "complete -c dots -n '__fish_seen_subcommand_from search' -l kind -a 'fn module type'",
    "complete -c dots -n '__fish_seen_subcommand_from lint' -l format -a 'stylish json sarif'",
    "complete -c dots -n '__fish_seen_subcommand_from doc' -l format -a 'md html json'",
    "complete -c dots -n '__fish_seen_subcommand_from graph' -l format -a 'mermaid dot json'",
    "complete -c dots -l color -a 'auto always never'",
    "complete -c dots -l profile -a '(__dots_profiles)'",
    "complete -c dots -l config -F",
    "complete -c dots -l cwd -a '(__fish_complete_directories)'",
]
fish = "\n".join(fish_lines) + "\n"

(out_dir / "dots.bash").write_text(bash, encoding="utf-8")
(out_dir / "_dots").write_text(zsh, encoding="utf-8")
(out_dir / "dots.fish").write_text(fish, encoding="utf-8")
(out_dir / "registry.json").write_text(
    json.dumps(
        {
            "completion_schema_version": schema,
            "source": "cmd/dots/registry.vit",
            "commands": cmds,
        },
        ensure_ascii=True,
        indent=2,
    )
    + "\n",
    encoding="utf-8",
)

print(f"generated completions in {out_dir} from {Path(sys.argv[1])} (schema {schema})")
PY
