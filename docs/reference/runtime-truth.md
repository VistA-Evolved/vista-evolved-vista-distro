# Runtime truth

- **Local VistA** runtime (e.g. `docker/local-vista`) is the reference for RPC, SSH terminal, and health checks.
- **Readiness levels:** See `docs/reference/runtime-readiness-levels.md`. Verification script: `scripts/verify/healthcheck-local-vista.ps1` (use `-ValidatePathsOnly` for path validation without Docker).
- **No Docker build** in bootstrap stage. When implemented, build from upstream + overlay; see ADR-0002.
