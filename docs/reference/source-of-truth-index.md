# Source of Truth Index — VistA Evolved Distro

> Master index of what governs what. When in doubt, this file resolves it.
>
> **Multi-root workspace:** When this file references `/AGENTS.md`, it means this repo's
> AGENTS.md. Each repo in the workspace is self-governing. Sibling repos
> (`VistA-Evolved` archive, `vista-evolved-platform`) have their own governance files.

---

## Governance files

| What | Canonical location | Notes |
|------|-------------------|-------|
| Cross-tool root law | `/AGENTS.md` | All AI tools and developers read this first |
| Claude Code instructions | `/CLAUDE.md` | Thin shim → AGENTS.md |
| Copilot instructions | `/.github/copilot-instructions.md` | Thin shim → AGENTS.md |
| Cursor rules | `/.cursor/rules/*.mdc` | Thin shims → AGENTS.md |
| Documentation model | `docs/reference/doc-governance.md` | Approved categories, forbidden paths |
| Runtime truth governance | `docs/reference/runtime-truth-governance.md` | How runtime truth is maintained |
| Build protocol | `docs/explanation/governed-build-protocol.md` | One-slice-at-a-time workflow |
| Code ownership | `/.github/CODEOWNERS` | Bounded contexts |
| Copilot scoped instructions | `/.github/instructions/*.instructions.md` | Path-scoped rules |

---

## Policy files

| What | Canonical location | Notes |
|------|-------------------|-------|
| Upstream source strategy | `docs/reference/upstream-source-strategy.md` | Fetch, pin, lock file contract |
| Runtime truth | `docs/reference/runtime-truth.md` | Docker lanes, ports, readiness |
| Runtime readiness levels | `docs/reference/runtime-readiness-levels.md` | 5-level health check model |
| Customization policy | `docs/reference/customization-policy.md` | Overlay rules, idempotent patches |
| Runtime proof policy | `docs/reference/runtime-proof-policy.md` | What counts as proof |
| Port registry | `docs/reference/port-registry.md` | Assigned ports per lane |

---

## Decision records

| What | Canonical location | Notes |
|------|-------------------|-------|
| Decision index | `docs/reference/decision-index.yaml` | Enterprise-namespaced ADR registry |
| ADR-0001 Upstream overlay | `docs/adrs/VE-DISTRO-ADR-0001-upstream-overlay-policy.md` | VE-DISTRO-ADR-0001 |
| ADR-0002 Local-source builds | `docs/adrs/VE-DISTRO-ADR-0002-local-source-first-builds.md` | VE-DISTRO-ADR-0002 |
| ADR-0003 UTF-8 primary lane | `docs/adrs/VE-DISTRO-ADR-0003-utf8-primary-lane.md` | VE-DISTRO-ADR-0003 |

---

## Lane designation (ADR-0003)

| Lane | Path | Role | Ports |
|------|------|------|-------|
| UTF-8 | `docker/local-vista-utf8` | **Primary planned operator lane** | 9434 (RPC), 2226 (SSH) |
| M-mode | `docker/local-vista` | Rollback/reference/safety lane | 9433 (RPC), 2225 (SSH) |

- English is the baseline language.
- Korean and Spanish are bounded product languages.
- Terminal sign-off under UTF-8 is not yet complete.

---

## Upstream and build

| What | Canonical location | Notes |
|------|-------------------|-------|
| Upstream source config | `scripts/fetch/worldvista-sources.config.json` | Source definitions, local paths |
| Upstream lock file | `locks/worldvista-sources.lock.json` | Pinned SHAs, branch, fetch date |
| Fetch script | `scripts/fetch/fetch-worldvista-sources.ps1` | Clone or fetch upstream |
| Pin script | `scripts/pin/pin-worldvista-sources.ps1` | Record SHAs in lock |
| Status script | `scripts/fetch/show-worldvista-source-status.ps1` | Show lock + upstream contents |
| M-mode Dockerfile | `docker/local-vista/Dockerfile` | M-mode build lane |
| UTF-8 Dockerfile | `docker/local-vista-utf8/Dockerfile` | UTF-8 build lane |

---

## Verification and health

| What | Canonical location | Notes |
|------|-------------------|-------|
| M-mode health check | `scripts/verify/healthcheck-local-vista.ps1` | 5-level readiness check |
| UTF-8 health check | `scripts/verify/healthcheck-local-vista-utf8.ps1` | 5-level readiness check |
| Governance: doc roots | `scripts/governance/check-doc-roots.sh` | CI gate |
| Governance: ADR index | `scripts/governance/check-adr-index.sh` | CI gate |
| Governance: SOT files | `scripts/governance/check-sot-files.sh` | CI gate |
| Governance: artifacts placement | `scripts/governance/check-artifacts-placement.sh` | CI gate |
| Governance: ports | `scripts/governance/check-ports.sh` | CI gate |

---

## Overlay and customizations

| What | Canonical location | Notes |
|------|-------------------|-------|
| Custom routines | `overlay/routines/` | MUMPS routines (ZVE*, XUS*, etc.) |
| Install scripts | `overlay/install/` | RPC registration, context setup |
| Patches | `overlay/patches/` | Applied on top of upstream |
| Language packs | `overlay/l10n/` | Multilingual support (ko, es, etc.) |

---

## Cross-repo references

| Repo | Namespace | Purpose |
|------|-----------|---------|
| vista-evolved-platform | `VE-PLAT-ADR-NNNN` | Control plane, contracts, UI |
| vista-evolved-vista-distro | `VE-DISTRO-ADR-NNNN` | Upstream, overlay, Docker, runtime |
| VistA-Evolved | `VE-GOV-ADR-NNNN` | Legacy monorepo (governance) |
