# First fetch runbook — WorldVistA upstream

**Purpose:** Get WorldVistA sources locally using the normalized scripts. All clones live inside this repo under `upstream/`. Re-runs are safe: existing repos are only fetched; missing ones are cloned.

---

## Run the fetch locally

From the **repo root** (so the lock and paths resolve correctly):

```powershell
cd "C:\Users\kmoul\OneDrive\Documents\GitHub\vista-evolved-vista-distro"
.\scripts\fetch\fetch-worldvista-sources.ps1
```

- **No `-DryRun`** — this performs real clone/fetch.
- Clones go to **upstream/VistA-M**, **upstream/VistA**, **upstream/VistA-VEHU-M** (VEHU only if `vehuEnabled` is true in config).
- When done, the script writes **locks/worldvista-sources.lock.json** with branch, commit SHA, and fetch date per repo.

**If the run is interrupted (e.g. timeout, network):** run the same command again. Existing `upstream/<repo>` dirs are **not** re-cloned; the script only fetches them and clones any repo that is still missing, then updates the lock.

---

## Verify

```powershell
.\scripts\fetch\show-worldvista-source-status.ps1
```

Shows lock contents and whether each repo exists on disk; use `-UseLockOnly` to skip scanning `upstream/`.

---

## Optional: pin to exact commits

To record or switch to specific SHAs (e.g. after fetch):

```powershell
.\scripts\pin\pin-worldvista-sources.ps1
```

With no `-VistAM` / `-VistA` / `-VistAVEHUM` args, this just records current HEADs into the lock. To pin to specific SHAs, pass them; the script will `git fetch` then `git checkout <sha>` in each repo.

**Shallow clones:** Fetch uses `--depth 1`. If you need to pin to an older commit that isn’t in the shallow history, deepen first in that repo, then pin:

```powershell
cd upstream\VistA-M   # or VistA, VistA-VEHU-M
git fetch --unshallow
cd ..\..
.\scripts\pin\pin-worldvista-sources.ps1 -VistAM <sha>
```

---

## Paths (canonical)

| What        | Path |
|------------|------|
| Config     | `scripts/fetch/worldvista-sources.config.json` |
| Lock file  | `locks/worldvista-sources.lock.json` |
| Upstream   | `upstream/VistA-M`, `upstream/VistA`, `upstream/VistA-VEHU-M` |
| Fetch      | `scripts/fetch/fetch-worldvista-sources.ps1` |
| Pin        | `scripts/pin/pin-worldvista-sources.ps1` |
| Status     | `scripts/fetch/show-worldvista-source-status.ps1` |
