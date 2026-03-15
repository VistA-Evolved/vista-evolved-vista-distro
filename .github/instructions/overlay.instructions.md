---
applyTo: "overlay/**"
---

# Overlay instructions

Read `/AGENTS.md` first — it is the root law.

## Rules for overlay/

1. **Never modify `upstream/`.** All customizations go in `overlay/`.
2. Subdirectories: `routines/`, `install/`, `patches/`, `l10n/`.
3. Install scripts must be idempotent — no destructive KILL of shared globals.
4. Patches must be documented and re-applicable on fresh upstream.
5. See `docs/reference/customization-policy.md` and ADR-0001.
