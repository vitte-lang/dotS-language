# FFI Security

## Threat Model

- Chargement de librairies non fiables.
- Traversal de chemin (`../`) pour sortir du workspace.
- Exfiltration secrets via logs/errors.
- Payloads volumineux causant saturation mémoire/logs.
- Boucles de retry non bornées.

## Controls in place

- Path hardening:
  - `secure_join` + normalisation.
  - blocage chemins hors `DOTS_FFI_ALLOW_DIRS`.
- Extension allowlist:
  - `.so`, `.dylib`, `.dll`, `.wasm`.
- Manifest allowlist:
  - `.dots/ffi_allowlist.txt` (ou `DOTS_FFI_ALLOWLIST_FILE`).
- Strict ABI mode:
  - `DOTS_FFI_STRICT=1`, checks arch/endian.
- Typed errors:
  - `error_type`, `error_message`, `error_category`, `retryable`, `retry_after_ms`.
- Protocol strict mode:
  - `DOTS_FFI_PROTOCOL_STRICT=1` (unknown fields rejected by parser backend).
- Redaction:
  - token/password/secret/bearer/apikey/jwt.
- Size limits:
  - `DOTS_FFI_MAX_ARGS_BYTES`, `DOTS_FFI_MAX_OUTPUT_BYTES`.
- Timeouts:
  - load/resolve/call/overall.
- Circuit-breaker + retry budget.
- State integrity:
  - checksum state files.

## Recommended policy

1. For CI: `DOTS_FFI_MODE=fake`.
2. For prod-like tests: `DOTS_FFI_MODE=real` + allowlist stricte.
3. Always enable strict ABI on release validation.
4. Never allow unrestricted absolute paths.
