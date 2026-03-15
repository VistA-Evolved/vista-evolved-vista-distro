# Runtime Truth Governance — VistA Evolved Distro

> How runtime truth is established, maintained, and enforced.

---

## Principles

1. **Docker is the reference environment.** Runtime claims are verified against the live Docker container, not model memory or code inspection.
2. **No silent mocks.** If the Docker container is unavailable, return `integration-pending`. Never silently fake runtime success.
3. **Proof over assumption.** "Looks correct" or "should work" is not proof. See `docs/reference/runtime-proof-policy.md`.

---

## Runtime truth chain

| Layer | Source of truth | Verified by |
|-------|----------------|-------------|
| Upstream sources | `locks/worldvista-sources.lock.json` | `scripts/pin/pin-worldvista-sources.ps1` |
| Overlay applied | `overlay/` directory contents | Docker build log |
| Container running | Docker container status | `scripts/verify/healthcheck-local-vista.ps1` |
| Services reachable | RPC + SSH ports | TCP probes in health check |
| Ports correct | `docs/reference/port-registry.md` | `scripts/governance/check-ports.sh` |

---

## Verification cadence

- **After build:** Run health check to verify container starts and services are reachable.
- **After overlay change:** Rebuild and re-verify.
- **After upstream refresh:** Fetch, pin, rebuild, re-verify.
- **Governance checks:** Run `scripts/governance/check-*.sh` after any docs or config change.

---

## What counts as runtime truth

See `docs/reference/runtime-truth.md` for the current verified state of each build lane.
See `docs/reference/runtime-readiness-levels.md` for the 5-level health check model.
See `docs/reference/runtime-proof-policy.md` for what qualifies as proof.

---

## Contradiction detection

If runtime-truth.md claims a lane is verified but the health check fails, the claim is stale. Update runtime-truth.md to reflect actual state. Never leave a stale claim in place.

---

## Cross-references

| Concern | File |
|---------|------|
| Current runtime state | `docs/reference/runtime-truth.md` |
| Health check model | `docs/reference/runtime-readiness-levels.md` |
| Proof standard | `docs/reference/runtime-proof-policy.md` |
| Port assignments | `docs/reference/port-registry.md` |
| Upstream strategy | `docs/reference/upstream-source-strategy.md` |
