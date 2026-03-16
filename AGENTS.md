# Agent and Developer Onboarding — VistA Evolved Distro

> **This file is the cross-tool root law for all AI coding agents and developers.**
> It applies to VS Code, Cursor, Claude Code, GitHub Copilot, ChatGPT, and any other tool.
> Tool-specific instruction files (CLAUDE.md, .cursor/rules/, .github/copilot-instructions.md)
> are thin shims that point back here. If they conflict with this file, this file wins.

> **Multi-root workspace note:** This AGENTS.md governs the `vista-evolved-vista-distro` repo only.
> In a multi-root workspace, each repo has its own AGENTS.md. When you see `/AGENTS.md`
> references in this repo's files, they mean **this file**, not a sibling repo's AGENTS.md.
> The sibling repos (`VistA-Evolved` archive and `vista-evolved-platform`) are self-governing.
> The archive repo's AGENTS.md is **reference material only** — it does not govern this repo.
>
> **Path disambiguation:** In task reports and all operator-facing outputs, use repo-prefixed
> paths (e.g., `vista-evolved-vista-distro/AGENTS.md`) instead of bare paths (e.g., `/AGENTS.md`)
> to eliminate ambiguity when multiple repos are open in the same workspace.

---

## 0. NON-NEGOTIABLE RULES

1. **No uncontrolled feature generation.** Work one slice at a time. Complete verification and human review before the next slice.
2. **No claiming done without proof.** Proof = exact files changed + exact commands run + exact outputs + pass/fail.
3. **No silent mocks or stubs.** If real infrastructure is unavailable, return explicit `integration-pending` state. Never silently fake success.
4. **No next stage without stop-and-report.** After each slice, produce a completion report and stop. Do not proceed until explicitly instructed.
5. **Upstream is read-only.** Never modify files under `upstream/`. All customizations go in `overlay/`. See ADR-0001.
6. **Runtime truth over assumptions.** Verify against the live Docker container, not model memory. See `docs/reference/runtime-truth.md`.
7. **Repo files are the source of truth, not model memory.** Force alignment through files, contracts, CI, and merge gates.
8. **No documentation sprawl.** Only approved doc categories. See `docs/reference/doc-governance.md`.

---

## 1. CORE POLICIES (by reference)

| Policy | Canonical location |
|--------|-------------------|
| Upstream source strategy | `docs/reference/upstream-source-strategy.md` |
| Upstream overlay policy | `docs/adrs/VE-DISTRO-ADR-0001-upstream-overlay-policy.md` |
| Local-source-first builds | `docs/adrs/VE-DISTRO-ADR-0002-local-source-first-builds.md` |
| Runtime truth | `docs/reference/runtime-truth.md` |
| Runtime readiness levels | `docs/reference/runtime-readiness-levels.md` |
| Customization policy | `docs/reference/customization-policy.md` |
| Documentation model | `docs/reference/doc-governance.md` |
| Runtime proof | `docs/reference/runtime-proof-policy.md` |
| Source of truth index | `docs/reference/source-of-truth-index.md` |
| Decision records | `docs/reference/decision-index.yaml`, `docs/adrs/` |
| Build protocol | `docs/explanation/governed-build-protocol.md` |
| Port registry | `docs/reference/port-registry.md` |

---

## 2. DOCUMENTATION MODEL

Approved top-level doc categories under `/docs`:
- **tutorials/** — Step-by-step learning paths
- **how-to/** — Task-oriented guides
- **reference/** — Technical references (policies, registries, indexes)
- **explanation/** — Architecture rationale, governance
- **adrs/** — Architecture decision records (enterprise-namespaced)
- **runbooks/** — Operational procedures

Approved support paths outside `/docs`:
- `/artifacts` — Build and verification outputs (gitignored)
- `/prompts` — Active prompts and templates
- `/.github` — Workflows, CODEOWNERS, instructions
- `/.cursor` — Cursor rules
- `/scripts` — Governance checks, fetch/pin/build/verify automation

**Forbidden:** `/reports`, `/docs/reports`, random audit folders, ad-hoc scratch docs, duplicate summaries. Evidence goes in `/artifacts`, not in `/docs`.

---

## 3. REPO LAYOUT

```
upstream/       — Pinned upstream VistA sources (read-only, populated by scripts)
overlay/        — Customizations: routines, install, patches, l10n
docker/         — Local-vista and UTF-8 build lanes
scripts/        — fetch, pin, build, verify, governance
docs/           — tutorials, how-to, reference, explanation, adrs, runbooks
artifacts/      — Build and verification outputs (gitignored)
locks/          — Lock files (worldvista-sources.lock.json is canonical)
```

---

## 4. KEY BUILD AND VERIFY COMMANDS

```bash
# Fetch upstream (updates lock file)
scripts/fetch/fetch-worldvista-sources.ps1

# Pin upstream SHAs
scripts/pin/pin-worldvista-sources.ps1

# Build M-mode lane
docker build --progress=plain -f docker/local-vista/Dockerfile -t vista-distro:local .

# Build UTF-8 lane
docker build --progress=plain -f docker/local-vista-utf8/Dockerfile -t vista-distro:local-utf8 .

# Health check (M-mode)
scripts/verify/healthcheck-local-vista.ps1

# Health check (UTF-8)
scripts/verify/healthcheck-local-vista-utf8.ps1
```

---

## 5. TASK EXECUTION FORMAT

Every AI task response MUST include:

```
## Task Report
- **Objective:** what was requested
- **Files inspected:** list
- **Files changed:** list
- **Commands run:** list with outputs
- **Results:** pass/fail per step
- **Verified truth:** what was proven
- **Unverified areas:** what remains unproven
- **Risks:** known risks
- **Next step:** what comes next
```

> **Multi-root path rule:** All file paths in task reports must be repo-prefixed
> (e.g., `vista-evolved-vista-distro/docs/adrs/VE-DISTRO-ADR-0001-upstream-overlay-policy.md`)
> to avoid ambiguity when multiple repos are open in the same workspace.

---

## 6. ADR GOVERNANCE

- ADR IDs are enterprise-namespaced: `VE-DISTRO-ADR-NNNN` for this repo.
- All ADRs must be registered in `docs/reference/decision-index.yaml`.
- Cross-repo ADR namespaces: `VE-GOV-` (governance), `VE-ARCH-` (architecture), `VE-PLAT-` (platform), `VE-DISTRO-` (distro).

---

## 7. DISTRO-SPECIFIC RULES

1. **Upstream first:** See `docs/reference/upstream-source-strategy.md`. Do not fetch upstream in bootstrap; use scripts when ready. Lock file is the contract.
2. **Overlay only:** Customizations go in `overlay/` (routines, install, patches, l10n). No editing of upstream copy.
3. **Local-source-first builds:** See ADR-0002. Build from local upstream + overlay; no Docker build in bootstrap stage.
4. **Runtime truth:** See `docs/reference/runtime-truth.md`. Verification and proof scripts go in `scripts/verify/`.
5. **Two build lanes:** UTF-8 (`docker/local-vista-utf8`) is the **primary planned operator lane** (ADR-0003). M-mode (`docker/local-vista`) is the rollback/reference/safety lane. Each has independent health checks.
6. **Ports:** RPC broker 9433, SSH 2225 (M-mode). UTF-8 lane uses separate ports. See `docs/reference/port-registry.md`.
7. **No platform app code in this repo.** This repo is upstream + overlay + Docker + scripts + docs only.
