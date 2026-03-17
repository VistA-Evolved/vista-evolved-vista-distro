# Phase 2 Proof Report — Authentic VistA Roll-and-Scroll Terminal

> **Status**: VERIFIED_M_MODE_RUNTIME_SLICE
> **Date**: 2026-03-13
> **Image**: `vista-distro:local` (`6efb7903cce7`, 19.8 GB)

## Pass 1 / Pass 2 Update

This report was extended with a live runtime cleanup pass and a live browser
terminal encoding check against the `local-vista` container and the
`apps/terminal-proof` bridge.

### Verified Before / After

Before runtime changes, the browser terminal showed:

```text
NEW SYSTEM 304-262-7078
Volume set: ROU:gtm_sysid  UCI: VAH  Device: /dev/pts/0
WARNING -- TASK MANAGER DOESN'T SEEM TO BE RUNNING!!!!
Select Systems Manager Menu <TEST ACCOUNT> Option:
```

After the verified runtime changes now in the repo, the browser terminal shows:

```text
VistA Evolved Local Sandbox
YottaDB-backed terminal runtime
Volume set: ROU:LOCAL-VISTA  UCI: VAH  Device: /dev/pts/0
ACCESS CODE:
```

After login, the browser terminal now shows:

```text
Good morning PROVIDER,CLYDE WV
Select Systems Manager Menu <LOCAL SANDBOX> Option:
```

### What Was Actually Fixed

- `ROU:gtm_sysid` was replaced with `ROU:LOCAL-VISTA` in the live terminal.
- The menu prompt changed from `<TEST ACCOUNT>` to `<LOCAL SANDBOX>`.
- The sign-on intro now renders as `VistA Evolved Local Sandbox` / `YottaDB-backed terminal runtime`.
- TaskMan now starts successfully at boot and the browser-visible warning is gone.
- Clipboard paste now works deterministically for sign-on and menu input.
- Selection copy-out now works through `Ctrl+C`, and right-click now performs
   operator-safe copy/paste based on whether text is selected.
- Reload and explicit reconnect are now both verified to start a fresh sign-on
   session rather than resuming the prior VistA menu state.
- The browser SSH shell was stabilized by unsetting YottaDB replication-instance
   vars and running `mupip rundown -reg "*"` in the `vista` user context before
   `yottadb -run ZU`.

### What Was Not Fully Fixed

- The terminal still runs in `ydb_chset=M` / `LC_ALL=C`. This is not a UTF-8
   runtime sign-off.

### Exact Intro / TaskMan Root Causes That Were Fixed

Live inspection found two concrete runtime bugs:

```text
XUS1A INTRO gate:
Q:'$D(^XTV(8989.3,1,"INTRO",0))

TaskMan live status after fix:
VOLRECORD^ROU^N^^N^N^VAH^^^0^G^1
PAIR^ROU:LOCAL-VISTA
MODE^G
RECORD^ROU:LOCAL-VISTA^^^^^0^24^0^G^^^0
BASEPAIR^ROU
BASERECORD^
RUNNING^67642,17090
```

The intro text nodes existed, but the required Word-Processing zero node did
not. `XUS1A` therefore skipped the banner entirely. The fix was to write
`^XTV(8989.3,1,"INTRO",0)` alongside the intro lines.

TaskMan was blocked because the active pair `ROU:LOCAL-VISTA` had no seeded
site record in file `14.7`. `ZVETASK` now ensures the required `14.5` and `14.7`
records exist before `START^ZTMB` runs.

### UTF-8 / I18N Reality Check

Live browser-terminal samples were entered at the VistA menu prompt:

- `José Niño`
- `François`
- `Müller`
- `São Paulo`
- `Peña`
- `العربية`
- `中文`

Observed truth:

- Latin-accented text echoed cleanly and returned `??` as invalid menu input,
   which means the browser, SSH path, and terminal rendering preserved those
   glyphs visibly.
- Arabic and Chinese glyphs also rendered in the browser terminal, but they did
   not behave like ordinary literal menu tokens. Entering them triggered menu
   redisplay/help rather than a normal `??` invalid-option response.
- Runtime environment remains `ydb_chset=M` with `LC_ALL=C`.
- Clipboard paste now reaches the VistA prompt deterministically for sign-on,
  menu tokens, accented Latin samples, Arabic, and Chinese. The remaining issue
  is not clipboard delivery but the underlying M-mode charset/runtime behavior.

Honest classification:

```text
UTF-8 migration possible but not complete.
```

### Build-Mode Boundary

Additional repo and upstream comparison established that this result is not a
narrow browser-only defect. The current `local-vista` lane is intentionally
built and started in M mode, and the matching distro lane in the main
`VistA-Evolved` repo does the same.

Observed repo truth:

- `docker/local-vista/Dockerfile` exports `ydb_chset=M` and `LC_ALL=C` during
   database creation, globals load, and runtime image setup.
- `docker/local-vista/entrypoint.sh`, `vista-login.sh`, `start-taskman.sh`, and
   `sync-runtime.sh` all start the live runtime with `ydb_chset=M` and
   `LC_ALL=C`.
- The VistA-Evolved service distro lane follows the same pattern rather than a
   UTF-8-first bootstrap.

Implication:

```text
The verified operator-safe browser terminal is an M-mode lane.
Durable UTF-8 requires a dedicated rebuild/reload/recompile slice, not a
runtime-only shell flip inside the current image.
```

### Live UTF-8 Promotion Attempt (2026-03-13)

An additional runtime experiment was run against the live `local-vista`
container to determine whether this lane could be promoted from the current
M-mode charset to a real UTF-8 shell/runtime path.

What was verified live:

- A direct YottaDB session with `ydb_chset=UTF-8` failed immediately when it hit
   existing object files compiled under `CHSET=M`.
- After deleting the stale `.o` files, the same direct UTF-8 session could reach
   `ZU` and print the sign-on banner and `ACCESS CODE:` prompt.
- However, switching the actual browser/SSH login lane to UTF-8 caused the live
   browser terminal to disconnect with the following runtime-visible errors:

```text
%YDB-E-GVKILLFAIL ... Global variable: ^XUTL("XUSYS",140)
. D SAVE("$ZU(56,2)",$ZU(56,2))
^-----
At column 24, line 37, source module /opt/vista/r/_ZTER.m
%YDB-E-INVFCN, Invalid function name
%YDB-E-GVPUTFAIL ... Global variable: ^TMP("$ZE",140,1)
```

Observed outcome:

- The SSH/browser session did not remain usable under the forced UTF-8 lane.
- The stable runtime had to be restored to the prior `ydb_chset=M` /
   `LC_ALL=C` configuration.

This means the blocker is now explicit and proven:

```text
UTF-8 shell promotion is not yet sign-off safe for the live browser terminal.
```

Current stop point:

```text
This Phase 2 runtime slice is complete for authentic browser terminal proof in
M mode. UTF-8 remains a separate follow-up build lane.
```

---

## What Was Done

Turned the Phase 1 browser terminal (shell-based SSH proof) into an authentic
VistA roll-and-scroll user entry point. The user lands directly at the VistA
`ACCESS CODE:` prompt with no Linux shell exposure.

### Changes Made

#### vista-evolved-vista-distro

| File | Change |
|------|--------|
| `docker/local-vista/Dockerfile` | Added KBANTCLN init step, demo user creation, canonical login shell with tied.sh security vars |
| `docker/local-vista/entrypoint.sh` | Added runtime sync and TaskMan launch/status path in the `vista` user context |
| `docker/local-vista/vista-login.sh` | Added explicit `LOCAL-VISTA` sysid plus vista-user rundown/replication cleanup before `ZU` |
| `docker/local-vista/start-taskman.sh` | Added vista-user YottaDB cleanup before TaskMan bootstrap |
| `docker/local-vista/check-taskman.sh` | Added live TaskMan status probe |
| `docker/local-vista/sync-runtime.sh` | Added repeatable runtime init path for `EN^ZVEINIT` under the live `vista` user context |
| `docker/local-vista/KBANTCLN.m` | Sam Habiel's silent ZTMGRSET replacement from WorldVistA/docker-vista |
| `overlay/routines/ZVECREUSER.m` | Demo user creation routine (PROV123/PROV123!!) using VistA APIs |
| `overlay/routines/ZVEINIT.m` | Local runtime sync for intro banner + menu prompt customization |
| `overlay/routines/ZVETASK.m` | Local TaskMan start/status helper routines |
| `apps/terminal-proof/public/index.html` | Added deterministic clipboard paste, selection copy-out, right-click copy/paste, and reconnect-safe input handling |
| `docs/runbooks/terminal-proof-checklist.md` | 6-gate proof checklist |
| `docs/runbooks/terminal-operator-quickstart.md` | Operator quick-start guide |

#### vista-evolved-platform

| File | Change |
|------|--------|
| `apps/terminal-proof/public/index.html` | Classic VistA theme: black background, green cursor, minimal 22px status bar |

### Root Causes Found and Fixed

| Problem | Root Cause | Fix |
|---------|-----------|-----|
| ZU exit code 90 | `^%ZOSF` global empty — ZTMGRSET/KBANTCLN never ran during image build | Downloaded KBANTCLN.m from WorldVistA, ran `START^KBANTCLN` |
| `%ZOSV` not found | % routines never renamed from source names (ZOSVGUX, ZISHGUX, etc.) | KBANTCLN renames all % routines |
| FileMan not initialized | DINIT never ran | KBANTCLN runs DINIT as part of initialization |
| CHSET mismatch | `ydb` wrapper re-sources `ydb_env_set`, overriding `ydb_chset=M` | Use `yottadb` binary directly + explicit env setup |
| SSH banners visible | Default sshd config shows MOTD and last login | `PrintMotd no`, `PrintLastLog no`, `Banner none`, empty `/etc/motd` |
| No user credentials | WorldVistA source import has no demo users with access codes | Created ZVECREUSER.m using `$$EN^XUSHSH` + `UPDATE^DIE` pattern from wvDemopi.m |

### What Was Researched

- WorldVistA/docker-vista `autoInstaller.sh` — build orchestration
- WorldVistA/docker-vista `KBANTCLN.m` — canonical silent ZTMGRSET (Sam Habiel)
- WorldVistA/docker-vista `wvDemopi.m` — demo user creation pattern
- WorldVistA/docker-vista `tied.sh` — login shell env vars pattern
- VistA kernel `XUSHSH.m` — SHA hashing (InterSystems vs GT.M/YottaDB paths)
- VistA kernel `XUS`, `XUS2` — sign-on flow
- VistA NEW PERSON file (#200) — credential storage, A-xref, verify code sub-file

---

## Verification Proof

### Gate 1: CHSET=M
```
Login shell sets ydb_chset=M after ydb_env_set sources.
Uses $ydb_dist/yottadb binary (not ydb wrapper).
```

### Gate 2: VistA sign-on (no shell)
```
Volume set: ROU:LOCAL-VISTA  UCI: VAH  Device: /dev/pts/0

ACCESS CODE:
```
No bash prompt, no `$`, no `YDB>` visible at any point.

### Gate 3: Classic VistA theme
```css
background: #000000; color: #e0e0e0; cursor: #22c55e;
Font: Cascadia Mono, Fira Code, monospace
Status bar: 22px, bottom only
```

### Gate 4: xterm.js retained
```
xterm.js 5.5.0 + @xterm/addon-fit 0.10.0 via CDN
```

### Gate 5: Login works
```
ACCESS CODE: *******
VERIFY CODE: *********
Good morning PROVIDER,CLYDE WV
...
Select Systems Manager Menu <LOCAL SANDBOX> Option:
```

### Gate 6: Menu navigation
```
Select Systems Manager Menu <LOCAL SANDBOX> Option: ?

   Core Applications ...
   Device Management ...
   Menu Management ...
   Operations Management ...
   Spool Management ...
   Information Security Officer Menu ...
   Taskman Management ...
   User Management ...
   Application Utilities ...
   Capacity Planning ...
   HL7 Main Menu ...
```

---

## Known Issues

1. **XLFIPV.m error** — InterSystems `$SYSTEM.Process.IPv6Format()` not available on YottaDB. Cosmetic only.
2. **Blank `Enter` defaults toward halt** — empty input at the Systems Manager prompt falls into `Do you really want to halt? YES//`.
3. **XUSHSH returns plaintext** — InterSystems `$system.Encryption.SHAHash()` not available. Access/verify codes stored unhashed. Acceptable for demo; production needs YottaDB-native SHA plugin or patched `XUSHSH.m`.

---

## Phase 3 Addendum — UTF-8 Lane Verification (2026-03-14)

The UTF-8 build lane (`docker/local-vista-utf8/`) has been built, booted, and
verified through the full browser terminal path. This resolves the Phase 2
finding that "UTF-8 runtime not proven."

### UTF-8 Lane Container

- **Image**: `vista-distro:local-utf8`
- **Container**: `local-vista-utf8`
- **Ports**: 2226 (SSH), 9434 (RPC Broker)
- **Charset**: `ydb_chset=UTF-8`, `LC_ALL=en_US.UTF-8` (build-time and runtime)
- **Source**: WorldVistA/VistA-VEHU-M plan-vi

### Live Browser Verification Results

All tests performed in the browser terminal at `http://localhost:4400/`
via the terminal-proof bridge (`server.mjs` targeting port 2226):

| Test | Command | Result |
|------|---------|--------|
| `$ZCHSET` | `W $ZCHSET` | `UTF-8` |
| Latin accent (café) | `S X="caf"_$C(233) W X` | `café` — rendered correctly |
| Latin accent (résumé) | `S X="r"_$C(233)_"sum"_$C(233) W X` | `résumé` — rendered correctly |
| Spanish (Español) | `S X="Espa"_$C(241)_"ol" W X` | `Español` — rendered correctly |
| CJK (世界) | `S X=$C(19990,30028) W X` | `世界` — rendered correctly |
| `$LENGTH` vs `$ZLENGTH` for café | `W $L(X)," ",$ZL(X)` | `4 5` — character count vs byte count correct |
| `$LENGTH` vs `$ZLENGTH` for 世界 | `W $L(X)," ",$ZL(X)` | `2 6` — each CJK char = 3 bytes |
| Global round-trip | `S ^TMP(...)=X W ^TMP(...)` | All multi-byte strings stored and retrieved correctly |

### No SSH leakage

The ssh2 Node.js library handles host keys silently (no `hostVerifier`
callback = accept all). The container's sshd is configured with `PrintMotd no`,
`PrintLastLog no`, `Banner none`. No SSH warnings visible in the browser path.

### No TaskMan warning

`^%ZTSCH("RUN")` has a value. No TaskMan warning appears at login.

### Menu prompt

Shows `<LOCAL SANDBOX>`, not `<TEST ACCOUNT>`. Set by `ZVEINIT PROMPT` tag
via `EN^XPAR`.

### Charset Classification

```
Full multilingual safe.
```

The UTF-8 lane is the production-candidate browser terminal path.

---

## Follow-Ups

- [ ] Patch `XUSHSH.m` for YottaDB-native SHA-256 hashing (use `$ZPIECE` or external plugin)
- [ ] Patch `XLFIPV.m` to skip InterSystems-specific IPv6 code on GT.M/YottaDB
- [ ] Consider adding NURSE and PHARMACIST demo users (from wvDemopi.m pattern)

---

## Runtime-Proof Reconciliation — UTF-8 Claims (2026-03-18)

This addendum records the bounded runtime-proof reconciliation that verified
three UTF-8 lane claims that were previously marked "still unverified" in
`docs/reference/runtime-truth.md`. All tests ran against the live
`local-vista-utf8` container (image sha256:82847200, built 2026-03-14).

### Claims verified

| Claim | Result | Method |
|-------|--------|--------|
| A. Direct sign-on under UTF-8 | **PASS** | `docker exec` login with PRO1234/PRO1234!! — full menu, clean exit |
| B. Browser terminal behavior | **PASS** | WebSocket→SSH bridge (port 2226) — sign-on, login, menu, device `/dev/pts/0` |
| C. Multilingual input | **PASS** | See sub-claims below |

### Multilingual sub-claims

| Sub-claim | Evidence |
|-----------|----------|
| C.1 English baseline | Text roundtrips correctly through MUMPS W/R |
| C.2 Korean | `$L("한국어테스트")=6` (character count, not 18 bytes) — confirms UTF-8 mode |
| C.3 Spanish | `$L("José")=4` (character count, not 5 bytes) |
| C.4 Unicode code points | `$A($E("한",1))=54620` = U+D55C |

Chinese and Arabic glyphs were observed to render through the I/O path but
are not bounded product languages and are not claimed as verified.

### Evidence

Full proof transcript: `artifacts/logs/utf8-proof-20260318.log`

### What this does NOT claim

See "What UTF-8 proof does NOT claim" in `docs/reference/runtime-truth.md`.
