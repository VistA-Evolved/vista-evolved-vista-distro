# Multilingual Language-Pack Foundation — Slice Report

> Date: 2025-07-14
> Container: `local-vista-utf8` (healthy, ports 2226:22, 9434:9430)
> Slice: language-pack-foundation (follows multilingual-architecture-inventory)

## Objective

Turn the completed multilingual inventory into the first real multilingual
terminal implementation slice by creating a language-pack foundation for the
terminal-first product.

## Tasks Completed

### A. Language-Pack Directory Structure
Created `overlay/l10n/` with:
- `README.md` — Structure overview, pack table
- `PACK-SPEC.md` — Full specification: directory layout, manifest schema, level definitions (0-5), formatting nodes, dialog storage, installer protocol
- `ko/` — Korean pack directory
- `es/` — Spanish pack directory
- `shared/` — Shared infrastructure (README)
- `docs/` — Language selection mechanism, shell implementation matrix

### B. Implementation Scope
Defined in PACK-SPEC.md: terminal-shell only. Covers sign-on prompts, YES/NO,
menu prompts, date/number/ordinal formatting. Excludes GUI, control-plane,
package-level translation.

### C. Korean Pack (Level 2 — Core Prompt Translated)
- **formatting.m** (`ZVEKOFMT`): Loads DD, FMTE, 20.2 nodes into LANGUAGE file (.85) IEN 198. DD delegates to `$$FMTE^UKOUTL` for YYYY-MM-DD display.
- **dialogs.m** (`ZVEKODLG`): Loads 34 dialog translations into DIALOG file (.84). All $C() sequences are machine-generated from live Plan VI globals via ZVEEXPT auto-exporter — NOT hand-coded.
- **manifest.json**: Full metadata with coverage details.
- **Verified**: All 34 dialogs load and verify byte-exact against original Plan VI data.

### D. Spanish Pack (Level 2 — Core Prompt Translated)
- **formatting.m** (`ZVEESFMT`): Loads all 7 formatting nodes (DD, FMTE, CRD, LC, UC, ORD, TIME) plus 20.2. DD/MM/YYYY dates, comma decimals, 24h time.
- **dialogs.m** (`ZVEESDLG`): Loads 26 dialog translations into DIALOG file (.84). Covers YES/NO (4), menu prompts (20), and sign-on prompts (2).
- **manifest.json**: Full metadata with coverage details.
- **Verified**: All 7 formatting nodes load correctly. 26 dialogs load and verify. Live-proven in browser (CÓDIGO DE ACCESO, Seleccione opción).

### E. Language Selection Mechanism
Documented in `overlay/l10n/docs/language-selection.md`:
- Dispatch chain: `DUZ("LANG")` set at login from site default (KSP p7) or per-user override (`^VA(200,DUZ,200)` p7)
- 363 routines check `$G(DUZ("LANG"))` for translation branching
- ZVELPACK provides `SETLANG` (site default) and `SETUSER` (per-user) commands

### F. Shell Implementation Matrix
Created `overlay/l10n/docs/shell-implementation-matrix.md`:
- Korean: 34 dialogs DONE, 3/7 formatting DONE, 4 remaining low-priority (no case in Hangul)
- Spanish: 7/7 formatting DONE, 0/26 dialogs STARTER, 26 candidates identified
- Implementation path to Level 3 (menus) documented; Korean Level 3 pilot complete (15/15 EVE tree)

### G. Installer Routine
Created `overlay/routines/ZVELPACK.m` with commands:
- `LOAD(pack)` — Calls ZVE<PACK>FMT and ZVE<PACK>DLG
- `VERIFY(pack)` — Checks formatting nodes and dialog translations
- `SETLANG(IEN)` — Sets site default language
- `SETUSER(DUZ,IEN)` — Sets per-user language
- `STATUS` — Shows all language packs with formatting/dialog counts
- `BOOT` — Boot-time entry: loads ko+es, reads `VISTA_SITE_LANG` env var

### H. Runtime Integration (2025-07-15)
Wired language pack loading into the container startup sequence:
- `entrypoint.sh` calls `BOOT^ZVELPACK` on every boot (idempotent)
- Bypassed `ydb_env_set` in all 3 scripts (entrypoint, sync-runtime, vista-login)
  due to its Robustify function creating broken SHM with NOTBEFOREIMAGEJOURNAL
- Added TEMP database recreation on boot (fixes GVPUTFAIL from stale TN)
- Added `ydb_icu_version=67.1` to all env setups (fixes ICUSYMNOTFOUND)
- Proven restart-safe in 5 browser scenarios: English baseline, Korean site,
  Spanish site, English+Korean user override, rollback to English
- 7 screenshots in `artifacts/proof-*.png`

## Files Changed

### New files (overlay/l10n/)
| File | Purpose |
|------|---------|
| `overlay/l10n/README.md` | L10n directory overview |
| `overlay/l10n/PACK-SPEC.md` | Language pack specification |
| `overlay/l10n/ko/manifest.json` | Korean pack metadata |
| `overlay/l10n/ko/formatting.m` | Korean LANGUAGE file loader |
| `overlay/l10n/ko/dialogs.m` | Korean DIALOG translations (34 entries, auto-exported) |
| `overlay/l10n/es/manifest.json` | Spanish pack metadata |
| `overlay/l10n/es/formatting.m` | Spanish LANGUAGE file loader (7 nodes) |
| `overlay/l10n/es/dialogs.m` | Spanish DIALOG starter (26 candidates) |
| `overlay/l10n/shared/README.md` | Shared infrastructure readme |
| `overlay/l10n/docs/language-selection.md` | Language selection mechanism doc |
| `overlay/l10n/docs/shell-implementation-matrix.md` | Implementation status matrix |

### New files (overlay/routines/)
| File | Purpose |
|------|---------|
| `overlay/routines/ZVELPACK.m` | Language pack installer/verifier |
| `overlay/routines/ZVEKOFMT.m` | Korean formatting (copy of ko/formatting.m) |
| `overlay/routines/ZVEKODLG.m` | Korean dialogs (copy of ko/dialogs.m) |
| `overlay/routines/ZVEESFMT.m` | Spanish formatting (copy of es/formatting.m) |
| `overlay/routines/ZVEESDLG.m` | Spanish dialogs (copy of es/dialogs.m) |

### Artifacts (not committed)
| File | Purpose |
|------|---------|
| `artifacts/ZVELXT2.m` | Data extractor v2 (with safe $D checks) |
| `artifacts/ZVEEXPT.m` | Auto-exporter: generates $C() from live globals |
| `artifacts/ZVELTEST.m` | Integration test harness (from prior session) |

## Commands Run

```powershell
# Container volume rebuild (to restore clean Plan VI data)
docker compose -f docker/local-vista-utf8/docker-compose.yml down -v
docker rm -f local-vista-utf8
docker compose -f docker/local-vista-utf8/docker-compose.yml up -d

# Deploy all 5 language pack routines
docker cp overlay\routines\ZVELPACK.m local-vista-utf8:/opt/vista/r/ZVELPACK.m
docker cp overlay\routines\ZVEKOFMT.m local-vista-utf8:/opt/vista/r/ZVEKOFMT.m
docker cp overlay\routines\ZVEKODLG.m local-vista-utf8:/opt/vista/r/ZVEKODLG.m
docker cp overlay\routines\ZVEESFMT.m local-vista-utf8:/opt/vista/r/ZVEESFMT.m
docker cp overlay\routines\ZVEESDLG.m local-vista-utf8:/opt/vista/r/ZVEESDLG.m

# Deploy and run auto-exporter (generates correct ZVEKODLG from live globals)
docker cp artifacts\ZVEEXPT.m local-vista-utf8:/opt/vista/r/ZVEEXPT.m
docker exec local-vista-utf8 bash -c "... && yottadb -run ZVEEXPT > /tmp/ZVEKODLG_exported.m"

# Verification test (8/8 passed)
docker exec local-vista-utf8 bash -c "... && yottadb -run ZVETEST2"
```

## Verification Results

```
=== Test 1: Load Korean pack ===         PASS (34 entries loaded)
=== Test 2: Dialog 7001 length ===       PASS (len=5, was 6 with bug)
=== Test 3: Dialog 7001 chars ===        PASS (50696/94/50500 correct)
=== Test 4: Dialog 7003 ===              PASS (len=9)
=== Test 5: Total Korean dialogs ===     PASS (34)
=== Test 6: Load Spanish pack ===        PASS (7 formatting nodes)
=== Test 7: Spanish DD node ===          PASS (DD/MM/YYYY format)
=== Test 8: Korean formatting ===        PASS (DD delegates to UKOUTL)

SUMMARY: PASS: 8  FAIL: 0  ALL TESTS PASSED
```

## Bug Found and Fixed

**$C() encoding bug in ZVEKODLG.m**: The original hand-coded Korean dialog
translations contained character encoding errors. Dialog 7001 produced
`예림^아니오` (6 chars, extra 림/$C(47548)) instead of correct `예^아니오`
(5 chars). Multiple other dialogs also had incorrect codepoints.

**Fix**: Created ZVEEXPT.m — an auto-exporter that reads each character from
the live Plan VI globals using `$A($E(text,I))` and generates correct $C()
sequences programmatically. Rebuilt the container from the Docker image (fresh
volume) to restore original Plan VI data, then re-exported.

**Lesson**: Never hand-code Unicode $C() sequences for M routines. Always
auto-generate from verified live data using $A() per-character extraction.

## What Works

1. Korean Level 2 pack: 34 dialog translations + 3 formatting nodes load and verify
2. Spanish Level 2 pack: 26 dialog translations + 7 formatting nodes load and verify
3. ZVELPACK installer: LOAD, VERIFY, STATUS commands all functional
4. Language selection mechanism: SETLANG (site) and SETUSER (per-user) work
5. All $C() sequences are machine-generated and byte-exact against Plan VI originals

## What's Missing / Not Done

1. ~~Spanish dialog translations~~ — DONE: 26 dialogs populated (Level 2)
2. Korean formatting gaps: CRD, LC, UC, ORD, TIME nodes (low priority — Hangul has no case)
3. ~~Menu item translations (Option file 19) for either language~~ — DONE (pilot): Korean via `ZVEKOMEN.m`, Spanish via `ZVEESMEN.m`, both 15/15 EVE tree items
4. ~~Integration with ZVEINIT.m startup sequence~~ — DONE: `BOOT^ZVELPACK` wired into `entrypoint.sh` (see Section H)
5. ~~DUZ("LANG") not set by default~~ — DONE: `BOOT^ZVELPACK` reads `VISTA_SITE_LANG` env var on every boot

## Live Shell Proof (2025-07-14)

> Verified in real browser terminal sessions (xterm.js → SSH → VistA sign-on).
> Container: `local-vista-utf8`. Credentials: PRO1234 / PRO1234!!.
> 10 screenshots captured during session.

### Bug Fix During Live Proof

**`U` variable undefined in ZVEKODLG.m**: Running `LOAD^ZVELPACK("ko")` hit
`%YDB-E-LVUNDEF, Undefined local variable: U` at `EN+5^ZVEKODLG`. The
auto-exported routine uses `_U_` (VistA caret separator `U="^"`), which is
only defined inside a full VistA login environment. Fixed by adding `S U="^"`
as the first line of the EN entry point in `overlay/l10n/ko/dialogs.m` and
`overlay/routines/ZVEKODLG.m`.

### Task A — English Baseline (PROVEN)

- Site=English, User=English
- Sign-on shows "ACCESS CODE:" and "VERIFY CODE:"
- Post-login shows "Good morning DOCTOR", "Select Systems Manager Menu Option:"
- `??` shows extended help with English text
- **Result**: English baseline is the control.

### Task B — Korean Site-Default Switching (PROVEN)

- Set KSP piece 7 to 198 (Korean) via `SITEKO^ZVELSET`
- Sign-on changed to "사용자 이름:" (Korean for "User name") and "암호:" (Password)
- Post-login prompt shows "Systems Manager Menu 옵션 선택:" (Korean option selection)
- `?` shows Korean help text
- Restored to English → "ACCESS CODE:" returned immediately in next session

### Task C — Per-User Korean Override (PROVEN)

- Site=English, User DUZ=1=Korean via `USERKO^ZVELSET`
- Sign-on shows "ACCESS CODE:" (English) — **correct**: user identity unknown pre-auth
- Post-login shows "옵션 선택:" (Korean) — user override takes effect after login
- **Proves**: `DUZ("LANG")` dispatch chain works: site default for pre-auth, user preference for post-auth

### Task D — Spanish Level 2 Prompts + Formatting (PROVEN)

- Set KSP piece 7 to 3 (Spanish) via `SITEES^ZVELSET`
- Sign-on shows "CÓDIGO DE ACCESO:" and "CÓDIGO DE VERIFICACIÓN:" (Spanish)
- Post-login shows "Seleccione opción Systems Manager Menu:" (Spanish)
- **CRD verified via M probe**: `$$CRD^XLFDT` with DUZ("LANG")=3: `1,234,567.89` → `1.234.567,89` ✓
- **ORD verified via M probe**: `$$ORD^XLFDT` with DUZ("LANG")=3: `1ST` → `1.`, `2ND` → `2.`, `3RD` → `3.` ✓
- **Note**: Spanish FMTE delegates to DILIBF (same as English). Korean FMTE delegates to UKOUTL (YYYY-MM-DD). This is why Korean has visible date display change and Spanish does not.

### Live Proof Classification

| Language | Level | What IS proven live | What is NOT visible in standard UI |
|----------|-------|--------------------|------------------------------------|
| English  | Baseline | All prompts, dates, menus | — |
| Korean   | 3 | Sign-on translated, menu prompts translated, help text translated, per-user override, rollback, **15/15 EVE menu items translated** (ZVEKOMEN.m) | Greeting text, remaining ~185 menu items, alerts, dates in captioned output |
| Spanish  | 3 | Sign-on translated (CÓDIGO DE ACCESO/VERIFICACIÓN), menu prompts translated (Seleccione opción), CRD comma/period swap, ORD period-ordinals, rollback, **15/15 EVE menu items translated** (ZVEESMEN.m), help listing, child nav | Greeting text, remaining ~185 menu items, alerts, FMTE same as English |

### Utility Routines Created for Live Proof

| Routine | Purpose | Location |
|---------|---------|----------|
| `ZVELOAD.m` | Combined pack loader (ko + es + status + verify) | `artifacts/ZVELOAD.m` |
| `ZVELSET.m` | Language switching (SITEENG/SITEKO/SITEES + USERENG/USERKO/USERES + SHOW) | `artifacts/ZVELSET.m` |
| `ZVEFMTP.m` | FMTE date formatting probe | `artifacts/ZVEFMTP.m` |
| `ZVEFMT2.m` | DD/CRD/ORD/TIME node probe | `artifacts/ZVEFMT2.m` |
| `ZVEFMT3.m` | CRD + ORD comparison probe (proved Spanish formatting works) | `artifacts/ZVEFMT3.m` |
| `ZVEKOMEN.m` | **Production** — Korean menu overlay for EVE tree (APPLY/RESTORE/STATUS) | `overlay/routines/ZVEKOMEN.m` |
| `ZVEESMEN.m` | **Production** — Spanish menu overlay for EVE tree (APPLY/RESTORE/STATUS) | `overlay/routines/ZVEESMEN.m` |

Investigation routines above are artifacts, not production. `ZVEKOMEN.m` and `ZVEESMEN.m` are production overlay routines integrated into ZVELPACK BOOT.

## Next Exact Task

**Korean Level 3 — Extend menu translations**: 15/15 EVE (Systems Manager
Menu) tree items are translated via `ZVEKOMEN.m` (curated, not machine-
translated). XQO compiled cache clearing and ZVELPACK BOOT integration are
proven. Next steps:
- Extend to additional menu trees (~185 remaining Option file entries)
- Same pattern: curated `$C()` Korean, backup/restore, XQO cache kill
- Or: use `TRAMENU^UKOP6TRA` pipeline with MS Translate API key + human review

**Spanish Level 3 — COMPLETE (pilot)**: 15/15 EVE tree items translated
via `ZVEESMEN.m` (curated, UTF-8 `$C()` for accented characters). Integrated
into ZVELPACK BOOT with multi-language switch logic. Browser-proved: 8
screenshots in `artifacts/proof-es-l3/`.

**Extend to additional menu trees**: Both Korean and Spanish Level 3 pilots
are proven. Next step is to translate the remaining ~185 Option file entries
using the same curated `$C()` pattern.

**Or**: Promote German from Level 1 to Level 2 by translating 26 core
shell dialogs (YES/NO, menu prompts, sign-on). German already has 7/7
formatting nodes — only dialog translations are missing.
