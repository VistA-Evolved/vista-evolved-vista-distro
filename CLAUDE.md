# Claude Code Instructions — VistA Evolved Distro

## Root law

Read `/AGENTS.md` before any task. It is the canonical cross-tool governance file.

> **Multi-root workspace:** `/AGENTS.md` means this repo's AGENTS.md, not a sibling repo's.
> The archive repo's AGENTS.md is reference material only — it does not govern this repo.

## Key rules

1. **Upstream is read-only.** Never modify files under `upstream/`. All customizations go in `overlay/`.
2. **Runtime truth.** Verify against the live Docker container. See `docs/reference/runtime-truth.md`.
3. **No documentation sprawl.** Only: tutorials, how-to, reference, explanation, adrs, runbooks under `/docs`. Evidence in `/artifacts`.
4. **No silent mocks.** Return explicit `integration-pending` when infrastructure is unavailable.
5. **One slice at a time.** Verify each slice before starting the next.
6. **Proof required.** Every task must report: files changed, commands run, outputs, pass/fail.
7. **ADRs are enterprise-namespaced.** `VE-DISTRO-ADR-NNNN` for this repo. Register in `docs/reference/decision-index.yaml`.

## Key references

| What | Where |
|------|-------|
| Source of truth index | `docs/reference/source-of-truth-index.md` |
| Doc governance | `docs/reference/doc-governance.md` |
| Upstream source strategy | `docs/reference/upstream-source-strategy.md` |
| Runtime truth | `docs/reference/runtime-truth.md` |
| Decision index | `docs/reference/decision-index.yaml` |
| Customization policy | `docs/reference/customization-policy.md` |

## Task response format

Every task must end with: Objective, Files inspected, Files changed, Commands run, Results, Verified truth, Unverified areas, Risks, Next step.
