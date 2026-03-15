# Documentation Governance — VistA Evolved Distro

> Canonical rules for what documentation is allowed, where it lives, and how it is maintained.

---

## Approved categories

All documentation lives under `/docs` in exactly these categories:

| Category | Path | Purpose |
|----------|------|---------|
| **Tutorials** | `docs/tutorials/` | Step-by-step learning paths for new developers/operators |
| **How-to** | `docs/how-to/` | Task-oriented guides (answer "how do I...?") |
| **Reference** | `docs/reference/` | Technical references: policies, registries, indexes |
| **Explanation** | `docs/explanation/` | Architecture rationale, governance, design decisions |
| **ADRs** | `docs/adrs/` | Architecture decision records (enterprise-namespaced) |
| **Runbooks** | `docs/runbooks/` | Operational procedures (build, verify, deploy, troubleshoot) |

---

## Approved paths outside /docs

| Path | Purpose |
|------|---------|
| `/artifacts` | Build and verification outputs (gitignored) |
| `/prompts` | Active prompts and templates |
| `/.github` | Workflows, CODEOWNERS, copilot-instructions |
| `/.cursor` | Cursor rules |
| `/scripts` | Governance checks, fetch/pin/build/verify automation |

---

## Forbidden

- `/reports` or `/docs/reports` — never create these directories.
- Evidence or verification outputs in `/docs` — use `/artifacts`.
- Ad-hoc scratch docs, random audit folders, duplicate summaries.
- Files at `/docs/*.md` that are not `index.md` — use the appropriate subcategory.

---

## Rules

1. **One canonical location per concept.** No duplicate docs covering the same topic.
2. **ADRs must be registered** in `docs/reference/decision-index.yaml` with enterprise namespace `VE-DISTRO-ADR-NNNN`.
3. **Evidence is not documentation.** Verification outputs, build logs, and test results go in `/artifacts` (gitignored).
4. **Runbooks must be testable.** Every runbook should contain commands that can be executed to verify the procedure.
5. **No legacy context dumps.** The `vista_evolved_project_context_master.md` pattern is deprecated. Use structured docs in the appropriate category.
6. **Index files.** Each category should have an `index.md` that describes the category and lists contents.

---

## Enforcement

- CI gate: `scripts/governance/check-doc-roots.sh` fails if unapproved directories exist under `/docs`.
- CI gate: `scripts/governance/check-adr-index.sh` fails if ADR files are not registered in the decision index.
- CI gate: `scripts/governance/check-artifacts-placement.sh` fails if evidence files appear in `/docs`.
