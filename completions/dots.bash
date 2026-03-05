# completion_schema_version=1.1.0

_dots_bench_names() {
  local root="${DOTS_COMPLETION_ROOT:-.}"
  if [ -d "$root/bench" ]; then
    ls "$root/bench"/*.dotS 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.dotS$//'
  fi
}

_dots_symbol_names() {
  local root="${DOTS_COMPLETION_ROOT:-.}"
  if command -v rg >/dev/null 2>&1; then
    rg -n '^(proc|form|space)\s+[A-Za-z0-9_/]+' "$root" -g '*.dotS' -g '*.vit' 2>/dev/null | sed -E 's/.*(proc|form|space)\s+([A-Za-z0-9_\/]+).*/\2/' | sort -u | head -n 200
  fi
}

_dots_profile_names() {
  local f=".dots/config.v2.conf"
  [ -f "$f" ] || return 0
  grep -E '^profile\.' "$f" 2>/dev/null | sed -E 's/^profile\.([^=]+)=.*/\1/'
}

_dots_plugins_names() {
  if command -v dots >/dev/null 2>&1; then
    dots plugins list 2>/dev/null | awk '{print $1}'
  fi
}

_dots_flag_values() {
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
}

_dots_resolve_alias() {
  case "$1" in
    b) echo "build" ;;
    t) echo "test" ;;
    r) echo "run" ;;
    fmt) echo "fmt" ;;
    lint) echo "lint" ;;
    *) echo "$1" ;;
  esac
}

_dots_complete(){
  local cur prev words cword
  COMPREPLY=()
  _get_comp_words_by_ref -n : cur prev words cword

  for w in "${words[@]}"; do
    [[ "$w" == "--" ]] && return 0
  done

  local first_non_flag=""
  for ((i=1;i<${#words[@]};i++)); do
    if [[ "${words[i]}" != -* ]]; then
      first_non_flag="${words[i]}"
      break
    fi
  done

  if [[ -z "$first_non_flag" ]]; then
    COMPREPLY=( $(compgen -W "help version completion cache doctor fmt lint check run eval build test benchmark profile graph doc search init install uninstall update publish package lock clean config repl debug lsp runtime plugins registry ffi verify status whoami login logout self b h r t v" -- "$cur") )
    return 0
  fi

  _dots_cmd="$(_dots_resolve_alias "$first_non_flag")"

  if [[ "$cur" == *=* && "$cur" == --* ]]; then
    local k="${cur%%=*}"
    local v="${cur#*=}"
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
    version) cmd_opts="--short --json" ;;
    cache) cmd_opts="--max-size --max-age-ms --json" ;;
    doctor) cmd_opts="--fix --registry --lsp --network-timeout-ms --json" ;;
    fmt) cmd_opts="--check --write --stdin --diff --json" ;;
    lint) cmd_opts="--fix --rule --exclude-rule --format" ;;
    run) cmd_opts="--watch --env-file --entry --args" ;;
    eval) cmd_opts="--expr --json" ;;
    build) cmd_opts="--target --release --debug --out-dir --emit --strip --dry-run --no-cache --json" ;;
    test) cmd_opts="--filter --shuffle --seed --update-snapshots --junit" ;;
    benchmark) cmd_opts="--mode --bench --output --compare --fail-on-regression" ;;
    profile) cmd_opts="--cpu --mem --flamegraph --output" ;;
    graph) cmd_opts="--format --focus --reverse --cycles --depth" ;;
    doc) cmd_opts="--format --private --open --json" ;;
    search) cmd_opts="--kind --fuzzy --rebuild --json" ;;
    init) cmd_opts="--template --name --org --license" ;;
    install) cmd_opts="--global --local --locked --offline --mirror --retries --jitter-ms --cb-threshold --dry-run --json" ;;
    uninstall) cmd_opts="--global --local" ;;
    update) cmd_opts="--all --interactive --offline --mirror --retries --jitter-ms --cb-threshold --dry-run --json" ;;
    publish) cmd_opts="--dry-run --tag --offline --mirror --retries --jitter-ms --cb-threshold --json" ;;
    lock) cmd_opts="--strict --out --json" ;;
    clean) cmd_opts="--all --target --dry-run" ;;
    config) cmd_opts="--global --project --json" ;;
    repl) cmd_opts="--history-file --load" ;;
    debug) cmd_opts="--breakpoint --attach" ;;
    lsp) cmd_opts="--stdio --json --prom" ;;
    runtime) cmd_opts="--json --prom --table --fix --strict --lines" ;;
    registry) cmd_opts="--json --prom --safe --fix --strict --follow --lines --component --severity --since-ms --until-ms" ;;
    ffi) cmd_opts="--json --prom --follow --lines" ;;
  esac

  if [[ "$cur" == --* ]]; then
    COMPREPLY=( $(compgen -W "--config --cwd --json --quiet --verbose --trace --timeout-ms --profile --color --no-color --yes --force --dry-run --include $cmd_opts" -- "$cur") )
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
}
complete -F _dots_complete dots
