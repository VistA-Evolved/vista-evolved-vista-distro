# Notion Sync — VistA Evolved Distro

> **Repo is canonical. Notion is the mirror.** Never edit in Notion and push to repo.

## How it works

1. Approved content from the distro docs is exported to Notion for stakeholder visibility.
2. The export script reads from the repo and writes to Notion via the Notion API.
3. Notion pages are read-only mirrors — edits in Notion are overwritten on next sync.

## Setup

1. Copy `notion-sync-config.example.json` to `notion-sync-config.json` (gitignored).
2. Fill in your Notion API token and target database/page IDs.
3. Run `node scripts/notion/export-approved-content.mjs`.

## Config

See `notion-sync-config.example.json` for the schema.

## Policy

See `docs/reference/notion-sync-policy.md` (to be created when sync is active).
