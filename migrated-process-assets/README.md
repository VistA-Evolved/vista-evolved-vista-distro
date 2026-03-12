# Migrated process assets — normalized

Process assets from the archive have been **normalized** into the distro layout. This folder is kept only as a pointer.

- **Fetch/pin/status:** `scripts/fetch/` (fetch-worldvista-sources.ps1, pin-worldvista-sources.ps1, show-worldvista-source-status.ps1, worldvista-sources.config.json)
- **Lock:** `locks/worldvista-sources.lock.json`
- **Verify:** `scripts/verify/healthcheck-local-vista.ps1`
- **Docs:** `docs/reference/upstream-source-strategy.md`, `runtime-truth.md`, `customization-policy.md`, `runtime-readiness-levels.md`

The copied scripts and config in `migrated-process-assets/upstream/`, `migrated-process-assets/runtime/`, and `migrated-process-assets/docs/` are **superseded** by the normalized versions above. They may be removed after verification.
