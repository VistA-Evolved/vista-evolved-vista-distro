# Multilingual Architecture & Language-Pack Inventory

> **Scope**: Terminal-first VistA distro only. No control-plane, no GUI, no scaffolding.
> **Date**: 2025-07-14
> **Container**: `local-vista-utf8` (YottaDB r2.02, `ydb_chset=UTF-8`, Plan VI snapshot)
> **Probes**: `ZVEMLI.m`, `ZVEMLI2.m` — live introspection of running globals and routines.

---

## A. VistA Localization Infrastructure Already Present

### A1. LANGUAGE File (File .85) — The Language Registry

**539 language entries** registered, covering ISO 639 codes from Afar to Zuni.
This is a lookup table mapping IEN → language name, 2-letter code, 3-letter code.

Key entries for our product scope:

| IEN | Language   | ISO-2 | ISO-3 | Formatting Data |
|-----|-----------|-------|-------|-----------------|
| 1   | ENGLISH   | EN    | ENG   | **Full** — CRD, DD, FMTE, LC, ORD, TIME, UC |
| 2   | GERMAN    | DE    | DEU   | **Full** — CRD, DD, LC, ORD, TIME, UC |
| 3   | SPANISH   | ES    | SPA   | **None** — only header node |
| 4   | FRENCH    | FR    | FRA   | **None** — only header node |
| 5   | FINNISH   | FI    | FIN   | **Partial** — DD, ORD only |
| 75  | CHINESE   | ZH    | ZHO   | **None** — only header node |
| 168 | JAPANESE  | JA    | JPN   | **None** — only header node |
| 198 | KOREAN    | KO    | KOR   | **Plan VI** — DD, FMTE (via `$$FMTE^UKOUTL`) |
| 475 | TAGALOG   | TL    | TGL   | **None** — only header node |
| 514 | VIETNAMESE| VI    | VIE   | **None** — only header node |

**Formatting routines** are executable M code stored in the LANGUAGE file at named
subscripts. They control how dates, numbers, case-folding, and ordinals display
for that language. Example: German `DD` node produces `27.03.2025` instead of
`MAR 27,2025`. Korean `DD`/`FMTE` nodes call `$$FMTE^UKOUTL` for ISO 8601 dates
(`2025-03-27`).

### A2. DIALOG File (File .84) — The Translatable String Registry

**2,698 dialog entries** in the current distro. These are VistA's translatable
strings — prompts, error messages, help text, format directives.

**Translation data structure:**
- Subscript 2: Base English text (always present)
- Subscript 4,LANG_IEN,1: Translated text per language

**Actual translations present:**

| Language | IEN | Dialog Entries Translated | Coverage of 2,698 |
|----------|-----|--------------------------|-------------------|
| Korean   | 198 | **34**                   | 1.3%              |
| German   | 2   | **1** (YES/NO only)      | 0.04%             |
| Spanish  | 3   | **0**                    | 0%                |
| French   | 4   | **0**                    | 0%                |
| All others | — | **0**                    | 0%                |

Korean is the ONLY language with meaningful dialog translations. German has only
the YES/NO translation (Dialog 7003: `y:YES;n:NO` → `j:JA;n:NEIN`).

### A3. Data Dictionary Language Subscripts

**Zero DD-level translations exist.** The infrastructure is fully present in
`DIALOGZ.m` for three DD subscripts:

| Subscript | Purpose                          | Fields Populated |
|-----------|----------------------------------|-----------------|
| .007      | Set-of-codes display translations | **0**           |
| .008      | Field label translations          | **0**           |
| .009      | Help text translations            | **0**           |

**Zero file-level name translations exist.** `^DIC("ALANG",...)` is empty.

### A4. The DUZ("LANG") Dispatch Mechanism

**363 routines** in the distro reference `DUZ("LANG")`. The dispatch chain is:

1. **Login** (`DUZ^XUS1A`): Sets `DUZ("LANG")=$P(XOPT,U,7)`
2. **XOPT resolution** (`XOPT^XUS1A`):
   - Start: site-level KSP `^XTV(8989.3,1,"XUS")` piece 7
   - Override: per-user `^VA(200,DUZ,200)` piece 7 (if set)
3. **Runtime dispatch** (`BLD^DIALOG`, `$$EZBLD^DIALOG`):
   - If `DILANG>1`: read from `^DI(.84,D0,4,DILANG,1,...)`
   - If no translation found or `DILANG<=1`: read from `^DI(.84,D0,2,...)`
4. **External formatting** (`DILIBF`, `DIALOGU`):
   - If `DUZ("LANG")>1`: use LANGUAGE file (.85) formatting routines
   - Fallback: English formatting

**Current state**: `DUZ("LANG")` = empty/0 for all users → everything defaults
to English. The VEHU snapshot shipped with site-level KSP piece 7 = 198 (Korean),
which `ZVEINIT.m` intentionally clears.

### A5. Key Language-Aware Subsystems (by routine count)

| Namespace | Package                    | Routines with DUZ("LANG") |
|-----------|----------------------------|--------------------------|
| DI*       | FileMan                    | ~22                      |
| IBX*      | IB Expert System (billing) | ~40+                     |
| MCAR*     | Clinical Assessment/Reports| ~50+                     |
| MCOB*     | Clinical Observations      | ~15+                     |
| DVB*      | Disability Board           | ~6                       |
| ENPLP*    | Encounter/Pharmacy         | ~8                       |
| FB*       | Fee Basis                  | ~3                       |
| GMP/GMV   | Problems/Vitals            | ~3                       |
| LR*       | Lab                        | ~2                       |
| XUS*      | Kernel Sign-on             | ~3                       |
| Other     | Various                    | ~211                     |
| **Total** |                            | **363**                  |

This is a deeply pervasive mechanism. It is NOT a bolted-on feature — language
awareness is woven into FileMan's core read/write/display cycle, Kernel's sign-on,
and major clinical packages.

---

## B. Current Distro Multilingual Truth

### B1. What Works Today (No Additional Code)

If you set `DUZ("LANG")=198` (Korean) in the current distro, the following
would change at the terminal:

1. **34 dialog prompts** switch to Korean, including:
   - YES/NO prompts: "예" / "아니오"
   - Menu selection prompt: "|1| |2|의|3| 옵션 선택:" (instead of "Select ... Option:")
   - "Answer with 'Yes' or 'No'" → "'예'또는 '아니오'를 입력하십시오."
2. **Date display** switches to ISO 8601 format (`2025-03-27`) via `$$FMTE^UKOUTL`
3. **Date input parsing** respects Korean input mode (node 20.2)

### B2. What Does NOT Work (Even with DUZ("LANG") Set)

| Area | Problem | Root Cause |
|------|---------|------------|
| Menu item names | Still English | Names stored in File 19 field 1, not dialog-driven |
| FileMan field labels | Still English | `.008` subscripts empty |
| FileMan help text | Still English | `.009` subscripts empty |
| Set-of-codes display | Still English | `.007` subscripts empty |
| File names | Still English | `^DIC("ALANG",...)` empty |
| Most prompts | Still English | 2,664 of 2,698 dialogs untranslated (98.7%) |
| Error messages | Still English | Application-level errors not in DIALOG file |
| Package-specific text | Still English | Hard-coded W "text" in 99%+ of routines |

### B3. What the UTF-8 Runtime Gives Us (Prerequisite, Not Solution)

The Phase 3 UTF-8 build lane provides:
- **Storage**: `$ZCHSET=UTF-8` — M globals store/retrieve any Unicode codepoint
- **String ops**: `$LENGTH` = character count, `$ZLENGTH` = byte count
- **Display**: xterm.js renders CJK, Hangul, Cyrillic, Thai, etc. correctly
- **Terminal**: `LC_ALL=en_US.UTF-8`, SSH charset negotiation works

This is the **necessary byte-level foundation** but provides ZERO application-level
multilingual behavior. A Korean user would see Korean characters render correctly
in patient names, free-text notes, and lab values — but all VistA system prompts,
menus, and labels remain English.

---

## C. Plan VI Relevant Changes

### C1. What Plan VI Added (Sam Habiel, 2018-2019)

| Routine | Purpose | Status in Distro |
|---------|---------|-----------------|
| `UKOUTL.m` | Korean date formatting (`YYYY-MM-DD`) | Present, wired |
| `UKOP6LEX.m` | KCD-7 lexicon loader (replaces ICD-10) | Present, not run |
| `UKOP6LEX1.m` | KCD-7 as additional terminology | Present, not run |
| `UKOP6TRA.m` | Automated menu/routine translation framework | Present, runnable |

### C2. UKOP6TRA.m Translation Pipeline (The Key Innovation)

This routine is a **complete automated translation system** with these capabilities:

1. **`MENUDLG`** — Scans File 19 (menu options), creates a DIALOG (.84) entry
   for every menu item's text and description. IEN scheme: `19000 + (menuIEN/100000)*1`
   for text, `*35` for description.

2. **`TRAMENU(menuName)`** — Takes a menu tree name (e.g., "XUCORE"), finds all
   sub-menus, and translates each by calling:

3. **`$$TRAN(string,from,to)`** — Calls Microsoft Cognitive Services Translator
   API v3.0. Requires env var `msTranslateAPIKey`. Returns translated string.

4. **`APPLYONE(menuIEN)`** — Writes translated text back to File 19 field 1
   (menu text) so menus display in the target language.

5. **`TRAROU`** — Interactive routine translator. Parses M source code, finds
   quoted strings >1 char with lowercase letters, offers to create Dialog entries
   and auto-translate them.

6. **`RESTORE`** — Reverses translation, restoring English menu text.

7. **`TRDLG` / `TRDLGRNG`** — Translates individual dialog entries or ranges.

### C3. Key Implication

The Plan VI framework can translate ANY language, not just Korean. The `$$TRAN`
API call uses the 2-letter ISO code from the LANGUAGE file. Setting `DUZ("LANG")`
to any language IEN and running `TRAMENU` would auto-translate menus to that language.

The **34 Korean dialog translations** in the current distro are the output of a
partial run of this pipeline. The full pipeline was not completed — only core
prompts (YES/NO, menu selection, basic input validation) were translated.

### C4. What Plan VI Did NOT Do

- Did not translate FileMan DD labels/help text (`.007`/`.008`/`.009` empty)
- Did not translate file-level names (`^DIC("ALANG",...)` empty)
- Did not add LANGUAGE file formatting routines for Spanish, French, Tagalog, etc.
- Did not create a language-pack packaging/deployment mechanism
- Did not add per-user language preference UI
- Did not address hard-coded Write statements in application routines

---

## D. Terminal Multilingual Architecture Matrix

### D1. Layer Classification

| Layer | Component | Mechanism | Current State | Effort to Localize |
|-------|-----------|-----------|---------------|-------------------|
| **L0 Runtime** | YottaDB UTF-8 | `$ZCHSET=UTF-8` | **DONE** | N/A |
| **L0 Runtime** | Terminal charset | `LC_ALL=en_US.UTF-8` + xterm.js | **DONE** | N/A |
| **L1 Formatting** | Date display | `.85` LANGUAGE file DD/FMTE nodes | **English + German + Korean** | Add M code per language |
| **L1 Formatting** | Number display | `.85` LANGUAGE file CRD node | **English + German only** | Add M code per language |
| **L1 Formatting** | Case folding | `.85` LANGUAGE file UC/LC nodes | **English + German only** | Add M code per language |
| **L1 Formatting** | Ordinals | `.85` LANGUAGE file ORD node | **English + German + Finnish** | Add M code per language |
| **L2 Core Prompts** | YES/NO | Dialog 7001/7003 | **Korean only** | 1 dialog entry per language |
| **L2 Core Prompts** | Menu "Select..." | Dialog 19001/19002 | **Korean only** | 1 dialog entry per language |
| **L2 Core Prompts** | Input validation | Dialogs 8040/9040 etc. | **Korean only (34 total)** | ~34 dialog entries per language |
| **L3 FileMan** | Field labels | DD `.008` subscript | **EMPTY** | 1 entry per field per language |
| **L3 FileMan** | Help text | DD `.009` subscript | **EMPTY** | 1 entry per field per language |
| **L3 FileMan** | Set-of-codes | DD `.007` subscript | **EMPTY** | 1 entry per set field per language |
| **L3 FileMan** | File names | `^DIC("ALANG",...)` | **EMPTY** | 1 entry per file per language |
| **L4 Menus** | Menu item names | File 19 field 1 | **English only** | Use UKOP6TRA TRAMENU pipeline |
| **L4 Menus** | Menu descriptions | File 19 field 3.5 | **English only** | Use UKOP6TRA TRAMENU pipeline |
| **L5 Application** | Hard-coded W text | In-routine strings | **English only** | Use UKOP6TRA TRAROU per routine |
| **L5 Application** | Error messages | Mix of DIALOG + hard-coded | **English only** | Audit each package |

### D2. Language Readiness by Target Language

| Language | L0 Runtime | L1 Formatting | L2 Core Prompts | L3 FileMan | L4 Menus | L5 App |
|----------|-----------|---------------|-----------------|-----------|---------|--------|
| English  | ✅ | ✅ Full | ✅ Native | ✅ Native | ✅ Native | ✅ Native |
| Korean   | ✅ | ⚠️ DD/FMTE only | ⚠️ 34/2698 (1.3%) | ❌ | ❌ | ❌ |
| German   | ✅ | ✅ Full | ⚠️ 1/2698 | ❌ | ❌ | ❌ |
| Spanish  | ✅ | ❌ None | ❌ | ❌ | ❌ | ❌ |
| French   | ✅ | ❌ None | ❌ | ❌ | ❌ | ❌ |
| Finnish  | ✅ | ⚠️ DD/ORD | ❌ | ❌ | ❌ | ❌ |
| Tagalog  | ✅ | ❌ None | ❌ | ❌ | ❌ | ❌ |
| Vietnamese| ✅ | ❌ None | ❌ | ❌ | ❌ | ❌ |

---

## E. Multilingual Product Levels

### Level 0: UTF-8 Safe (CURRENT STATE)
- **What**: Runtime stores/displays any Unicode character correctly
- **User experience**: All system text in English; patient data, free-text,
  and imported data render correctly in any script
- **Effort**: Done (Phase 3 UTF-8 build lane)
- **Value**: Correct rendering and storage of multilingual clinical data

### Level 1: Locale-Formatted
- **What**: Dates, numbers, ordinals display in locale conventions
- **User experience**: System text still English, but `MAR 27,2025` → `27.03.2025`
  (German), `2025-03-27` (Korean), `27/03/2025` (French)
- **Effort per language**: Write 5-7 M code nodes in LANGUAGE file (.85)
- **Prerequisite**: DUZ("LANG") mechanism already works; just need formatting code
- **Priority targets**: Spanish, French, Tagalog (no formatting code today)

### Level 2: Core Prompt Translated
- **What**: Levels 0+1 plus YES/NO, "Select...Option:", basic input prompts
- **User experience**: The 30-50 most-seen prompts in the target language;
  FileMan field values and menu items still English
- **Effort per language**: ~50 Dialog file entries (can use UKOP6TRA $$TRAN API)
- **Prerequisite**: Level 1 formatting + Dialog entries populated
- **Korean is already here** (partially — 34 of ~50 core prompts)

### Level 3: Menu Translated
- **What**: Levels 0-2 plus all menu item names in target language
- **User experience**: Menu tree navigation in target language; FileMan field
  labels and data-entry prompts still English
- **Effort per language**: Run `MENUDLG^UKOP6TRA` then `TRAMENU^UKOP6TRA` per menu
  tree. Automated via MS Translator API. ~100-500 menus depending on scope.
- **Prerequisite**: Level 2 + API key + review of automated translations

### Level 4: FileMan Localized
- **What**: Levels 0-3 plus field labels, help text, set-of-codes in target language
- **User experience**: Data entry screens show translated labels and help;
  application-level messages still English
- **Effort per language**: Populate DD `.007`/`.008`/`.009` subscripts. Can be
  automated (DIALOGZ.m has the framework). Thousands of fields across hundreds of files.
- **Prerequisite**: Level 3 + massive translation effort + clinical review

### Level 5: Package Localized
- **What**: Full application-level localization per VistA package
- **User experience**: Near-native language experience within specific packages
- **Effort**: Audit each routine for hard-coded text; convert to Dialog references
  (TRAROU^UKOP6TRA can assist); translate all dialog entries
- **Prerequisite**: Level 4 + per-package commitment
- **Note**: Some packages (MCAR, IBX) already check DUZ("LANG") extensively

---

## F. What Must Still Be Built (by level)

### For Level 1 (Locale-Formatted) — Minimal Effort, High Value
1. **LANGUAGE file formatting nodes** for target languages (Spanish, French, Tagalog,
   Vietnamese). Each needs: `DD` (date display), `FMTE` (formatted external),
   `CRD` (cardinal numbers), `LC`/`UC` (case folding), `ORD` (ordinals), `TIME`.
   Model: copy `^DI(.85,2,*)` (German) and adapt.
2. **Per-user language preference** at login: `^VA(200,DUZ,200)` piece 7 already
   works. Need a way to set it (FileMan edit or custom option).

### For Level 2 (Core Prompt Translated) — Moderate Effort
1. **Complete Korean dialogs**: 34 exist; ~16 more needed for full core coverage.
2. **Translate ~50 core dialogs** per new target language. The `$$TRAN^UKOP6TRA`
   API is ready — just needs an API key and review.
3. **Language pack packaging**: A mechanism to export/import a set of Dialog (.84)
   sub-4 translations as a single deployable unit.

### For Level 3 (Menu Translated) — Semi-Automated
1. `MENUDLG^UKOP6TRA` already creates dialog entries for all menus.
2. `TRAMENU^UKOP6TRA` already auto-translates via MS API.
3. **What's missing**: Quality review of automated translations, scope selection
   (which menu trees to translate), and a rollback mechanism (RESTORE exists).

### For Level 4+ (FileMan/Package) — Large Effort, Deferred
1. Not recommended for near-term terminal product.
2. The infrastructure (`DIALOGZ.m`, `.007`/`.008`/`.009` DD subscripts) is complete
   and ready — the bottleneck is translation data, not code.

---

## G. Architecture Decisions Needed

| # | Decision | Options | Recommendation |
|---|----------|---------|---------------|
| 1 | Default language for distro | English (current) vs. configurable at init | Keep English default; add init-time `DUZ("LANG")` configuration |
| 2 | Translation API provider | MS Translator (Plan VI), Google Translate, offline | Start with MS Translator (pipeline exists); evaluate offline for air-gapped |
| 3 | Language pack format | M global export/import vs. JSON manifest vs. overlay routine | M global import (native to VistA); one `.zwr` file per language per level |
| 4 | Which languages first | Korean (34 done), Spanish, Tagalog, French | Korean to Level 2 completion; Spanish new to Level 2 |
| 5 | Menu translation scope | Full menu tree vs. clinical-only menus | Clinical-only (ORCLINIC, ORWRT, etc.) — most terminal users never see admin menus |
| 6 | Per-user vs. site-wide | DUZ("LANG") per user vs. KSP site default | Both: site default for deployment, per-user override for multilingual facilities |

---

## H. Summary Table

| Item | Count | Source |
|------|-------|--------|
| Languages registered (.85) | 539 | Live probe |
| Dialog entries (.84) | 2,698 | Live probe |
| Korean dialog translations | 34 | Live probe |
| German dialog translations | 1 | Live probe |
| DD field-level translations | 0 | Live probe |
| File name translations | 0 | Live probe |
| Routines checking DUZ("LANG") | 363 | `grep` of runtime routines |
| Languages with formatting code | 3 (EN, DE, KO) + 1 partial (FI) | Live probe |
| Plan VI routines | 4 (UKOUTL, UKOP6LEX, UKOP6LEX1, UKOP6TRA) | Container inspection |
| Overlay routines touching lang | 2 (XUS1A, ZVEINIT) | Overlay inspection |

**Bottom line**: VistA has a **mature, deeply-integrated localization framework**
(LANGUAGE file, DIALOG file, DIALOGZ.m DD translations, DUZ("LANG") dispatch in
363 routines). Plan VI added a **working automated translation pipeline** and
**Korean-specific** date formatting + 34 core prompt translations. The framework
is comprehensive but the **translation data is nearly empty** — the bottleneck is
populating translations, not building infrastructure.
