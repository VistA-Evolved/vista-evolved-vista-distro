# Language Selection Mechanism

> How the terminal-first VistA product sets and uses the active language.

## How It Works (Already Built Into VistA)

Language selection is a **login-time mechanism** controlled by `DUZ("LANG")`.
No new code is needed to make it work — only data.

### The Dispatch Chain

```
Login → XUS1A XOPT tag
  1. Read site default: ^XTV(8989.3,1,"XUS") piece 7 = language IEN
  2. Read user override: ^VA(200,DUZ,200) piece 7 = language IEN (if set)
  3. Set DUZ("LANG") = winner of above (user overrides site)
  4. All subsequent DIALOG calls check DUZ("LANG")
```

### Where DUZ("LANG") Gets Checked

When `DUZ("LANG")` > 1 (non-English), these dispatch paths activate:

| Component | Entry Point | What Changes |
|-----------|------------|-------------|
| **DIALOG.m** `BLD` | `$$EZBLD^DIALOG(IEN,...)` | Reads subscript 4 (translation) instead of subscript 2 (English) |
| **DIALOGU.m** | `$$OUT^DIALOGU(...)` | Uses LANGUAGE file (.85) formatting routines |
| **DILIBF.m** | `$$FMTE^DILIBF(...)` | Delegates date formatting to language-specific DD/FMTE nodes |
| **363 routines** | Various | Each checks DUZ("LANG") for language-specific behavior |

## How to Set Language

### Site Default (All Users)

Set Kernel System Parameters (file 8989.3) XUS piece 7 to the language IEN:

```mumps
; Set site default to Korean (IEN 198):
S $P(^XTV(8989.3,1,"XUS"),"^",7)=198

; Set site default to Spanish (IEN 3):
S $P(^XTV(8989.3,1,"XUS"),"^",7)=3

; Clear site default (English):
S $P(^XTV(8989.3,1,"XUS"),"^",7)=""
```

**Effect**: Every user who logs in without a personal language preference
will use this language.

### Per-User Override

Set the user's language preference in the NEW PERSON file (200):

```mumps
; Set user DUZ=1 to Spanish (IEN 3):
S $P(^VA(200,1,200),"^",7)=3

; Set user DUZ=1 to Korean (IEN 198):
S $P(^VA(200,1,200),"^",7)=198

; Clear user preference (follow site default):
S $P(^VA(200,1,200),"^",7)=""
```

**Effect**: This user always gets their preferred language, regardless of
the site default.

### At Login Time

The login routine `XOPT^XUS1A` resolves the effective language:
1. Start with site KSP piece 7
2. If user has `^VA(200,DUZ,200)` piece 7 set → override
3. Store result in `DUZ("LANG")`

### Language IENs for Target Languages

| Language | IEN | ISO 2 | Status |
|----------|-----|-------|--------|
| English  | 1   | EN    | Default (DUZ("LANG")="" or 0 or 1) |
| German   | 2   | DE    | Formatting nodes present |
| Spanish  | 3   | ES    | Formatting nodes in starter pack |
| French   | 4   | FR    | No formatting nodes yet |
| Korean   | 198 | KO    | Formatting + 34 dialog translations |
| Tagalog  | 475 | TL    | No data yet |
| Vietnamese | 514 | VI  | No data yet |

## Product Integration

### For the Distro Init Routine (ZVEINIT.m)

Currently `ZVEINIT.m` clears the Korean site default that ships with VEHU.
To enable a language pack:

```mumps
; In ZVEINIT.m or a separate ZVELANG.m:
; Set site language after loading a pack:
S $P(^XTV(8989.3,1,"XUS"),"^",7)=<IEN>
```

### For the Language Pack Installer (ZVELPACK.m)

The installer loads formatting nodes and dialog translations, then
optionally sets the site default.

### What Users See

| DUZ("LANG") | Terminal Behavior |
|-------------|------------------|
| "" or 0 or 1 | All English (current default) |
| 198 (Korean) | 34 prompts in Korean, dates as YYYY-MM-DD, rest English |
| 3 (Spanish) | Dates as DD/MM/YYYY, rest English (until dialogs are translated) |

## ZVEINIT.m Integration

The distro's `ZVEINIT.m` currently forces English by clearing KSP piece 7:

```mumps
; Clear KSP language override (piece 7) — VEHU data ships with 198 (Korean)
I $P($G(^XTV(8989.3,1,"XUS")),"^",7)]"",$P($G(^XTV(8989.3,1,"XUS")),"^",7)'=0 D
. S $P(^XTV(8989.3,1,"XUS"),"^",7)=""
```

This is correct for the English-default product. When a language pack is
loaded, the installer can set the site default after ZVEINIT has run.
The per-user override always takes precedence regardless.
