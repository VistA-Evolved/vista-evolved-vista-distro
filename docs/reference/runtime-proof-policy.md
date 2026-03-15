# Runtime Proof Policy — VistA Evolved Distro

> What counts as proof that something works. No guessing. No "should work."

---

## Proof requirements

A claim is **proven** when ALL of these are true:

1. **Commands were executed.** The exact commands are listed in the report.
2. **Outputs were captured.** The exact stdout/stderr is included or referenced.
3. **Pass/fail is explicit.** Each check has a clear PASS or FAIL.
4. **Docker was running.** For runtime claims, the Docker container was up and reachable.
5. **No assumptions.** "Looks correct" or "should work" is not proof.

---

## What is NOT proof

- Code compiles → not proof it works at runtime.
- Tests pass in isolation → not proof against the live container.
- "Verified by reading the code" → not proof.
- Model memory says it works → not proof.

---

## Verification artifacts

All verification outputs go in `/artifacts` (gitignored). They are evidence, not documentation.

Approved artifact types:
- Health check outputs (from `scripts/verify/`)
- Build logs (from Docker build)
- Governance check outputs (from `scripts/governance/`)
- Session transcripts and proof screenshots

---

## Runtime verification checklist

For Docker/VistA runtime claims:

| Gate | How to verify |
|------|--------------|
| Container started | `docker ps -a --filter name=<container>` shows "Up" |
| Network reachable | TCP connect to RPC and SSH ports succeeds |
| Service ready | `docker inspect` shows Health.Status = healthy |
| Terminal ready | SSH port accepts connection |
| RPC ready | RPC broker port accepts connection |

See `docs/reference/runtime-readiness-levels.md` for the full 5-level model.

---

## Governance verification

Run all governance checks from repo root:

```bash
bash scripts/governance/check-doc-roots.sh
bash scripts/governance/check-adr-index.sh
bash scripts/governance/check-sot-files.sh
bash scripts/governance/check-artifacts-placement.sh
bash scripts/governance/check-ports.sh
```

All must PASS for a slice to be considered verified.
