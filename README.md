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

No Docker build yet. No WorldVistA fetch yet. See docs/reference/upstream-source-strategy.md and docs/adrs/.
