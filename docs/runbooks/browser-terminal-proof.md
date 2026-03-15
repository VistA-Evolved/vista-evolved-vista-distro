# Browser Roll-and-Scroll Terminal Proof Runbook

> **Purpose:** Prove that the browser-based VistA roll-and-scroll terminal works
> against the `local-vista` Docker runtime. This is a prerequisite before any
> product UI work begins.

---

## Prerequisites

| Requirement | Check |
|-------------|-------|
| `local-vista-utf8` container healthy | `docker ps --filter name=local-vista-utf8` shows "healthy" |
| RPC broker port 9434 reachable | TCP connect to `127.0.0.1:9434` |
| SSH port 2226 reachable | TCP connect to `127.0.0.1:2226` |
| Healthcheck passes | `scripts/verify/healthcheck-local-vista.ps1` exits 0 (5/5 PASS) |

Run the healthcheck first:

```powershell
& scripts/verify/healthcheck-local-vista.ps1
# Must show: 5 PASS, 0 FAIL
```

---

## Architecture (from VistA-Evolved archive)

The browser terminal has two paths. Only the **SSH path** is relevant for roll-and-scroll proof:

```
Browser (xterm.js)
  |
  | WebSocket /ws/terminal
  v
server.mjs (Fastify 5) -- SSH proxy
  |
  | TCP SSH
  v
local-vista-utf8:22 (sshd -> vista-login.sh -> D ^ZU)
```

### Key archive files (READ ONLY -- in VistA-Evolved, not this repo)

| File | Purpose |
|------|---------|
| `apps/web/src/components/terminal/VistaSshTerminal.tsx` | xterm.js + FitAddon, VT220, connects `/ws/terminal` |
| `apps/web/src/lib/rs-stream-parser.ts` | Detects VistA prompts in TTY stream |
| `apps/api/src/routes/ws-terminal.ts` | WebSocket-to-SSH bridge, session auth, audit |
| `apps/web/src/app/cprs/vista-workspace/page.tsx` | Canonical route `/cprs/vista-workspace` |
| `docs/canonical/terminal/web-terminal-architecture.md` | Full architecture doc |
| `docs/canonical/terminal/web-terminal-verification.md` | Verification steps |
| `docs/canonical/terminal/authentic-web-roll-and-scroll-criteria.md` | 7 authenticity criteria |
| `scripts/runtime/verify-web-terminal-backend.ps1` | Backend terminal verifier |
| `apps/web/e2e/terminal-roll-and-scroll.spec.ts` | Playwright E2E spec |

---

## Environment Variables (API side)

The API `ws-terminal.ts` proxy reads these env vars:

```env
VISTA_SSH_HOST=127.0.0.1
VISTA_SSH_PORT=2226
VISTA_SSH_USER=vista
VISTA_SSH_PASSWORD=vista
PORT=4400
```

---

## Proof Steps

### Step 1: Verify SSH direct access

```powershell
# From host, verify SSH responds
ssh -p 2226 vista@127.0.0.1
# Should present VistA roll-and-scroll (D ^ZU menu system)
# Type HALT to exit
```

If SSH is not configured with a password, use the container's built-in user.

### Step 2: Verify API terminal health endpoint

With the VistA-Evolved API running (`apps/api` pointed at `VISTA_SSH_PORT=2225`):

```powershell
curl.exe -s http://127.0.0.1:3001/terminal/health
# Expected: {"ok":true,"ssh":"reachable","port":2225}
```

### Step 3: Verify WebSocket upgrade

```powershell
# Login first
Set-Content -Path login-body.json -Value '{"accessCode":"PRO1234","verifyCode":"PRO1234!!"}' -NoNewline -Encoding ASCII
curl.exe -s -c cookies.txt -X POST http://127.0.0.1:3001/auth/login -H "Content-Type: application/json" -d "@login-body.json"

# Check terminal sessions endpoint
curl.exe -s -b cookies.txt http://127.0.0.1:3001/terminal/sessions
# Expected: {"ok":true,"sessions":[...]}

# Clean up
Remove-Item login-body.json, cookies.txt -ErrorAction SilentlyContinue
```

### Step 4: Browser proof (manual)

1. Start the web app: `cd apps/web && pnpm dev`
2. Navigate to `http://localhost:3000/cprs/vista-workspace`
3. Select "Terminal" mode
4. Verify xterm.js canvas renders
5. Verify `data-terminal-status="connected"` attribute appears on the terminal element
6. Verify the fresh session shows:
  - `VistA Evolved Local Sandbox`
  - `YottaDB-backed terminal runtime`
  - `Volume set: ROU:LOCAL-VISTA  UCI: VAH  Device: /dev/pts/N`
  - `ACCESS CODE:`
7. Log in with `PROV123 / PROV123!!` and verify no TaskMan warning appears
8. Verify `?`, `??`, and `^` at `Select Systems Manager Menu <LOCAL SANDBOX> Option:`
9. Verify `Ctrl+V` or `Shift+Insert` paste for:
  - `PROV123` at `ACCESS CODE:`
  - `PROV123!!` at `VERIFY CODE:`
  - `?` and one accented Latin sample at the menu prompt
10. Verify `Ctrl+C` copies the current terminal selection into the host clipboard
11. Verify right-click copies when text is selected and pastes when no text is selected
12. Reload the browser and verify the terminal returns to a fresh sign-on prompt
13. Disconnect and use the `reconnect` control once; verify it also returns to a fresh sign-on prompt
14. Record the current charset truth: **Full multilingual safe**. `$ZCHSET=UTF-8`, `$LENGTH` returns character count, `$ZLENGTH` returns byte count. Latin accents, Spanish ñ, and CJK characters all store/retrieve/render correctly through the full stack.

### Step 5: E2E test (automated)

From the VistA-Evolved repo:

```powershell
cd apps/web
npx playwright test e2e/terminal-roll-and-scroll.spec.ts
```

---

## Authenticity Criteria (7 gates)

From `docs/canonical/terminal/authentic-web-roll-and-scroll-criteria.md`:

| # | Criterion | How to verify |
|---|-----------|--------------|
| 1 | Stable session | Terminal stays connected for >60s without drop |
| 2 | Keyboard fidelity | All printable chars + Ctrl+C, arrow keys, backspace work |
| 3 | Copy/paste | Clipboard input and selection copy work without dropping or truncating terminal text |
| 4 | Resize (PTY) | Browser window resize propagates to VistA terminal width |
| 5 | No fake prompts | All prompts come from VistA, not locally generated |
| 6 | Real VistA interaction | `D ^ZU` produces actual CPRS menus from the running VistA |
| 7 | Usable by VistA-trained user | A user familiar with VistA R&S can navigate without confusion |

---

## Success Criteria

The browser terminal proof is **DONE** when ALL of:

1. `healthcheck-local-vista.ps1` exits 0 (5/5 PASS)
2. SSH direct access to `local-vista:2225` works and shows VistA menu
3. `/terminal/health` returns `{"ok":true}`
4. WebSocket upgrade at `/ws/terminal` completes
5. xterm.js renders in browser at `/cprs/vista-workspace`
6. `D ^ZU` produces real VistA output (not simulated)
7. All 7 authenticity criteria pass

---

## Failure Modes

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| SSH connection refused | Container SSH daemon not started | Check `entrypoint.sh` starts `sshd` |
| WebSocket upgrade fails | API not running or wrong SSH env vars | Verify `VISTA_SSH_HOST`/`VISTA_SSH_PORT` in `.env.local` |
| xterm.js blank canvas | WebSocket URL wrong | Check `WS_BASE` in `api-config.ts` |
| "D ^ZU" no response | VistA not started in container | Check `xinetd` and `mumps` process in container |
| Terminal disconnects | Idle timeout or socket error | Check `VISTA_TERMINAL_MAX_SESSIONS` |
| Intro lines missing but `ACCESS CODE:` appears | `^XTV(8989.3,1,"INTRO",0)` missing or runtime sync not applied | Re-run `EN^ZVEINIT` in the live runtime and reconnect |
| Menu login shows TaskMan warning | TaskMan bootstrap or site-parameter seeding failed | Inspect `/opt/vista/g/taskman.log` and `STATUS^ZVETASK` |
| Paste fails silently | Browser clipboard permission or terminal focus issue | Re-focus the terminal and re-authorize clipboard access |
| Blank `Enter` surprises operators with halt confirmation | This menu's default action path is halt | Document the behavior and advise operators to type an explicit command or `^` |
| Forced UTF-8 shell disconnects the browser session | **Resolved.** The UTF-8 lane (`local-vista-utf8`) is built from scratch with `ydb_chset=UTF-8`. The `_ZTER` / `$ZU(...)` errors occurred only during live M-to-UTF8 promotion; they do not occur in the dedicated UTF-8 build lane. |
