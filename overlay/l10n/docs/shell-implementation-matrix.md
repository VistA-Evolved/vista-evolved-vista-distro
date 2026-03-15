# Shell Implementation Matrix

> Scope: Terminal-shell interactions only. No GUI, no control-plane, no
> package-level text. Assessed against `local-vista-utf8` container.
>
> **Live proof date**: 2025-07-14 (initial), 2025-07-15 (restart-safe). Tasks A–D verified via real browser
> terminal sessions (xterm.js → SSH → VistA sign-on). 10 screenshots (initial) + 7 screenshots (restart).

## Status Key

| Symbol | Meaning |
|--------|---------|
| LIVE-PROVEN | Verified in real browser terminal session with screenshot evidence |
| DONE | Data loaded and verified in container (M-level, not yet browser-proven) |
| PARTIAL | Some data present, gaps identified |
| STARTER | Structure created, data not yet populated |
| NEEDS-DATA | Code path exists, translation data needed |
| NEEDS-CODE | FileMan/Kernel code change required |
| BLOCKED | Upstream VistA limitation, cannot fix in overlay |

---

## Korean (ko) — Level 2

| Feature | Status | Detail |
|---------|--------|--------|
| **Date display (DD)** | DONE | Delegates to `$$FMTE^UKOUTL` → YYYY-MM-DD format. Node at `^DI(.85,198,"DD")`. |
| **Date+time format (FMTE)** | DONE | Delegates to `$$FMTE^UKOUTL`. Node at `^DI(.85,198,"FMTE")`. |
| **Date input hint (20.2)** | DONE | Stored at `^DI(.85,198,20.2)`. Guides date parser. |
| **YES/NO prompts** | LIVE-PROVEN | 4 dialogs: 7001 (예^아니오), 7003 (y:예;n:아니오), 8040, 9040. Verified byte-exact. |
| **Menu selection prompts** | LIVE-PROVEN | 20 dialogs (19001-19020): "옵션 선택:" visible in post-login terminal session. |
| **Sign-on / cover sheet** | LIVE-PROVEN | 10 dialogs: "사용자 이름:" and "암호:" visible at sign-on when site=Korean. |
| **Cardinal numbers (CRD)** | NEEDS-DATA | Korean uses same decimal convention as English (period). Node empty. Low priority. |
| **Lowercase (LC)** | NEEDS-DATA | Hangul has no case. Node not needed for Korean. |
| **Uppercase (UC)** | NEEDS-DATA | Hangul has no case. Node not needed for Korean. |
| **Ordinals (ORD)** | NEEDS-DATA | Korean ordinals differ from English (제1, 제2). Node empty. |
| **Time format (TIME)** | NEEDS-DATA | Korean uses 24h like English. Node empty. Low priority. |
| **Menu item names** | DONE (pilot) | 15/15 EVE tree items translated via `ZVEKOMEN.m`. Curated Korean using `$C()` encoding. XQO cache cleared on apply/restore. |

### Korean Live Proof Summary (2025-07-14)
- **Site-default switching**: Setting KSP piece 7 to 198 changes sign-on prompts to Korean ("사용자 이름:", "암호:") and post-login menu prompts to Korean ("옵션 선택:"). Help text also Korean.
- **Per-user override**: Setting `^VA(200,1,200)` piece 7 to 198 (site=English) produces English sign-on (expected — user unknown pre-auth) then Korean post-login prompts.
- **Rollback**: Clearing KSP piece 7 restores English immediately in next session.
- **What does NOT change**: Greeting text ("Good morning DOCTOR"), remaining ~185 menu item names outside EVE tree, alerts, date format in standard captioned output.
- **What DOES change at Level 3**: 15 EVE tree menu item names are now Korean when `APPLY^ZVEKOMEN` is active.
- **Formatting**: 3/7 nodes loaded (DD, FMTE, 20.2). 4 remaining are low-priority for Korean.
- **Dialogs**: 34/34 loaded. All 4 categories covered: YES/NO (4), menu prompts (20), sign-on (2), cover sheet (8).
- **Menus**: 15/15 EVE tree items translated via `ZVEKOMEN.m`. Integrated into ZVELPACK BOOT. Rollback: `D RESTORE^ZVEKOMEN`.

---

## Spanish (es) — Level 2

| Feature | Status | Detail |
|---------|--------|--------|
| **Date display (DD)** | DONE | DD/MM/YYYY format code loaded. Note: `$$FMTE^XLFDT` still delegates to `DILIBF` (same as English) — so standard date display is unchanged. The DD node is for input parsing, not FMTE output. |
| **Date+time format (FMTE)** | DONE | Delegates to `DILIBF` standard external format — same as English. No visible date display difference. |
| **Date input hint (20.2)** | DONE | Stored at `^DI(.85,3,20.2)`. |
| **Cardinal numbers (CRD)** | LIVE-PROVEN | Period→comma, comma→period swap. `$TR(Y,".,",",.")`. Verified: English `1,234,567.89` → Spanish `1.234.567,89`. |
| **Lowercase (LC)** | DONE | Full Latin alphabet `$TR` mapping. |
| **Uppercase (UC)** | DONE | Full Latin alphabet `$TR` mapping. |
| **Ordinals (ORD)** | LIVE-PROVEN | Number followed by period (e.g., `1.` not `1ST`). Verified: English `1ST, 2ND, 3RD` → Spanish `1., 2., 3.`. |
| **Time format (TIME)** | DONE | 24-hour display. |
| **YES/NO prompts** | LIVE-PROVEN | 4 dialogs: 7001 (Sí^No), 7003 (y:SÍ;n:NO), 8040, 9040. Verified byte-exact. |
| **Menu selection prompts** | LIVE-PROVEN | 20 dialogs (19001-19020): "Seleccione opción" visible in post-login terminal session. |
| **Sign-on prompts** | LIVE-PROVEN | 2 dialogs: 30810.51 (CÓDIGO DE ACCESO:), 30810.52 (CÓDIGO DE VERIFICACIÓN:). Verified at sign-on. |
| **Menu item names** | DONE (pilot) | 15/15 EVE tree items translated via `ZVEESMEN.m`. Curated Spanish using `$C()` encoding for accented chars (á,é,í,ó,ú,ñ). XQO cache cleared on apply/restore. |

### Spanish Live Proof Summary (2025-07-14)
- **Site-default switching**: Setting KSP piece 7 to 3 (Spanish) produces Spanish sign-on ("CÓDIGO DE ACCESO:", "CÓDIGO DE VERIFICACIÓN:") and post-login menu prompts ("Seleccione opción"). Help text also Spanish.
- **CRD verified via M probe**: `$$CRD^XLFDT` with `DUZ("LANG")=3` correctly swaps comma/period: `1,234,567.89` → `1.234.567,89`.
- **ORD verified via M probe**: `$$ORD^XLFDT` with `DUZ("LANG")=3` correctly produces period-ordinals: `1.`, `2.`, `3.` (vs English `1ST`, `2ND`, `3RD`).
- **FMTE unchanged**: Spanish FMTE delegates to `DILIBF` (same as English). No visible date display difference. Korean FMTE delegates to `UKOUTL` (YYYY-MM-DD) — this is why Korean has visible date change and Spanish does not.
- **? help**: "Ingrese ?? para más opciones, ??? para descripciones breves, ?OPCIÓN para texto de ayuda" — dialog 19020 rendering correctly.
- **?? extended help**: "También puede seleccionar una opción secundaria:" (19006), "Pulse INTRO para continuar, '^' para detener:" (19003), "O una opción común:" (19007) — all rendering correctly.
- **Rollback**: Clearing KSP piece 7 restores English immediately in next session. "ACCESS CODE:" confirmed restored.
- **What does NOT change**: Greeting text ("Good morning DOCTOR"), menu item names, alerts — these are data, not dialog translations.
- **Formatting**: 7/7 nodes loaded. Full locale formatting coverage.
- **Dialogs**: 26/26 populated. All 3 categories covered: YES/NO (4), menu prompts (20), sign-on (2).
- **Menus**: 15/15 EVE tree items translated via `ZVEESMEN.m`. Integrated into ZVELPACK BOOT. Rollback: `D RESTORE^ZVEESMEN`.

### Spanish Level 3 Live Proof Summary (2025-07-15)
- **Menu translation**: 15/15 EVE tree menu items translated with curated Spanish using UTF-8 `$C()` encoding for accented characters.
- **Browser proof**: 8 screenshots in `artifacts/proof-es-l3/` showing English baseline → Spanish sign-on → Spanish menus → help → extended help → child navigation → rollback.
- **Translated items**: Menú de Administración del Sistema, Opciones de Programador, VA FileMan, Gestión de Dispositivos, Gestión de Usuarios, Gestión de Menús, Aplicaciones Principales, Gestión de Operaciones, Gestión de Cola de Impresión, Menú del Oficial de Seguridad Informática, Utilidades de Aplicaciones, Planificación de Capacidad, Gestión de Correo, Gestión de Taskman, Menú Principal HL7.
- **? help rendering**: Spanish menu items display correctly in `?` single-column and `??` multi-column help listings.
- **Child navigation**: Type-ahead search with "Gest" matches all "Gestión de ..." items. Child menus (e.g., Gestión de Usuarios) display correctly.
- **Rollback**: `D RESTORE^ZVEESMEN` restores all 15 English menu items from backup; clearing KSP piece 7 restores English sign-on. Full rollback proven in browser.
- **ZVELPACK BOOT integration**: Multi-language switch logic ensures only one language's menu translations are active. Restores the other before applying the requested one.

---

## Runtime Integration (Restart-Safe)

> **Proven 2025-07-15** — 5 browser scenarios across container restart. 7 screenshots.

### How it works

Language packs are loaded automatically on every container boot by
`BOOT^ZVELPACK`, called from `entrypoint.sh`. The boot sequence:

1. **IPC cleanup** — removes stale System V shared memory/semaphores
2. **mupip rundown** — clears orphaned database locks
3. **TEMP database recreation** — `rm + mupip create` the temp.dat file
   (^TMP, ^XUTL, ^XTMP are transient and don't persist across boots)
4. **ZVEINIT sync** — runtime configuration
5. **BOOT^ZVELPACK** — loads ko (34 dlg) + es (26 dlg), reads `VISTA_SITE_LANG`
   env var, sets site default accordingly (defaults to English if unset)
6. **TaskMan, SSH, xinetd** — services start

### Key technical decisions

- **ydb_env_set bypassed** — its `Robustify` function creates broken shared
  memory when before-image journaling is not configured, causing cascading
  REQRUNDOWN errors. All three boot scripts (entrypoint.sh, sync-runtime.sh,
  vista-login.sh) set env vars directly instead.
- **ydb_icu_version=67.1** — must be set explicitly since ydb_env_set no
  longer auto-detects it. Without it, YottaDB fails with ICUSYMNOTFOUND.
- **TEMP database recreated on every boot** — prevents GVPUTFAIL errors from
  stale transaction numbers in the transient data region.
- **Pack loading is idempotent** — BOOT^ZVELPACK runs both LOAD and IEN
  resolution every boot; existing data is overwritten, not duplicated.

### Restart-safe proof (5 scenarios)

| # | Scenario | Pre-login | Post-login | Screenshot |
|---|----------|-----------|------------|------------|
| 1 | English baseline after restart | ACCESS CODE: | Select ... Option: | proof-1-english-post-restart.png |
| 2 | Korean site-default | 사용자 이름: | 옵션 선택: | proof-2-korean-*.png |
| 3 | Spanish site-default | CÓDIGO DE ACCESO: | Seleccione opción | proof-3-spanish-*.png |
| 4 | English site + Korean user | ACCESS CODE: (site) | 옵션 선택: (user) | proof-4-english-site-korean-user-*.png |
| 5 | Rollback to English | ACCESS CODE: | Select ... Option: | proof-5-rollback-english.png |

### VISTA_SITE_LANG env var

Set in docker-compose or `-e` flag to change site default on boot:
- `VISTA_SITE_LANG=ko` → Korean site default
- `VISTA_SITE_LANG=es` → Spanish site default
- Unset or empty → English (default)

The env var is read once at boot by `BOOT^ZVELPACK`. Runtime changes use
`SETLANG^ZVELPACK(IEN)` and take effect on next login (no restart needed).

### Files modified for runtime integration

| File | Change |
|------|--------|
| `docker/local-vista-utf8/entrypoint.sh` | ydb_env_set bypass, TEMP recreation, BOOT^ZVELPACK block |
| `docker/local-vista-utf8/sync-runtime.sh` | ydb_env_set bypass, ydb_icu_version |
| `docker/local-vista-utf8/vista-login.sh` | ydb_env_set bypass, ydb_icu_version, mupip rundown order |
| `overlay/routines/ZVELPACK.m` | BOOT entry point added (loads ko+es, reads VISTA_SITE_LANG) |

---

## Implementation Path to Next Level

### Korean → Level 3 (Menu Translated) — COMPLETE (pilot)
Completed via `ZVEKOMEN.m` with curated translations (not machine-translated).
1. ✅ Probed File 19 EVE tree structure (IEN 28, 14 children)
2. ✅ Created `overlay/routines/ZVEKOMEN.m` with APPLY/RESTORE/STATUS
3. ✅ Translates MENU TEXT (`^DIC(19,IEN,0)` piece 2) + uppercase U-node + kills XQO compiled cache
4. ✅ Integrated into `ZVELPACK.m` BOOT — auto-applies when `VISTA_SITE_LANG=ko`
5. ✅ Browser-proved: Korean menus, help listing, English rollback

**Next**: Extend to additional menu trees (~200 total Option file entries) using same pattern.

### Spanish → Level 3 (Menu Translated) — COMPLETE (pilot)
Completed via `ZVEESMEN.m` with curated translations (not machine-translated).
1. ✅ Same EVE tree as Korean pilot (IEN 28, 14 children)
2. ✅ Created `overlay/routines/ZVEESMEN.m` with APPLY/RESTORE/STATUS
3. ✅ Uses `$C()` for accented characters (á=225, é=233, í=237, ó=243, ú=250, ñ=241)
4. ✅ Custom UC() function for accented uppercase mapping
5. ✅ Integrated into `ZVELPACK.m` BOOT — multi-language switch logic
6. ✅ Browser-proved: Spanish menus, help listing, child nav, English rollback (8 screenshots)

**Next**: Extend to additional menu trees (~200 total Option file entries) using same pattern.

### Either Language → Level 4+ (FileMan Localized)
Requires translating FileMan field labels, help text, and set-of-codes.
This is a large effort (~2,698 dialog entries in File .84) and is out of
scope for this terminal-first slice.

---

## DUZ("LANG") Dispatch Coverage

363 routines in the VistA codebase check `$G(DUZ("LANG"))` to branch to
translated text. Key categories:

| Area | Routine Count | How Translation Fires |
|------|--------------|----------------------|
| FileMan core (DI*) | ~120 | `$$EZBLD^DIALOG` reads `^DI(.84,IEN,4,LANG)` |
| Kernel sign-on (XU*) | ~30 | Same DIALOG lookup |
| Menu system (XM*,XQ*) | ~40 | DIALOG + Option file text |
| Order entry (OR*) | ~50 | DIALOG for prompts, hard-coded for clinical text |
| TIU/Notes | ~20 | DIALOG for chrome, hard-coded for note templates |
| Other packages | ~103 | Mixed DIALOG + hard-coded |

The 34 Korean dialogs cover the FileMan core and Kernel sign-on dispatch
paths. Menu system dispatch requires Option file translation (Level 3).
Clinical package text (Order entry, TIU, etc.) requires Level 5 effort.
