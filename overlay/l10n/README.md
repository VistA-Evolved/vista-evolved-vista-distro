# Language Pack Structure — VistA Evolved Distro

This directory contains multilingual language packs for the terminal-first
VistA product. Each language pack is a self-contained set of M globals that
can be loaded into a running VistA instance to enable that language.

## Structure

```
overlay/l10n/
  README.md           — This file
  PACK-SPEC.md        — Language pack specification
  ZVELPACK.m          — Language pack installer/loader routine
  shared/             — Shared infrastructure (not language-specific)
  ko/                 — Korean language pack
  es/                 — Spanish language pack (starter)
  docs/               — Implementation docs for this subsystem
```

## What Belongs in a Language Pack

1. **LANGUAGE file (.85) formatting nodes** — M code for date, number,
   case-folding, ordinal display in that language
2. **DIALOG (.84) translations** — Translated prompts, messages, labels
3. **Menu translation assets** — Translated menu item names (File 19)
4. **Metadata** — `manifest.json` with version, coverage, source info
5. **Installer** — The shared `ZVELPACK.m` routine loads any pack

## How Packs Are Loaded

```
; Load Korean pack into running VistA:
D LOAD^ZVELPACK("ko")

; Verify a pack:
D VERIFY^ZVELPACK("ko")
```

## Current State

| Pack | Level | Dialog Coverage | Formatting | Status |
|------|-------|----------------|------------|--------|
| ko   | L2    | 34/2698 (1.3%) | DD, FMTE   | Baseline from Plan VI |
| es   | L1    | 0/2698         | Starter    | New — formatting nodes only |
