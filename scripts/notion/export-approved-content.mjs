#!/usr/bin/env node
/**
 * export-approved-content.mjs — Export approved distro docs to Notion
 *
 * Repo is canonical. Notion is mirror only.
 *
 * Usage: node scripts/notion/export-approved-content.mjs
 *
 * Requires:
 *   - notion-sync-config.json (see notion-sync-config.example.json)
 *   - NOTION_TOKEN environment variable or config file token
 */

import { readFileSync, existsSync } from "fs";
import { join, dirname } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const CONFIG_PATH = join(__dirname, "notion-sync-config.json");

if (!existsSync(CONFIG_PATH)) {
  console.error("ERROR: notion-sync-config.json not found.");
  console.error("Copy notion-sync-config.example.json and fill in credentials.");
  process.exit(1);
}

const config = JSON.parse(readFileSync(CONFIG_PATH, "utf-8"));
const token = process.env.NOTION_TOKEN || config.token;

if (!token) {
  console.error("ERROR: No Notion API token found.");
  process.exit(1);
}

console.log("Notion sync scaffold loaded. Implement export logic per docs/reference/notion-sync-policy.md.");
console.log(`Target database: ${config.targetDatabaseId || "(not configured)"}`);
console.log("Status: scaffold only — real sync not yet implemented.");
