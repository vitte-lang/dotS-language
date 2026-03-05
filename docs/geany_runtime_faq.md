# Geany Runtime FAQ

## Why source of truth under editor/geany?
To avoid config drift across `filedefs`, `tools/geany`, and project profiles.

## How to refresh generated legacy files?
Run:

```bash
bash scripts/geany_sync_runtime_profile.sh
```

## How to fully validate before commit?
Run:

```bash
bash scripts/ci_geany_assets_gate.sh
```
