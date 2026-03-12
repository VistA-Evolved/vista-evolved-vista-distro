# Agent and developer onboarding — VistA Distro

- **Upstream first:** See docs/reference/upstream-source-strategy.md and docs/adrs/ADR-0001-upstream-overlay-policy.md. Do not fetch upstream in bootstrap; use scripts when ready.
- **Overlay only:** Customizations go in overlay/ (routines, install, patches). No editing of upstream copy.
- **Local-source-first builds:** See ADR-0002. Build from local upstream + overlay; no Docker build in bootstrap stage.
- **Runtime truth:** See docs/reference/runtime-truth.md. Verification and proof scripts go in scripts/verify/.
