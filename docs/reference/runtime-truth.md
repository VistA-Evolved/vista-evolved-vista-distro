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

### UTF-8 runtime proof (2026-03-18)

Live proof was executed against the running `local-vista-utf8` container (image `vista-distro:local-utf8`, sha256:82847200, built 2026-03-14). Evidence: `artifacts/logs/utf8-proof-20260318.log`.

- **Direct sign-on: PASS.** `ACCESS CODE:` / `VERIFY CODE:` prompt appears and accepts credentials (PRO1234 / PRO1234!!) under `ydb_chset=UTF-8`, `LANG=en_US.UTF-8`, `LC_ALL=en_US.UTF-8`. Full menu loads. Banner: "VistA Evolved Local Sandbox / YottaDB-backed terminal runtime". Volume set: `ROU:LOCAL-VISTA-UTF8`. Exit code 0. No MUMPS errors.
- **Browser terminal behavior: PASS.** The `terminal-proof` WebSocket-SSH bridge (port 2226) connects to the UTF-8 container, delivers the VistA sign-on banner at `ACCESS CODE:` prompt, accepts credentials, and displays the full menu. No shell leakage, no bash prompt, no `YDB>` visible. Device is `/dev/pts/0` (proper pseudo-terminal).
- **Multilingual input: PASS.**
	- English baseline: text roundtrips correctly through MUMPS W/R under UTF-8.
	- Korean bounded check: `$LENGTH("한국어테스트")` returns 6 (character count), confirming true UTF-8 mode (M-mode would return 18 bytes). Korean input echoes correctly through browser→WebSocket→SSH→VistA→SSH→WebSocket roundtrip.
	- Spanish bounded check: `$LENGTH("José")` returns 4 (character count, not 5 bytes). Spanish accented input echoes correctly through the full browser terminal roundtrip.
	- `$ASCII($EXTRACT("한",1))` returns 54620 (U+D55C), confirming Unicode code point handling.
	- Chinese and Arabic glyphs were observed to render/input correctly through the UTF-8 I/O path as a render-path observation only. These are not product languages.

### What UTF-8 proof does NOT claim

- Full VistA application-level localization. Menu text remains English; this is baseline sign-on and I/O path proof.
- Production-readiness of language pack integration (ZVELPACK boot-time loading exists but was not specifically tested in this proof).
- Chinese, Japanese, or Arabic as product languages. Only Korean and Spanish are bounded product languages per ADR-0003 and repo policy.
- Long-duration terminal stability (proof was session-length).
