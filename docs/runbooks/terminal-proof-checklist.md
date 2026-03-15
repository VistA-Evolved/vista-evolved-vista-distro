# VistA Browser Terminal — Proof Checklist

> Phase 2 — Authentic VistA Roll-and-Scroll Terminal
> Date: 2026-03-13
> Container: `vista-distro:local` (image `26126ee58a0b`, 19.8 GB)

## Gate Checklist

| # | Gate | Status | Evidence |
|---|------|--------|----------|
| 1 | **CHSET=M** — No UTF-8 override on login | PASS | `vista-login.sh` sets `ydb_chset=M` after `ydb_env_set`; uses `yottadb` binary directly (not `ydb` wrapper) |
| 2 | **VistA sign-on** — User lands at `ACCESS CODE:` prompt, never a Linux shell | PASS | Fresh browser session shows `VistA Evolved Local Sandbox`, `YottaDB-backed terminal runtime`, `Volume set: ROU:LOCAL-VISTA UCI: VAH Device: /dev/pts/0`, then `ACCESS CODE:`. No bash, no `$`, no `YDB>` |
| 3 | **Classic VistA theme** — Black background, monospace, green cursor, no splash | PASS | `index.html` rewritten: `#000000` background, `#e0e0e0` monospace text, `#22c55e` green cursor, 22px status bar, no splash screen |
| 4 | **xterm.js retained** — No new terminal library | PASS | `public/index.html` loads xterm.js 5.5.0 + fit addon via CDN, same as Phase 1 |
| 5 | **Login works** — `PROV123` / `PROV123!!` authenticates as PROVIDER,CLYDE WV | PASS | Screenshot shows `Good morning PROVIDER,CLYDE WV` and Systems Manager Menu (EVE) with 11 options |
| 6 | **TaskMan online** — No runtime warning at login or menu entry | PASS | Browser login no longer shows `TASK MANAGER DOESN'T SEEM TO BE RUNNING`; direct `START^ZVETASK` / `STATUS^ZVETASK` path reports `RUNNING^...` |
| 7 | **Menu navigation** — `?`, `??`, and `^` behave correctly | PASS | `?` lists menus, `??` lists option codes and common options, `^` exits paged help back to `Select Systems Manager Menu <LOCAL SANDBOX> Option:` |
| 8 | **Reconnect behavior** — Browser reload returns to a clean sign-on | PASS | Reloading `http://127.0.0.1:4400/` shows the intro banner and a fresh `ACCESS CODE:` prompt rather than resuming the prior menu state |
| 9 | **Clipboard paste** — Access Code, Verify Code, and menu paste work live | PASS | `Ctrl+V` paste delivered `PROV123` and `PROV123!!` correctly and completed login; ASCII `?` and accented `José Niño` paste behaved deterministically at the menu prompt |
| 10 | **Copy-out / right-click** — Selection copy and right-click copy/paste are operator-usable | PASS | `Ctrl+C` copied selected terminal text into the system clipboard; right-click copied when text was selected and pasted `?` when no selection existed |

## Known Limitations (Still Real)

| Issue | Root Cause | Impact |
|-------|-----------|--------|
| `XLFIPV.m` error on login | InterSystems Caché IPv6 API (`$SYSTEM.Process.IPv6Format()`) not available in YottaDB | Cosmetic only — does not affect functionality |
| `XUSHSH` returns plaintext (no SHA hash) | InterSystems `$system.Encryption.SHAHash()` not available in YottaDB | Access/verify codes stored unhashed. Acceptable for demo. Production needs YottaDB-native SHA plugin |
| Blank `Enter` defaults toward halt | This menu treats empty input as its default action path | Operators who hit `Enter` on a blank prompt see `Do you really want to halt? YES//` |

## Technical Stack

```
Browser -> xterm.js (WebSocket) -> server.mjs (Fastify 5) -> SSH (port 2226)
  -> sshd -> vista-login.sh -> yottadb -run ZU -> VistA sign-on
```

## Container Configuration

- **Image**: `vista-distro:local-utf8`
- **Base**: `yottadb/yottadb-debian:r2.02`
- **VistA source**: WorldVistA/VistA-VEHU-M plan-vi (33,951 routines, 2,922 globals)
- **Kernel init**: KBANTCLN.m (Sam Habiel)
- **Charset**: `ydb_chset=UTF-8`, `LC_ALL=en_US.UTF-8` (build-time and runtime)
- **Ports**: 9434->9430 (RPC Broker), 2226->22 (SSH)
- **Login shell**: `/opt/vista/vista-login.sh`
- **Demo user**: PROGRAMMER,ONE (DUZ 1), primary menu EVE
