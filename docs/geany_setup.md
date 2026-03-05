# Geany Setup (Linux)

## Quickstart 30s
```bash
bash scripts/install_geany_dots.sh
bash scripts/geany_sync_project.sh
bash scripts/geany_doctor.sh
geany editor/geany/profiles/dotS-language.geany
```

## Installed files
- `~/.config/geany/filedefs/filetypes.DOTS.conf`
- `~/.config/geany/filedefs/filetypes.VIT.conf`
- `~/.config/geany/geany.conf`
- `~/.config/geany/keybindings.conf`
- `~/.config/geany/plugins/geanylsp.conf`
- templates in `~/.config/geany/filedefs/templates/files/`

## Build tools
- Lint/Fmt/Run/Check
- Run selection via eval
- Generate completions / completion gate
- Real protocol gate
- Startup bench budget
- Fake registry e2e subset
- Bench quick/stress
- CLI healthcheck

## Profiles
- `editor/geany/profiles/dotS-language.geany`
- `editor/geany/profiles/dotS-language.strict-dev.geany`
- `editor/geany/profiles/dotS-language.perf.geany`
- `editor/geany/profiles/dotS-language.docs.geany`
- `editor/geany/profiles/dotS-language.runtime.geany`
- `editor/geany/profiles/dotS-language.strict-runtime.geany`

## Uninstall / rollback
```bash
bash scripts/uninstall_geany_dots.sh
```

See also:
- `docs/geany_troubleshooting.md`
- `docs/geany_faq.md`
- `docs/geany_security_performance.md`
