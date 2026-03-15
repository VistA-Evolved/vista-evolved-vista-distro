# Port Registry — VistA Evolved Distro

> Canonical port assignments. Do not use ports outside this registry without updating this file.

---

## Assigned ports

| Service | Port | Lane | Notes |
|---------|------|------|-------|
| RPC broker (M-mode) | 9433 | `docker/local-vista` | XWB RPC broker |
| SSH (M-mode) | 2225 | `docker/local-vista` | Terminal access |
| RPC broker (UTF-8) | 9434 | `docker/local-vista-utf8` | XWB RPC broker (UTF-8 lane) |
| SSH (UTF-8) | 2226 | `docker/local-vista-utf8` | Terminal access (UTF-8 lane) |

---

## Environment overrides

| Variable | Default | Purpose |
|----------|---------|---------|
| `LOCAL_VISTA_PORT` | 9433 | RPC broker port (M-mode) |
| `LOCAL_VISTA_SSH_PORT` | 2225 | SSH port (M-mode) |

---

## Cross-repo port coordination

| Repo | Service | Port | Notes |
|------|---------|------|-------|
| VistA-Evolved | VEHU RPC broker | 9431 | Dev sandbox |
| VistA-Evolved | Legacy RPC broker | 9430 | Legacy WorldVistA |
| VistA-Evolved | API server | 3001 | Fastify API |
| vista-evolved-vista-distro | M-mode RPC | 9433 | Distro M-mode |
| vista-evolved-vista-distro | M-mode SSH | 2225 | Distro terminal |
| vista-evolved-vista-distro | UTF-8 RPC | 9434 | Distro UTF-8 |
| vista-evolved-vista-distro | UTF-8 SSH | 2226 | Distro terminal |
