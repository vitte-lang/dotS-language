# FFI Runbook

## Pré-requis

- Runtime DotS disponible.
- Binaire optionnel d’exécution native: `dots-ffi-call`.
- Binaire parser protocole: `dots-ffi-protocol` (ou `DOTS_FFI_PROTOCOL_BIN`).
- Dossier projet avec permissions d’écriture sur `.dots/state/ffi`.

## Flux standard

1. Load: `ffi_load_library`
2. Resolve: `ffi_resolve_symbol`
3. Call: `ffi_call`
4. Unload: `ffi_unload`

Ou en une passe:

- `ffi_sequence_load_resolve_call_unload`

## Mode strict ABI

```bash
export DOTS_FFI_STRICT=1
export DOTS_FFI_EXPECT_ARCH=x86_64
export DOTS_FFI_EXPECT_ENDIAN=little
```

## Mode backend

```bash
export DOTS_FFI_MODE=fake   # CI/tests déterministes
# ou
export DOTS_FFI_MODE=real   # backends natifs
```

## Timeout / retry / CB

```bash
export DOTS_FFI_TIMEOUT_MS=2000
export DOTS_FFI_RETRIES=2
export DOTS_FFI_RETRY_BUDGET=4
export DOTS_FFI_JITTER_POLICY=equal
export DOTS_FFI_CB_THRESHOLD=3
export DOTS_FFI_CB_COOLDOWN_MS=1000
export DOTS_FFI_LOAD_TIMEOUT_MS=1000
export DOTS_FFI_RESOLVE_TIMEOUT_MS=1000
export DOTS_FFI_CALL_TIMEOUT_MS=2000
export DOTS_FFI_OVERALL_TIMEOUT_MS=5000
```

## Sécurité path/allowlist

```bash
export DOTS_FFI_ALLOW_DIRS=/opt/dots/lib,/home/me/project/lib
export DOTS_FFI_ALLOWLIST_FILE=.dots/ffi_allowlist.txt
```

Format allowlist recommandé:

`/abs/path/libx.so|<sha256>|<sig>`

## Inspecter l’état

- Status table/json: `ffi_status_print_table` / `ffi_status_print_json`
- Doctor table/json: `ffi_doctor_print_table` / `ffi_doctor_print_json`
- Events: `.dots/state/ffi/events.jsonl`
- Metrics: `.dots/state/ffi/stats.v2.jsonl`

Via CLI:

- `dots ffi doctor --json`
- `dots ffi status --json`
- `dots ffi status --prom`
- `dots ffi events --lines 50 --follow`
- `dots ffi reset`

## Incident quick triage

1. `FFI_ERROR`:
   - vérifier chemin, extension, permissions.
2. `SYMBOL_NOT_FOUND`:
   - vérifier nom export + ABI.
3. `ABI_MISMATCH`:
   - vérifier signature/arity/types + mode strict.
4. `CALL_FAILED`:
   - vérifier backend runtime (`dots-ffi-call`), logs redacted.
5. `TIMEOUT`:
   - augmenter `DOTS_FFI_TIMEOUT_MS`, réduire retries.

## Nettoyage contrôlé

- Supprimer seulement `.dots/state/ffi/*` si corruption.
- Conserver un backup des events avant purge.
