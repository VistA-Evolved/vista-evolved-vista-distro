# Shared Language-Pack Infrastructure

This directory holds assets shared across all language packs.

## Files

- `ZVELPACK.m` — Language pack installer/verifier routine (lives in overlay/routines/)
- This README

## Design Principle

Language packs are **data packs, not code packs**. The shared infrastructure
provides one installer routine that can load any conforming language pack.
Each pack provides its own:

- `formatting.m` — LANGUAGE file (.85) node loader
- `dialogs.m` — DIALOG file (.84) translation loader

The installer just orchestrates calling them in order.
