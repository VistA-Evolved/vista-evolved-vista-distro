# Upstream source strategy

- **Upstream** repos (e.g. WorldVistA VistA-M, VistA) are fetched and pinned by scripts in this repo. **Canonical paths:**
  - **Config:** `scripts/fetch/worldvista-sources.config.json` — source definitions and `localPath` (under `upstream/`).
  - **Lock:** `locks/worldvista-sources.lock.json` — commit SHAs, branch, fetch date. Tracked in git.
  - **Clones:** `upstream/VistA-M`, `upstream/VistA`, `upstream/VistA-VEHU-M` (optional). Not tracked; populated by fetch.
- **Fetch:** `scripts/fetch/fetch-worldvista-sources.ps1` — clone or fetch; updates lock. Use `-DryRun` to validate paths and config only.
- **Pin:** `scripts/pin/pin-worldvista-sources.ps1` — record current or given SHAs in lock. Use `-ValidateOnly` to validate paths and config only.
- **Status:** `scripts/fetch/show-worldvista-source-status.ps1` — read lock and optionally list `upstream/` contents.
- **Overlay** (routines, install, patches) is applied on top of upstream. All customizations live in `overlay/`; upstream remains pristine.
- Do not fetch in bootstrap stage. When ready, run fetch then pin; lock file is the contract for reproducible builds.
