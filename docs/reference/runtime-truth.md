# Runtime truth

## Lane designation (ADR-0003)

- **Primary planned operator lane:** UTF-8 (`docker/local-vista-utf8`). All new operator workflows, terminal proof, multilingual verification, and production readiness work target this lane.
- **Rollback/reference/safety lane:** M-mode (`docker/local-vista`). Retained for comparison, rollback, and as the original verified baseline. Not deprecated or removed.
- **English** is the baseline language. **Korean** and **Spanish** are bounded product languages.

## M-mode lane (rollback/reference)

- **Docker image:** `vista-distro:local` — built from `upstream/VistA-M` (local snapshot import). See `docker/local-vista/Dockerfile`.
- **Container:** `local-vista` — ports **9433** (RPC broker), **2225** (SSH). Volume: `local-vista-data`.
- **Readiness levels:** See `docs/reference/runtime-readiness-levels.md`. Verification script: `scripts/verify/healthcheck-local-vista.ps1` (use `-ValidatePathsOnly` for path validation without Docker).
- **Docker build completed.** Built from local upstream + overlay per ADR-0002. 33,951 routines, 2,922 globals, 0 load errors. Lock: `locks/worldvista-sources.lock.json`.
- **Charset boundary:** `ydb_chset=M` with `LC_ALL=C`. This was the original operator-safe lane for initial operator/browser proof. See `docs/runbooks/phase2-terminal-proof-report.md` and `artifacts/session-report-terminal-charset-boundary.md`.

## UTF-8 lane (primary planned operator lane)

- `docker/local-vista-utf8` is built from the local WorldVistA `plan-vi` source lane (`upstream/VistA-VEHU-M-plan-vi`) and has passed image build plus compose readiness verification. Latest live proof:
	- build command: `docker build --progress=plain -f docker/local-vista-utf8/Dockerfile -t vista-distro:local-utf8 .`
	- runtime command: `docker compose -f docker/local-vista-utf8/docker-compose.yml up -d`
	- readiness command: `scripts/verify/healthcheck-local-vista-utf8.ps1`
	- readiness result: 5 PASS, 0 FAIL (`CONTAINER_STARTED`, `NETWORK_REACHABLE`, `SERVICE_READY`, `TERMINAL_READY`, `RPC_READY`)
	- latest build artifact: `artifacts/logs/docker-build-planvi-kbantclnfix8.log`
- **UTF-8 lane verified fixes:**
	- UTF-8 `.zwr` header rewrite and routine recode are active in the build lane.
	- UTF-8 YottaDB shared-library path is in use.
	- `KBANTCLN` now runs to completion under UTF-8 after replacing fresh-db FileMan lookups for files `.7`, `3.5`, and `19` with bootstrap-safe logic.
	- both Dockerfiles now recompile `KBANTCLN.m` after copying it, which avoids stale upstream `KBANTCLN.o` reuse.
- **Still unverified in UTF-8:** direct sign-on, browser terminal behavior, and multilingual input proof have not yet been rerun against the live `local-vista-utf8` container. This ADR does not claim those are complete.
