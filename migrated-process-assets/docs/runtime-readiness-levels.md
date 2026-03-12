# Runtime readiness levels

> **Five levels of readiness for the local VistA Docker lane.** COPIED FROM ARCHIVE. Normalize into docs/reference/ or docs/runbooks/ when implementing runtime.

## Levels

1. **CONTAINER_STARTED** — Container exists and status contains "Up".
2. **NETWORK_REACHABLE** — Both RPC and SSH ports accept TCP from host.
3. **SERVICE_READY** — Docker health status = healthy.
4. **TERMINAL_READY** — SSH port accepts connection.
5. **RPC_READY** — RPC broker port accepts connection.

See archive `docs/canonical/runtime/runtime-proof-checklist.md`, `stage4-execution-report.md`, and `scripts/runtime/healthcheck-local-vista.ps1` for exact checks and outputs.
