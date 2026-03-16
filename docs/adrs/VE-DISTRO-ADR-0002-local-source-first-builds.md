# VE-DISTRO-ADR-0002: Local-source-first builds

> **Legacy ID:** ADR-0002 (compatibility reference only)

## Status

Accepted.

## Context

Builds should be reproducible from local sources (upstream + overlay), not from ad-hoc downloads or unversioned assets.

## Decision

- Build from **local** upstream (cloned/pinned) + **overlay**. No Docker build in bootstrap stage; when implemented, Docker/build scripts consume upstream/ and overlay/ only.
- Fetch and pin are separate steps; lock file is the contract for what version of upstream is used.

## Consequences

- Reproducible builds. No fetch at build time by default; optional refresh step updates upstream and lock file.
