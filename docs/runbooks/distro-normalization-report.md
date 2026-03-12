# Distro normalization report

**Objective:** Normalize migrated process assets so the distro repo is internally consistent and self-contained. No upstream fetch or Docker build. No product code from archive.

---

## Files inspected

| Location | File | Purpose |
|----------|------|---------|
| migrated-process-assets/upstream/ | fetch-worldvista-sources.ps1 | Fetch script (vendor/upstream, vendor/locks) |
| migrated-process-assets/upstream/ | pin-worldvista-sources.ps1 | Pin script (vendor/locks, scripts\upstream) |
| migrated-process-assets/upstream/ | worldvista-sources.config.json | Config (localPath: vendor/upstream/...) |
| migrated-process-assets/runtime/ | healthcheck-local-vista.ps1 | Readiness check (no repo paths) |
| migrated-process-assets/docs/ | runtime-readiness-levels.md | Short reference |
| archive (VistA-Evolved) | show-worldvista-source-status.ps1 | Status helper (vendor\upstream, vendor\locks) |
| .gitignore | — | Had locks/ and *.lock.json ignored |
| docs/reference/ | upstream-source-strategy.md, runtime-truth.md, customization-policy.md | Existing refs |

---

## Files changed

### Created

| File | Purpose |
|------|---------|
| **locks/** | Canonical directory for lock metadata. |
| **locks/.gitkeep** | Placeholder so locks/ is tracked; lock file tracked when present. |
| **scripts/fetch/worldvista-sources.config.json** | Canonical config; `localPath` uses `upstream/VistA-M`, `upstream/VistA`, `upstream/VistA-VEHU-M`. |
| **scripts/fetch/fetch-worldvista-sources.ps1** | Normalized fetch; RepoRoot from script dir; config at `scripts/fetch/`, lock at `locks/`; `-DryRun` added. |
| **scripts/fetch/show-worldvista-source-status.ps1** | Brought from archive; lock at `locks/`, upstream at `upstream/`. |
| **scripts/pin/pin-worldvista-sources.ps1** | Normalized pin; config at `scripts/fetch/`, lock at `locks/`; `-ValidateOnly` added. |
| **scripts/verify/healthcheck-local-vista.ps1** | Normalized from migrated-process-assets; `-ValidatePathsOnly` added. |
| **docs/reference/runtime-readiness-levels.md** | Full reference; links to `scripts/verify/healthcheck-local-vista.ps1`. |

### Modified

| File | Change |
|------|--------|
| **.gitignore** | Removed `locks/` and `*.lock.json` so `locks/worldvista-sources.lock.json` is tracked. Kept `upstream/VistA-M/`, `upstream/VistA/`, `upstream/VistA-VEHU-M/`, `artifacts/` ignored. |
| **docs/reference/upstream-source-strategy.md** | Canonical paths documented: config, lock, fetch/pin/status scripts, overlay. |
| **docs/reference/runtime-truth.md** | Linked to runtime-readiness-levels.md and healthcheck script with `-ValidatePathsOnly`. |
| **migrated-process-assets/README.md** | Updated to state assets are normalized; list normalized locations; old copies superseded. |

### Deleted

| File | Reason |
|------|--------|
| **scripts/fetch/.gitkeep** | Replaced by real scripts and config. |
| **scripts/pin/.gitkeep** | Replaced by real script. |
| **docs/reference/.gitkeep** | Replaced by reference docs. |

---

## Old path assumptions found

| Script / config | Old assumption | New canonical path |
|----------------|----------------|---------------------|
| fetch-worldvista-sources.ps1 | `vendor\locks\worldvista-sources.lock.json` | `locks\worldvista-sources.lock.json` |
| fetch-worldvista-sources.ps1 | Config under `scripts\upstream` | Config at `scripts\fetch\worldvista-sources.config.json` |
| pin-worldvista-sources.ps1 | `vendor\locks\worldvista-sources.lock.json` | `locks\worldvista-sources.lock.json` |
| pin-worldvista-sources.ps1 | Config under `scripts\upstream` | Config at `scripts\fetch\worldvista-sources.config.json` |
| worldvista-sources.config.json | `localPath: "vendor/upstream/VistA-M"` etc. | `localPath: "upstream/VistA-M"` etc. |
| show-worldvista-source-status.ps1 | `vendor\locks\worldvista-sources.lock.json` | `locks\worldvista-sources.lock.json` |
| show-worldvista-source-status.ps1 | `vendor\upstream` directory | `upstream` directory |
| healthcheck-local-vista.ps1 | (none; no repo paths) | Repo root resolved for `-ValidatePathsOnly` from `scripts\verify` |
| $PSScriptRoot in param default | Empty when run as `powershell -File` from some hosts | Fallback: `Split-Path -Parent $MyInvocation.MyCommand.Path`; RepoRoot default in script body |

---

## New canonical paths

| Purpose | Path |
|---------|------|
| Repo root | Resolved from script location (e.g. `scripts\fetch` → parent of parent). |
| Config | `scripts/fetch/worldvista-sources.config.json` |
| Lock file | `locks/worldvista-sources.lock.json` |
| Lock directory | `locks/` |
| Upstream clones | `upstream/VistA-M`, `upstream/VistA`, `upstream/VistA-VEHU-M` |
| Fetch script | `scripts/fetch/fetch-worldvista-sources.ps1` |
| Pin script | `scripts/pin/pin-worldvista-sources.ps1` |
| Status script | `scripts/fetch/show-worldvista-source-status.ps1` |
| Healthcheck script | `scripts/verify/healthcheck-local-vista.ps1` |
| Artifacts (ignored) | `artifacts/` |

---

## Commands run

All from repo root: `c:\Users\kmoul\OneDrive\Documents\GitHub\vista-evolved-vista-distro`

```powershell
.\scripts\fetch\fetch-worldvista-sources.ps1 -DryRun
.\scripts\pin\pin-worldvista-sources.ps1 -ValidateOnly
.\scripts\verify\healthcheck-local-vista.ps1 -ValidatePathsOnly
.\scripts\fetch\show-worldvista-source-status.ps1 -UseLockOnly
```

---

## Results

| Command | Exit code | Output summary |
|---------|-----------|----------------|
| fetch -DryRun | 0 | Repo root, config, lock path, lock dir, config valid JSON, Git available. No clone/fetch. |
| pin -ValidateOnly | 0 | Repo root, config, lock path, config valid JSON (3 sources), lock dir exists. No git ops. |
| healthcheck -ValidatePathsOnly | 0 | Repo root, script dir, container name, ports, timeout. No Docker. |
| show-worldvista-source-status -UseLockOnly | 0 | Repo root, lock path; lock file not found (expected). |

---

## Verified truth

- **Canonical layout:** `upstream/`, `overlay/`, `docker/`, `scripts/fetch/`, `scripts/pin/`, `scripts/build/`, `scripts/verify/`, `docs/`, `artifacts/`, `locks/` are the canonical directories.
- **Single config:** `scripts/fetch/worldvista-sources.config.json` is the only source config; `localPath` values use `upstream/` (no `vendor/`).
- **Single lock location:** `locks/worldvista-sources.lock.json`; directory created by scripts; file tracked when present.
- **Script self-check:** Fetch has `-DryRun`, pin has `-ValidateOnly`, healthcheck has `-ValidatePathsOnly`; all resolve repo root and canonical paths without network or Docker.
- **Repo root resolution:** When `$PSScriptRoot` is empty, scripts use `Split-Path -Parent $MyInvocation.MyCommand.Path` and default RepoRoot in script body so they work when run via `powershell -File` from repo root.
- **Docs:** `docs/reference/upstream-source-strategy.md`, `runtime-truth.md`, `customization-policy.md`, `runtime-readiness-levels.md` exist and reference the canonical paths and scripts.
- **.gitignore:** `locks/` and lock file are tracked; `upstream/` clones and `artifacts/` are ignored.

---

## Unverified areas

- **Actual fetch/pin:** No `git clone` or `git fetch` was run. First real fetch will create `upstream/` and write `locks/worldvista-sources.lock.json`.
- **Docker:** No Docker build or compose; healthcheck’s non-ValidatePathsOnly path was not run against a live container.
- **Cross-platform:** Paths use backslashes in scripts; forward slashes in config `localPath` work with `Join-Path` on Windows. Linux/macOS not tested.

---

## Risks

- **Lock file missing:** Until first fetch or pin, `locks/worldvista-sources.lock.json` does not exist; status script reports "Lock file not found" (by design).
- **Optional repo:** VistA-VEHU-M is optional and gated by `vehuEnabled` in config; if disabled, it is skipped.

---

## Next step

- **Before upstream fetch/pin:** Ensure Git is installed and network access to GitHub is allowed. Run from repo root:
  - `.\scripts\fetch\fetch-worldvista-sources.ps1` (no `-DryRun`) to clone/fetch and update lock, or
  - `.\scripts\fetch\fetch-worldvista-sources.ps1 -DryRun` then `.\scripts\pin\pin-worldvista-sources.ps1` after manually cloning if you need to pin without fetch.
- **Optional cleanup:** Remove `migrated-process-assets/upstream/`, `migrated-process-assets/runtime/`, and `migrated-process-assets/docs/` (keep `migrated-process-assets/README.md` as pointer) to avoid duplicate files.

Do not begin upstream fetch/pin until explicitly instructed.
