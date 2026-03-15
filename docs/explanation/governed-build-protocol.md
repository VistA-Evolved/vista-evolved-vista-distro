# Governed Build Protocol — VistA Evolved Distro

> How work gets done in this repo: one slice at a time, with proof.

---

## Principles

1. **One slice at a time.** Complete verification and human review before the next slice.
2. **Proof required.** Every completed slice must include: files changed, commands run, outputs, pass/fail.
3. **Runtime truth.** Verify against the live Docker container. "Looks correct" is not proof.
4. **Stop and report.** After each slice, produce a completion report and stop. Do not proceed until instructed.

---

## Slice workflow

1. **Inventory** — List files to inspect, files to change, and expected outcomes.
2. **Implement** — Minimal edits. Reuse existing patterns.
3. **Verify** — Run against the live Docker container if applicable. Run governance checks.
4. **Report** — Produce a task report (see AGENTS.md Section 5).
5. **Stop** — Wait for human review before the next slice.

---

## Distro-specific verification

- **Build lanes:** UTF-8 (`docker/local-vista-utf8`) is the **primary planned operator lane** (ADR-0003). M-mode (`docker/local-vista`) is the rollback/reference/safety lane.
- **Health checks:** `scripts/verify/healthcheck-local-vista.ps1` and `scripts/verify/healthcheck-local-vista-utf8.ps1`.
- **Lock file:** `locks/worldvista-sources.lock.json` is the contract for reproducible builds.
- **Overlay:** All customizations in `overlay/`. Never modify `upstream/`.
