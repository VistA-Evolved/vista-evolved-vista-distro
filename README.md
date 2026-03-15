# VistA Evolved — VistA Distro

Upstream fetch/pin, overlay (routines, install, patches), and local VistA runtime (docker, scripts). No platform app code.

## Layout

- **upstream/** — Cloned/pinned upstream VistA sources (populated by scripts).
- **overlay/** — routines, install, patches applied on top of upstream.
- **docker/** — local-vista and related compose.
- **scripts/** — fetch, pin, build, verify.
- **docs/** — tutorials, how-to, reference, explanation, ADRs, runbooks.
- **artifacts/** — Build and verification outputs.

## Bootstrapped

- Docker build completed for the local M-mode reference lane. See `docker/local-vista/` and `docs/reference/runtime-truth.md`.
- Browser terminal proof completed for the current M-mode operator lane. See `docs/runbooks/phase2-terminal-proof-report.md`.
- UTF-8 is not yet a verified runtime lane. Treat it as a separate follow-up build slice, not a shell-only tweak.
- See `docs/reference/upstream-source-strategy.md` and `docs/adrs/` for upstream and overlay rules.
