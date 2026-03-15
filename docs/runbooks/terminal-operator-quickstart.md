# VistA Browser Terminal — Operator Quick-Start

## Prerequisites

- Docker Desktop running
- Node.js 20+ installed
- Ports 2226, 4400, 9434 available (UTF-8 lane)

## Active Lane: UTF-8

The production-candidate browser terminal now targets the **UTF-8 lane**
(`local-vista-utf8`, port 2226). The legacy M-mode lane (`local-vista`,
port 2225) is retained for reference but is no longer the primary operator path.

## 1. Start the VistA Container

```powershell
cd vista-evolved-vista-distro/docker/local-vista-utf8
docker compose up -d
```

Wait for the container to become healthy (~30 seconds):

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}" | Select-String "local-vista-utf8"
# Should show: local-vista-utf8   Up X seconds (healthy)
```

## 2. Start the Terminal Server

```powershell
cd vista-evolved-platform/apps/terminal-proof
node --env-file=.env src/server.mjs
```

Verify the server is running:

```powershell
curl.exe -s http://127.0.0.1:4400/terminal/health
# Should return: {"ok":true,"ssh":{"host":"127.0.0.1","port":2226,"status":"connected"},...}
```

## 3. Open in Browser

Navigate to: **http://127.0.0.1:4400/**

You should see:
```
VistA Evolved Local Sandbox
YottaDB-backed terminal runtime

Volume set: ROU:LOCAL-VISTA  UCI: VAH  Device: /dev/pts/0

ACCESS CODE:
```

## 4. Log In

| Credential | Value |
|-----------|-------|
| ACCESS CODE | `PRO1234` |
| VERIFY CODE | `PRO1234!!` |

After login: `Good morning PROGRAMMER,ONE`

Then: `<LOCAL SANDBOX> Select Systems Manager Menu Option:`

Type `?` + Enter to see available menus. Type `??` for option codes and `^`
to stop paged help and return to the menu prompt.

## Runtime Truth

- The terminal is a VEHU Plan VI VistA runtime hosted on YottaDB r2.02.
- Runtime charset is `ydb_chset=UTF-8` with `LC_ALL=en_US.UTF-8`.
- The database was created, loaded, and compiled under UTF-8 from the start.
- `$ZCHSET` returns `UTF-8` at the YDB direct-mode prompt.
- `$LENGTH` returns character count; `$ZLENGTH` returns byte count. Both are
  correct for multi-byte characters (verified with Latin accents, Spanish,
  and CJK).
- UTF-8 global store and retrieve round-trip is verified: Latin accents (cafe,
  resume), Spanish (Espanol), and CJK (世界) all write to globals and read
  back correctly.
- `Ctrl+V`, `Shift+Insert`, and right-click paste deliver full clipboard text
  to the active VistA prompt.
- `Ctrl+C` copies the current terminal selection out to the system clipboard.
- Right-click copies when text is selected and pastes when no text is selected.
- Reloading the browser starts a fresh sign-on session. The `reconnect` control
  also starts a fresh sign-on session after disconnect. Neither path resumes a
  prior VistA menu state.
- Final charset classification: **Full multilingual safe** (Latin, Spanish,
  CJK verified end-to-end through YottaDB -> SSH -> WebSocket -> xterm.js).

## 5. Troubleshooting

| Symptom | Fix |
|---------|-----|
| "connecting" stuck | Check `docker ps` — container must be healthy |
| SSH timeout | Container SSH on port 2226 not ready — wait 30 seconds |
| ACCESS CODE rejected | Verify PROGRAMMER,ONE user exists (DUZ 1) |
| `Device: 0` instead of `/dev/pts/N` | Not using SSH with PTY — use the browser terminal, not piped stdin |
| Intro banner missing before `ACCESS CODE:` | Runtime sync did not apply — rerun `/opt/vista/sync-runtime.sh` in the container and reconnect |
| `TASK MANAGER DOESN'T SEEM TO BE RUNNING` | Regression — inspect `/opt/vista/g/taskman.log` and `/opt/vista/check-taskman.sh` output |
| Paste does nothing | Browser clipboard permission denied — re-focus the terminal and allow clipboard access |
| Right-click opens the browser menu instead of copy/paste | Terminal focus or clipboard permission failed — click the terminal once and retry |

## Environment Variables (.env)

The terminal-proof `.env` targets the UTF-8 lane:

```env
VISTA_SSH_HOST=127.0.0.1
VISTA_SSH_PORT=2226
VISTA_SSH_USER=vista
VISTA_SSH_PASSWORD=vista
PORT=4400
```

## Stopping

```powershell
# Stop terminal server: Ctrl+C in the terminal
# Stop container:
cd vista-evolved-vista-distro/docker/local-vista-utf8
docker compose down
```
