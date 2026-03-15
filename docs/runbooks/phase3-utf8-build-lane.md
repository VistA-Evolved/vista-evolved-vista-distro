# Phase 3 Runbook - UTF-8 Build Lane

## Objective

Create and prove a dedicated UTF-8 local VistA lane without destabilizing the
already verified M-mode operator lane.

This is a separate build slice. Do not mutate `docker/local-vista/` until the
UTF-8 lane is independently built, booted, and verified.

## Current Truth

- The verified browser terminal lane is the UTF-8 image in `docker/local-vista-utf8/`.
- The UTF-8 lane has been built, booted, and verified through the full browser
  terminal path (YottaDB -> SSH -> WebSocket -> xterm.js).
- `$ZCHSET` returns `UTF-8` at the YDB direct-mode prompt.
- `$LENGTH` returns character count; `$ZLENGTH` returns byte count (correct
  multi-byte distinction verified for Latin, Spanish, CJK).
- Global store/retrieve round-trip verified for cafe, resume, Espanol, and
  CJK characters (世界).
- No SSH leakage, no TaskMan warning, menu prompt shows `<LOCAL SANDBOX>`.
- Charset classification: **Full multilingual safe**.
- The legacy M-mode lane (`docker/local-vista/`) is retained for reference
  but is no longer the primary operator path.

## Inventory First

Inspect these files before implementing the UTF-8 lane:

- `docker/local-vista/Dockerfile`
- `docker/local-vista/docker-compose.yml`
- `docker/local-vista/entrypoint.sh`
- `docker/local-vista/vista-login.sh`
- `docker/local-vista/start-taskman.sh`
- `docker/local-vista/sync-runtime.sh`
- `docker/local-vista/check-taskman.sh`
- `docker/local-vista/health-check.sh`
- `overlay/routines/_ZTER.m`
- `docs/runbooks/phase2-terminal-proof-report.md`
- `docs/runbooks/browser-terminal-proof.md`
- `scripts/verify/healthcheck-local-vista.ps1`

## Exact Files To Add Or Change In The Next Slice

Prefer a parallel lane with new files rather than changing the stable lane in
place. This scaffold now exists in the repo.

Planned new files:

- `docker/local-vista-utf8/Dockerfile`
- `docker/local-vista-utf8/docker-compose.yml`
- `docker/local-vista-utf8/entrypoint.sh`
- `docker/local-vista-utf8/vista-login.sh`
- `docker/local-vista-utf8/start-taskman.sh`
- `docker/local-vista-utf8/sync-runtime.sh`
- `docker/local-vista-utf8/check-taskman.sh`
- `docker/local-vista-utf8/health-check.sh`
- `scripts/verify/healthcheck-local-vista-utf8.ps1`
- `docs/runbooks/phase3-utf8-build-lane.md` updates with live proof results

Current scaffold choices:

- container name: `local-vista-utf8`
- image name: `vista-distro:local-utf8`
- RPC port: `9434`
- SSH port: `2226`
- runtime sysid: `LOCAL-VISTA-UTF8`

Files that may need overlay changes after the first UTF-8 boot attempt:

- `overlay/routines/_ZTER.m`
- additional overlay routines only if a live UTF-8 crash identifies a specific
  routine-level incompatibility after the lane is rebuilt correctly

## Implementation Steps

1. Copy the current `docker/local-vista/` lane into a new `docker/local-vista-utf8/` lane.
2. Change the new build lane to use UTF-8 locale and YottaDB charset from the
   start of database creation, global load, compile, and runtime startup.
3. Keep ports separate from the M-mode lane to allow side-by-side comparison.
4. Ensure the new lane does not reuse M-built object files or runtime state.
5. Add a dedicated UTF-8 healthcheck script so proof does not rely on the M-mode
   lane tooling.
6. Rebuild the full lane from scratch. Do not test UTF-8 by flipping env vars in
   an already-built M image.
7. Only after a clean UTF-8 boot, investigate any remaining routine-level errors
   such as `_ZTER`.

## Build-Time Requirements

The UTF-8 lane must prove all of the following:

- locale is configured for UTF-8 at build time
- YottaDB charset is UTF-8 at build time
- globals are loaded under UTF-8, not under M then reused
- objects are compiled under UTF-8, not reused from the M lane
- runtime launcher scripts preserve the UTF-8 environment end to end

## Upstream UTF-8 Contract

The UTF-8 lane must stay aligned with the upstream WorldVistA and YottaDB
contract rather than ad hoc local fixes.

WorldVistA-side requirements confirmed from upstream install scripts:

- UTF-8 install is a real build mode (`-u` / UTF-8 instance creation), not just
   a runtime locale flip.
- WorldVistA `vehu6` uses `https://github.com/WorldVistA/VistA-VEHU-M/archive/plan-vi.zip`,
  not `master.zip`, for the UTF-8 source tree.
- UTF-8 builds rewrite `.zwr` first lines to `OSEHRA ZGO Export: THIS GLOBAL UTF-8`
   before `mupip load`.
- UTF-8 builds recode imported routine source from `iso8859-1` to `utf-8`
   before compile/load.
- UTF-8 instance env uses UTF-8 locale and UTF-8 routine/plugin paths.
- VEHU Plan VI applies `vehu6piko.sh` after `KBANTCLN` to install the Plan VI
  Lexicon KIDs payload and Korean-specific post-install adjustments. That step
  is downstream of the current `KBANTCLN` blocker, but it is part of the full
  upstream UTF-8 contract.

YottaDB-side requirements confirmed from upstream docs and source:

- UTF-8 mode must use UTF-8-compiled shared library paths, especially
   `$ydb_dist/utf8/libyottadbutil.so`.
- `mupip load` rejects extract/header charset mismatch, so UTF-8 global headers
   are part of correctness, not cosmetic cleanup.
- YottaDB ships separate M-mode and UTF-8 routine/library lanes and separate
   default `ydb_routines` resolution for each.

Operational requirement for this repo:

- Any future UTF-8 fix must map to one of these upstream requirements or to a
   clearly identified VistA routine incompatibility. Do not paper over build
   failures with runtime env toggles.

## Live Results So Far

The following are now proven in the UTF-8 lane:

- UTF-8 locale packages install successfully.
- local snapshot preparation completes successfully.
- 3,090 globals load under UTF-8 with 0 load errors.
- the prior `%YDB-E-DLLCHSETM` failure is resolved by using the UTF-8 YottaDB
   shared library path.
- upstream research confirmed the previous local source selection was incomplete:
  the lane had been building from `upstream/VistA-M` instead of the WorldVistA
  `plan-vi` source tree used by `vehu6`; this is now corrected.
- `KBANTCLN` now completes under UTF-8 after replacing bootstrap-unsafe
  FileMan lookups and recompiling the copied `KBANTCLN.m` so the build does not
  execute a stale upstream object file.
- demo user creation now completes under UTF-8 with `overlay/routines/ZVECREUSER.m`.
- compose readiness passes against the live `local-vista-utf8` container:
  `CONTAINER_STARTED`, `NETWORK_REACHABLE`, `SERVICE_READY`, `TERMINAL_READY`,
  and `RPC_READY` all PASS.

Latest proof artifacts:

- build log: `artifacts/logs/docker-build-planvi-kbantclnfix8.log`
- readiness command: `scripts/verify/healthcheck-local-vista-utf8.ps1`
- runtime start command: `docker compose -f docker/local-vista-utf8/docker-compose.yml up -d`

## Verification Steps

Run these after the new lane is built.

### 1. Container readiness

Create and run a UTF-8-specific readiness script equivalent to:

```powershell
.\scripts\verify\healthcheck-local-vista-utf8.ps1
```

Expected result:

- container started
- network reachable
- service ready
- terminal ready
- RPC ready

### 2. Runtime charset proof

Verify inside the UTF-8 container that the runtime actually reports UTF-8 and is
not silently falling back to M.

Expected proof points:

- `$ZCHSET` reports UTF-8
- the login shell runs with UTF-8 locale
- object directory contents are from the UTF-8 build path, not reused M objects

### 3. Direct sign-on proof

Verify a direct terminal session can reach:

- intro banner
- `ACCESS CODE:`
- successful login
- menu prompt

### 4. Browser terminal proof

Repeat the existing browser proof against the UTF-8 lane:

- clipboard paste for access and verify code
- menu navigation with `?`, `??`, and `^`
- reload and reconnect
- accented Latin input
- Arabic input
- Chinese input

### 5. Failure audit

If the lane still fails, capture the exact crash path and classify it as one of:

- build-lane defect
- locale/env defect
- object reuse defect
- routine incompatibility requiring overlay remediation

For the current state, classify failures in this order:

- import/header mismatch
- UTF-8 shared-library mismatch
- GT.M/YottaDB compatibility routine incompatibility
- FileMan/kernel initialization failure
- runtime terminal or broker failure after successful boot

## Acceptance Gates

Phase 3 is done only if all gates pass:

1. UTF-8 lane builds from scratch without falling back to M-mode artifacts.
2. Readiness script passes.
3. Direct sign-on reaches `ACCESS CODE:` and successful menu login.
4. Browser terminal stays connected.
5. Multilingual input no longer relies on the M-mode compromise path.
6. No `_ZTER` crash or equivalent fatal error occurs during ordinary browser use.
7. A proof report records exact commands, exact outputs, and pass/fail status.

## Rejection Criteria

Reject the UTF-8 lane for operator use if any of these remain true:

- the lane only works after manual shell env flipping
- it reuses M-built objects or globals
- browser sessions disconnect under ordinary sign-on or menu use
- multilingual input still behaves inconsistently in a way that proves the lane
  is not actually stable UTF-8

## Stop And Report Rule

If a rebuilt UTF-8 lane still fails, stop after the first fully documented live
failure and write a proof artifact that includes:

- files changed
- commands run
- exact output
- pass/fail per gate
- whether the root cause appears build-level or routine-level

Current stop boundary:

- import path is corrected and live-proven
- UTF-8 shared-library path is corrected and live-proven
- source selection is now corrected to the upstream `plan-vi` lane for the next
   rebuild
- boot is still blocked by `KBANTCLN` / FileMan `.7` lookup path under UTF-8

Do not mark browser, broker, terminal, or multilingual operator proof complete
until the image builds past this boundary and reaches live sign-on.

Do not silently collapse back into the M-mode lane and call UTF-8 "partially
working" unless the proof clearly shows that outcome.