# ADR-0003: UTF-8 lane is the primary planned operator lane

> **Enterprise ID:** VE-DISTRO-ADR-0003

## Status

Accepted.

## Context

The distro repo has two build lanes:

- **M-mode** (`docker/local-vista`) — `ydb_chset=M`, `LC_ALL=C`. Ports 9433 (RPC), 2225 (SSH). Built and verified first. Full 5/5 readiness. Browser terminal proof completed under M-mode.
- **UTF-8** (`docker/local-vista-utf8`) — `ydb_chset=UTF-8`, UTF-8 locale. Ports 9434 (RPC), 2226 (SSH). Built from WorldVistA `plan-vi` source tree. Full 5/5 readiness (CONTAINER_STARTED, NETWORK_REACHABLE, SERVICE_READY, TERMINAL_READY, RPC_READY).

The UTF-8 lane is required for multilingual support (Korean, Spanish) and correct multi-byte character handling. The M-mode lane cannot support non-ASCII characters safely. Several runbooks already refer to the UTF-8 lane as the active operator path.

## Decision

- **UTF-8 lane is the primary planned operator lane.** New operator workflows, terminal proof, multilingual verification, and production readiness work target this lane.
- **M-mode lane is the rollback/reference/safety lane.** It is retained for comparison, rollback, and as the original verified baseline. It is not deprecated or removed.
- **English is the baseline language.** All operator paths must work in English first.
- **Korean and Spanish are bounded product languages.** They are the only non-English languages with active language pack work. No broader language expansion without an explicit decision.
- **Terminal is not fully signed off.** Direct sign-on, browser terminal behavior, and multilingual input proof under the UTF-8 lane have not yet been rerun. This ADR does not claim those are complete.

## What this ADR does NOT claim

- The UTF-8 lane is production-ready. (It is the primary *planned* lane; readiness work continues.)
- Browser terminal is fully verified under UTF-8. (Still unverified; see `docs/reference/runtime-truth.md`.)
- Multilingual input round-trip is proven end-to-end. (Korean and Spanish packs exist; terminal input proof is pending.)
- M-mode lane is deprecated. (It is retained as rollback/reference/safety.)

## Consequences

- `docs/reference/runtime-truth.md` is updated to reflect UTF-8 as primary and M-mode as rollback/reference.
- Runbooks and quickstarts that already target UTF-8 (phase3-utf8-build-lane, terminal-operator-quickstart) are now aligned with the canonical designation.
- Future verification work (sign-on, browser terminal, multilingual input) must target the UTF-8 lane first.
- The M-mode lane remains buildable and verifiable. Its health check and Docker artifacts are not removed.
- Platform repo files referencing lanes may need a follow-up sync (see STEP D of the ratification task).
