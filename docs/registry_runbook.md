# Registry Runbook

## Modes
- `DOTS_REGISTRY_MODE=fake`: backend local deterministic (`.dots/fake_registry` by default)
- `DOTS_REGISTRY_MODE=real`: client runtime natif (binaire `dots-registry` par defaut)

## Fake registry init
```bash
scripts/fake_registry.sh init .dots/e2e-reg
scripts/fake_registry.sh add-pkg .dots/e2e-reg demo 1.0.0
```

## Install/update/publish with fake backend
```bash
DOTS_REGISTRY_MODE=fake DOTS_REGISTRY_DIR=.dots/e2e-reg dots install --json demo
DOTS_REGISTRY_MODE=fake DOTS_REGISTRY_DIR=.dots/e2e-reg dots update --json
DOTS_REGISTRY_MODE=fake DOTS_REGISTRY_DIR=.dots/e2e-reg DOTS_PUBLISH_SKIP_GIT=1 dots publish --json --tag next
```

## Registry status/reset
```bash
dots registry status --json
dots registry status --prom
dots registry reset --json
dots registry reset --safe --json
dots registry doctor --json --fix
dots registry events --json --lines 50 --component core
```

## Real mode
```bash
DOTS_REGISTRY_MODE=real DOTS_REGISTRY_REAL_BIN=dots-registry dots update --json
```

### Real mode stub (tests deterministes)
```bash
DOTS_REGISTRY_MODE=real DOTS_REGISTRY_REAL_STUB=1 DOTS_REGISTRY_DIR=.dots/e2e-reg dots install --json demo
```

## Real mode protocol (strict)
- Le backend real doit retourner du JSON contractuel avec au minimum:
  - `protocol_version` (`1.1` ou `1.1.0`)
  - `value`, `count`, `endpoint` en succes
  - `error_type`, `error_message`, `error_category` en erreur
- Le format legacy `key=value` n'est plus accepte en mode strict.

## Incident: checksum mismatch storm
```bash
dots registry doctor --json
dots registry events --lines 200 --severity warn --component core
dots registry status --prom
dots registry reset --safe --json
```
