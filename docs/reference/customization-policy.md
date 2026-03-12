# Customization policy

- **All customizations** go in `overlay/`: routines, install scripts, patches. Do not modify the upstream copy.
- **Patches** are applied in a defined order; document dependencies. Re-applying overlay on a fresh upstream must be idempotent where possible.
- **Install scripts** register RPCs, contexts, and seed data; they must not destroy existing data (no KILL of shared globals without append-only strategy).
