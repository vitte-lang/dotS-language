# ADR 0002: FFI Protocol And Error Model

## Status

Accepted

## Context

Le path FFI avait un parsing JSON fragile par découpe de chaînes et un modèle d’erreurs non homogène entre transports backend.

## Decision

1. Introduire un parser protocole runtime unique via `ffi/protocol.vit` + binaire `dots-ffi-protocol`.
2. Séparer:
   - `protocol_schema_version` (protocole transport)
   - `FFI_SCHEMA_VERSION` (sortie CLI/FFI).
3. Forcer compatibilité version par matrice min/max.
4. Rendre `count` obligatoire en succès.
5. Uniformiser erreurs transport via `ffi/errors.vit`.
6. Catégories d’erreur explicites:
   - `parse_error`
   - `protocol_error`.
7. Enrichir transport avec:
   - `request_deadline_ms`
   - `cancel_token`.

## Consequences

- Contrat backend plus strict et testable.
- Fail-fast sur payload incomplet/mal typé.
- Meilleure observabilité (metrics + calls JSONL + events).
- Migration requise pour backends qui ne respectent pas encore le protocole strict.

## Follow-up

- Implémenter `dots-ffi-protocol` natif côté runtime.
- Ajouter tests e2e process-race sur lock/refcount.
- Ajouter contract tests JSON en CI sur toutes commandes FFI.
