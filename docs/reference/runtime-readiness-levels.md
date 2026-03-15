# Runtime readiness levels

Five levels of readiness for the local VistA Docker lane. Each level has a clear pass/fail check. No guessing.

| Level | Meaning | Check |
|-------|---------|--------|
| **CONTAINER_STARTED** | Container exists and status contains "Up" | `docker ps -a --filter name=local-vista --format "{{.Status}}"` |
| **NETWORK_REACHABLE** | Both RPC and SSH ports accept TCP from host | TCP connect to 127.0.0.1:RPC_PORT and 127.0.0.1:SSH_PORT |
| **SERVICE_READY** | Docker health status = healthy | `docker inspect` Health.Status |
| **TERMINAL_READY** | SSH port accepts connection | TCP to SSH port |
| **RPC_READY** | RPC broker port accepts connection | TCP to RPC port |

Default ports: RPC 9433, SSH 2225. Override with `LOCAL_VISTA_PORT` and `LOCAL_VISTA_SSH_PORT` or script parameters.

**Script:** `scripts/verify/healthcheck-local-vista.ps1` — runs all five levels and exits 0 only if all pass. Use `-ValidatePathsOnly` to verify script paths without calling Docker.
