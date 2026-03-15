# Language Pack Specification

> Version: 1.0
> Date: 2025-07-14

## Pack Directory Layout

Each language pack lives in `overlay/l10n/<iso2>/` where `<iso2>` is the
lowercase ISO 639-1 two-letter code (e.g., `ko`, `es`, `de`, `fr`).

```
overlay/l10n/<iso2>/
  manifest.json        — Pack metadata
  formatting.m         — LANGUAGE file (.85) formatting node loader
  dialogs.m            — DIALOG file (.84) translation loader
  menus.m              — Menu (File 19) translation loader (when applicable)
  routines/            — Any language-specific M routines (e.g., UKOUTL.m)
```

## manifest.json Schema

```json
{
  "packVersion": "1.0.0",
  "language": {
    "name": "KOREAN",
    "iso2": "ko",
    "iso3": "kor",
    "ien": 198
  },
  "level": 2,
  "coverage": {
    "formatting": {
      "DD": true,
      "FMTE": true,
      "CRD": false,
      "LC": false,
      "UC": false,
      "ORD": false,
      "TIME": false
    },
    "dialogs": {
      "total": 34,
      "categories": {
        "yesno": 4,
        "menuPrompts": 20,
        "signOn": 2,
        "coverSheet": 8
      }
    },
    "menus": {
      "translated": 0,
      "candidate": true
    }
  },
  "source": "Plan VI (Sam Habiel 2018-2019)",
  "requires": {
    "ydbChset": "UTF-8",
    "languageFileIen": true
  }
}
```

## Level Definitions

| Level | Name | What It Provides |
|-------|------|-----------------|
| 0 | UTF-8 Safe | Runtime renders any Unicode. No app-level changes. |
| 1 | Locale-Formatted | Dates, numbers, ordinals in locale convention. |
| 2 | Core Prompt Translated | L1 + YES/NO, menu prompts, basic input. |
| 3 | Menu Translated | L2 + menu item names in target language. |
| 4 | FileMan Localized | L3 + field labels, help text, set-of-codes. |
| 5 | Package Localized | L4 + per-package hard-coded text. |

## Formatting Nodes

Each node in LANGUAGE file (.85) is executable M code stored at a named
subscript. The runtime calls it via `X ^DI(.85,IEN,"DD")` etc.

| Node | Purpose | Example (German) |
|------|---------|-----------------|
| DD | Date display | `27.03.2025` |
| FMTE | Formatted external (date+time) | Dispatches to `DILIBF` |
| CRD | Cardinal numbers | Comma → period for decimals |
| LC | Lowercase | `$TR` mapping |
| UC | Uppercase | `$TR` mapping |
| ORD | Ordinals | `1.` instead of `1ST` |
| TIME | Time display | `10:30:00` |
| 20.2 | Date input mode | Internal date parsing hint |

## Dialog Translation Storage

Translations are stored in DIALOG file (.84) at subscript 4:
```
^DI(.84,<dialogIEN>,4,<langIEN>,0) = <langIEN>
^DI(.84,<dialogIEN>,4,<langIEN>,1,0) = "^^<lineCount>^<lineCount>"
^DI(.84,<dialogIEN>,4,<langIEN>,1,<lineNum>,0) = "<translated text>"
```

## Installer Protocol

The shared `ZVELPACK.m` routine:
1. Reads the manifest to determine language IEN and scope
2. Calls the pack's `formatting.m` to load LANGUAGE file nodes
3. Calls the pack's `dialogs.m` to load DIALOG translations
4. Optionally calls `menus.m` for menu translations
5. Reports what was loaded and any errors

All loaders are idempotent — safe to run multiple times.
