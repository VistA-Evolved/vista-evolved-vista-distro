# VistA Evolved Distro

Upstream fetch/pin, overlay (routines, install, patches), and local VistA runtime (Docker, scripts).

## Quick links

- [Source of Truth Index](reference/source-of-truth-index.md)
- [Runtime Truth](reference/runtime-truth.md)
- [Governed Build Protocol](explanation/governed-build-protocol.md)
- [Decision Records](adrs/index.md)

## Repo layout

| Directory | Purpose |
|-----------|---------|
| `upstream/` | Pinned upstream VistA sources (read-only) |
| `overlay/` | Customizations: routines, install, patches, l10n |
| `docker/` | M-mode and UTF-8 build lanes |
| `scripts/` | Fetch, pin, build, verify, governance |
| `docs/` | Documentation (this site) |
| `artifacts/` | Build and verification outputs (gitignored) |
| `locks/` | Lock files for reproducible builds |
