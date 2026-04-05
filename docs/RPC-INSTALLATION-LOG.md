# RPC Installation Log — Wave 1

## Summary

| Metric | Value |
|--------|-------|
| **Wave** | 1 (1B) |
| **Total RPCs** | 30 |
| **M Routines Created** | 7 (5 RPC + 2 support) |
| **Context Options** | 2 (ZVE ADMIN CONTEXT, ZVE PATIENT CONTEXT) |
| **Output Convention** | `S R(n)="1^..."` success / `S R(0)="0^error"` failure (RPC Broker type=2 ARRAY) |
| **Master Installer** | `D RUN^ZVEINSTALL` |

## M Routine Inventory

| Routine | Purpose | RPCs | Lines |
|---------|---------|------|-------|
| ZVEADMIN.m | Admin user list/detail/edit/term/audit/rename | 6 | ~375 |
| ZVEADMN1.m | Admin keys/e-sig/roles/params/divisions | 9 | ~419 |
| ZVEPAT.m | Patient register/edit/demographics/insurance/means/elig | 6 | ~416 |
| ZVEPAT1.m | Patient flags/duplicate/search/recent/deceased | 5 | ~352 |
| ZVEADT.m | ADT admit/discharge/transfer/census | 4 | ~243 |
| ZVECTX2.m | Context option creation + RPC registration | — | ~93 |
| ZVEINSTALL.m | Master installer with verification | — | ~66 |

## RPC Catalog

### Admin Domain (15 RPCs → ZVEADMIN.m + ZVEADMN1.m)

| # | RPC Name | Tag^Routine | Input | Output |
|---|----------|-------------|-------|--------|
| A01 | ZVE USER LIST | LIST2^ZVEADMIN | SEARCH, STATUS, DIVISION, MAX | 1^COUNT^OK + rows |
| A02 | ZVE USER DETAIL | DETAIL^ZVEADMIN | TARGETDUZ | 1^1^OK + DEM/KEY/DIV rows |
| A03 | ZVE USER EDIT | EDIT^ZVEADMIN | TARGETDUZ, FIELD, VALUE | 1^OK^field^value |
| A04 | ZVE USER TERM | TERM^ZVEADMIN | TARGETDUZ, REASON | 1^TERMINATED^DUZ |
| A05 | ZVE ADMIN AUDIT | AUDIT^ZVEADMIN | SOURCE, USERDUZ, MAX | 1^COUNT^OK + rows |
| A06 | ZVE USER RENAME | RENAME^ZVEADMIN | TARGETDUZ, NEWNAME | 1^OK^name |
| A07 | ZVE KEY LIST | KEYLIST^ZVEADMN1 | TARGETDUZ (opt) | 1^COUNT^OK + rows |
| A08 | ZVE KEY ASSIGN | KEYASSN^ZVEADMN1 | TARGETDUZ, KEYNAME | 1^OK^keyname |
| A09 | ZVE KEY REMOVE | KEYREM^ZVEADMN1 | TARGETDUZ, KEYNAME | 1^OK^keyname |
| A10 | ZVE ESIG MANAGE | ESIGMGT^ZVEADMN1 | TARGETDUZ, ACTION | 1^STATUS^SET\|NONE |
| A11 | ZVE ROLE TEMPLATE | ROLETPL^ZVEADMN1 | ROLENAME | 1^1^OK + ROLE/KEY/CTX rows |
| A12 | ZVE PARAM GET | PARAMGT^ZVEADMN1 | (none) | 1^COUNT^OK + PARAM rows |
| A13 | ZVE PARAM SET | PARAMST^ZVEADMN1 | PARAMNAME, VALUE, REASON | 1^OK^name^value |
| A14 | ZVE DIVISION LIST | DIVLIST^ZVEADMN1 | (none) | 1^COUNT^OK + rows |
| A15 | ZVE DIVISION ASSIGN | DIVASN^ZVEADMN1 | TARGETDUZ, DIVIEN, ACTION | 1^OK^action |

### Patient Domain (11 RPCs → ZVEPAT.m + ZVEPAT1.m)

| # | RPC Name | Tag^Routine | Input | Output |
|---|----------|-------------|-------|--------|
| P01 | ZVE PATIENT REGISTER | REG^ZVEPAT | NAME, DOB, SSN, SEX, addr... | 1^DFN^name^ssn4 |
| P02 | ZVE PATIENT EDIT | EDIT^ZVEPAT | DFN, FIELD, VALUE | 1^OK^field^value |
| P03 | ZVE PATIENT DEMOGRAPHICS | DEMO^ZVEPAT | DFN | 1^COUNT^OK + DEM/INS/NOK/EMRG |
| P04 | ZVE PATIENT INSURANCE | INS^ZVEPAT | DFN, ACTION, params... | varies by action |
| P05 | ZVE PATIENT MEANS | MEANS^ZVEPAT | DFN, ACTION | 1^1^OK + MT row |
| P06 | ZVE PATIENT ELIG | ELIG^ZVEPAT | DFN | 1^COUNT^OK + ELIG rows |
| P07 | ZVE PATIENT FLAGS | FLAGS^ZVEPAT1 | DFN, ACTION, params... | varies by action |
| P08 | ZVE PATIENT DUPLICATE | DUPL^ZVEPAT1 | NAME, DOB, SSN, SEX, MAX | 1^COUNT^OK + scored rows |
| P09 | ZVE PATIENT SEARCH EXTENDED | SRCH^ZVEPAT1 | SEARCH, STYPE, params... | 1^COUNT^OK + rows |
| P10 | ZVE RECENT PATIENTS | RECENT^ZVEPAT1 | USERDUZ, COUNT | 1^COUNT^OK + rows |
| P11 | ZVE PATIENT DECEASED | DEAD^ZVEPAT1 | DFN, DEATHDT, SOURCE, ACTION | 1^OK^DFN^date |

### ADT Domain (4 RPCs → ZVEADT.m)

| # | RPC Name | Tag^Routine | Input | Output |
|---|----------|-------------|-------|--------|
| P12 | ZVE ADT ADMIT | ADMIT^ZVEADT | DFN, WARDIEN, ROOMBED, params... | 1^MOVIEN^dt^ward^bed |
| P13 | ZVE ADT DISCHARGE | DISCH^ZVEADT | DFN, DIAGCODE, DISPOSITION | 1^MOVIEN^dt^disp |
| P14 | ZVE ADT TRANSFER | TRANS^ZVEADT | DFN, TOWARDIEN, TOROOMBED | 1^MOVIEN^dt^from^to |
| P15 | ZVE ADT CENSUS | CENSUS^ZVEADT | WARDIEN, PENDING, MAX | 1^COUNT^OK + rows |

## VHA Directive 6500 Enforcement (ZVEADMN1.m)

The `ZVE PARAM SET` RPC enforces these mandatory limits:

| Parameter | Min Value | Max Value | Directive |
|-----------|-----------|-----------|----------|
| AUTOLOGOFF (session timeout) | 60 seconds | 900 seconds (15 min) | VHA Directive 6500 §5.a |
| LOCKOUT ATTEMPTS | 1 | 5 | VHA Directive 6500 §5.b |
| PASSWORD EXPIRATION | 1 day | 90 days | VHA Directive 6500 §5.c |

## ORES/ORELSE Mutual Exclusion (ZVEADMN1.m)

The `ZVE KEY ASSIGN` RPC enforces mutual exclusion between ORES (physician order entry) and ORELSE (nurse/non-physician order entry). A user cannot hold both keys simultaneously. This is enforced at the M routine level — the RPC will reject the assignment with an error message if conflict is detected.

## Context Options

### ZVE ADMIN CONTEXT (B-type, File #19)
Contains: All 15 admin RPCs + 6 existing ZVEUSMG RPCs = 21 RPCs total

### ZVE PATIENT CONTEXT (B-type, File #19)
Contains: All 11 patient RPCs + 4 ADT RPCs = 15 RPCs total

## Output Format Convention

All Wave 1 RPCs use the RPC Broker type=2 (ARRAY) return pattern. The broker calls `D TAG^ROUTINE(.R,params)` and reads from the `R` array:

```mumps
; Success: S R(0)="1^OK" or S R(0)="1^COUNT^OK" (header), S R(1..N)=data
; Failure: S R(0)="0^error message"
```

**CRITICAL:** Do NOT use `W "text"` — stdout is NOT captured by the RPC broker for type=2 RPCs. All output must be stored in the `R` parameter array.

The Node.js adapter parses this via `line0.startsWith('1^')` in `callZveRpc()`, and `zveOutcome()` classifies results as `ok`, `missing`, `noop`, or `fail`.

## Installation Steps

```mumps
; SSH into VistA Docker container
; Copy routines to /opt/vista/r/
; Then from M command line:

; 1. Link all routines
ZLINK "ZVEADMIN","ZVEADMN1","ZVEPAT","ZVEPAT1","ZVEADT","ZVECTX2","ZVEINSTALL"

; 2. Run the master installer
D RUN^ZVEINSTALL

; 3. Verify
D VERIFY^ZVEINSTALL
```

## Audit Trail

All write operations log to `^XTMP("ZVE-AUDIT")` via `AUDITLOG^ZVEADMIN` with:
- 3-year automatic purge via `$$FMADD^XLFDT`
- Format: `^XTMP("ZVE-AUDIT",DUZ,NOW)=ACTION^IEN^DETAIL`
- Actions logged: KEY-ASSIGN, KEY-REMOVE, ESIG-CLEAR, PARAM-SET, DIV-ASSIGN, DIV-REMOVE, PAT-REG, PAT-EDIT, INS-ADD, INS-VERIFY, MEANS-INIT, FLAG-ASSIGN, FLAG-INACT, DECEASED, DEATH-VERIFY, ADT-ADMIT, ADT-DISCH, ADT-TRANS, USER-EDIT, USER-TERM, USER-RENAME

## Files Modified/Created

### New Files (overlay/routines/)
- `ZVEADMIN.m` — Admin user management RPCs
- `ZVEADMN1.m` — Admin keys/params/roles/divisions RPCs
- `ZVEPAT.m` — Patient registration/demographics RPCs
- `ZVEPAT1.m` — Patient flags/search/duplicate/deceased RPCs
- `ZVEADT.m` — ADT admit/discharge/transfer/census RPCs
- `ZVECTX2.m` — Context option creation + registration
- `ZVEINSTALL.m` — Master installation script

### Support Files
- `RPC-INSTALLATION-LOG.md` — This document

## Quality Audit (Post-Write Pass)

**Date:** Performed immediately after Wave 1 code was written.

### Audit Scope
1. **Sanity Check** — Wiring, hardcoded data, reachability, contracts, runtime
2. **Feature Integrity Check** — End-to-end flow, edge cases, dead code, gap analysis
3. **System Regression Check** — No breakage, consistent contracts, aligned expectations

### Findings: 32 issues found across 7 files

| Severity | Count | Fixed |
|----------|-------|-------|
| BUG (data integrity) | 6 | 6/6 |
| WARN (correctness/safety) | 19 | 19/19 |
| STYLE (cosmetic) | 7 | 7/7 |

### Critical Bugs Fixed

| # | File | Bug | Fix |
|---|------|-----|-----|
| 1 | ZVEADMIN.m | `FILE^DIE` TERM used external "YES" instead of internal code `1` | Changed to internal `1`, flag to `"K"` |
| 2 | ZVEADMIN.m | `^XTMP` audit header perpetual purge-date rollforward | Guarded with `$D` check |
| 3 | ZVEADMN1.m | `$O(^VA(200,x,51,""),-1)+1` IEN overwrite when "B" cross-ref is last subscript | Changed to `+$O(.."A"),-1)+1` |
| 4 | ZVEADMN1.m | Same `$O` IEN overwrite in DIVASN (division subfile) | Same fix |
| 5 | ZVEPAT.m | EMAIL and CELL PHONE both mapped to field .133 | EMAIL remapped to .135 |
| 6 | ZVEPAT.m | Same `$O` IEN overwrite in insurance ADD subfile | Same fix |
| 7 | ZVEINSTALL.m | Dead no-op loop scanning entire `^DIC(9.8,"B")` with no body | Removed |

### Other Fixes Applied

- **ZVEADMIN.m**: Removed 48-line dead LIST code (unreachable after LIST2 was registered); removed unused `N DUZ2`; added `$G()` on bare global refs; added `K ^VA(200,x,51)` to sync with `^XUSEC` cleanup on termination; changed sign-on log from wrong `^XUSEC(0)` to correct `^%ZUA(3.081)`; used `$I()` atomic increment for audit sequence numbers; added user existence check in RENAME
- **ZVEADMN1.m**: Added `N CONFLICT` in KEYASSN; added subfile header updates in KEYASSN/KEYREM/DIVASN ADD/DIVASN REMOVE; added user existence check in ESIGMGT; added lower-bound VHA 6500 validation (AUTOLOGOFF min 60s, LOCKOUT min 1, PASSWORD min 1 day); added `N REJECT` to prevent stale state; removed "DEFAULT" from DIVASN action comment
- **ZVEPAT.m**: Added subfile header update in insurance ADD; clarified COIEN reuse comment in VERIFY
- **ZVEPAT1.m**: Fixed SRCHSSN/SRCHDOB to loop over ALL DFNs per name (was only checking first); added `$G(DUZ)` in RECLOG
- **ZVEADT.m**: Added MAX parameter (default 500) to CENSUS to prevent unbounded `^DPT` scan; documented direct global SET pattern on `^DPT(DFN,.1)` in ADMIT/DISCH/TRANS

### Server Integration Status

**Status: FULLY DEPLOYED AND WIRED (April 2026)**

All 30 Wave 1 RPCs are deployed to VistA and wired into `server.mjs` with "try ZVE first, fall back to DDR" pattern.

#### Deployment Bugs Found and Fixed

| # | Bug | Root Cause | Fix |
|---|-----|------------|-----|
| 1 | All RPCs returned empty data via API | M routines used `W "text"` (stdout) but RPC broker type=2 reads `R` array | Converted all 5 routines from `W` to `S R(n)=` pattern |
| 2 | Wave 1 RPCs not in broker context | RPCs weren't added to "OR CPRS GUI CHART" context option | Created ZVECTXF.m to add all 21 RPCs |
| 3 | DIVLIST returned 0 divisions | Used `^DIC(40.8)` but File 40.8 data stored in `^DG(40.8)` | Changed global reference |
| 4 | PARAMGT returned empty values | Used wrong field numbers (7, 4.03, 4.02, 4.01) for KSP fields | Corrected to 210, 202, 214, 230 per DD |
| 5 | PARAMST failed to file AUTOLOGOFF | Same field number bug (tried field 7, doesn't exist) | Corrected to field 210 |
| 6 | PUT /users rejected ZVE-supported fields | DDR allow-list gate blocked TITLE(8), SERVICE(29), etc. | Expanded ALLOW object to 16 fields |

#### API Verification Results (Phase 8)

| Endpoint | Method | ZVE RPC | Source | Status |
|----------|--------|---------|--------|---------|
| /users | GET | ZVE USER LIST | zve | ✅ PASS (200 users) |
| /users/:id | GET | ZVE USER DETAIL | zve | ✅ PASS |
| /users/:id | PUT | ZVE USER EDIT | zve | ✅ PASS |
| /key-inventory | GET | ZVE KEY LIST | zve | ✅ PASS (689 keys) |
| /divisions | GET | ZVE DIVISION LIST | zve | ✅ PASS (3 divisions) |
| /roles | GET | ZVE ROLE TEMPLATE | zve | ✅ PASS |
| /params/kernel | GET | ZVE PARAM GET | zve | ✅ PASS (8 params) |
| /params/kernel | PUT | ZVE PARAM SET | zve | ✅ PASS |
| /patients | GET | ZVE PATIENT SEARCH EXTENDED | zve | ✅ PASS |
| /patients/:dfn | GET | ZVE PATIENT DEMOGRAPHICS | zve | ✅ PASS |
| /patients/:dfn/flags | GET | ZVE PATIENT FLAGS | zve | ✅ PASS |
| /census | GET | ZVE ADT CENSUS | zve | ✅ PASS |
| /patients/recent | GET | ZVE RECENT PATIENTS | zve | ✅ PASS |
| /auth/session | GET | ZVE USER DETAIL | zve | ✅ PASS |
| /audit/fileman | GET | ZVE USMG AUDLOG | vista | ✅ PASS |
| /audit/error-log | GET | ZVE ADMIN AUDIT | zve | ✅ PASS |
| /audit/signon-log | GET | ZVE ADMIN AUDIT | zve | ✅ PASS |

#### Frontend Verification (Phase 9)

All endpoints verified through Vite proxy (localhost:3000/api/ta/v1/*) — all returning `source: zve`.
