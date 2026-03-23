# Port Registry — VistA Evolved Distro

> Canonical port assignments for **distro** VistA runtime services. Do not use
> ports outside this registry without updating this file.
>
> **Platform service ports** (control plane, tenant admin, PostgreSQL) are managed by
> the platform repo: `vista-evolved-platform/docs/reference/port-registry.md`.

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
| vista-evolved-platform | Control plane review API | 4500 | HTTP |
| vista-evolved-platform | Control plane admin API | 4510 | HTTP |
| vista-evolved-platform | Tenant admin workspace | 4520 | HTTP |
| vista-evolved-platform | Control plane PostgreSQL | 5433 | TCP |
| VistA-Evolved (archive) | VEHU RPC broker | 9431 | Dev sandbox |
| VistA-Evolved (archive) | Legacy RPC broker | 9430 | Legacy WorldVistA |
| VistA-Evolved (archive) | API server | 3001 | Fastify API |
