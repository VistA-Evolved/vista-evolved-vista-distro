# ADR-0001: Upstream-overlay policy

> **Enterprise ID:** VE-DISTRO-ADR-0001

## Status

Accepted.

## Context

We need a clear separation between pristine upstream VistA sources and our customizations so we can refresh upstream and re-apply our changes.

## Decision

- **upstream/** — Fetched and pinned by scripts. Read-only; no edits. Lock file records commit SHAs.
- **overlay/** — routines, install, patches. All customizations live here. Applied on top of upstream for build/runtime.
- Upstream is never modified in place. To change behavior, add or adjust overlay and re-run build/install.

## Consequences

- Clean refresh of upstream is possible. Overlay must be idempotent and well-documented.
