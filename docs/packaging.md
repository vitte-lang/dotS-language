# DotS Packaging

Packaging is currently split between:

- `cmd/dots/package`
- `packaging/*`
- `modules/package/*`

Two layers exist:

1. local artifact packaging
2. registry/backend publish/install/update flows

Local artifact packaging:

- `packaging/artifact.vit` builds and verifies a package artifact JSON
- `dots package pack`
- `dots package verify`
- `dots package unpack`

Registry packaging:

- `dots install`
- `dots update`
- `dots publish`
- backend fake/real transport logic under `modules/package/backend`

Minimal artifact fields:

- `schema_version`
- `name`
- `version`
- `license`
- `artifact_path`
- `source_root`
