#!/bin/bash
# =============================================================================
# VistA Distro Entrypoint
# Initializes YottaDB environment, starts broker via xinetd, starts SSH.
# =============================================================================
set -e

BROKER_PORT="${VISTA_BROKER_PORT:-9430}"
BROKER_BIND="${VISTA_BROKER_BIND:-0.0.0.0}"
VISTA_HOME="${VISTA_HOME:-/opt/vista}"
SSH_ENABLED="${VISTA_SSH_ENABLED:-true}"
TASKMAN_ENABLED="${VISTA_TASKMAN_ENABLED:-true}"

# ---------- Validate required env vars ----------
if [ -z "$VISTA_ADMIN_ACCESS" ] || [ -z "$VISTA_ADMIN_VERIFY" ]; then
    echo "ERROR: VISTA_ADMIN_ACCESS and VISTA_ADMIN_VERIFY must be set."
    echo "  Example: -e VISTA_ADMIN_ACCESS=PRO1234 -e VISTA_ADMIN_VERIFY=PRO1234!!"
    exit 1
fi

# ---------- Initialize YottaDB environment ----------
export gtm_dist=/opt/yottadb/current
export ydb_chset=M
export LC_ALL=C
source /opt/yottadb/current/ydb_env_set 2>/dev/null || true
export gtm_sysid="${VISTA_SYSID:-LOCAL-VISTA}"
export ydb_sysid="${VISTA_SYSID:-LOCAL-VISTA}"
export ydb_gbldir="${VISTA_HOME}/g/vista.gld"
export ydb_routines="${VISTA_HOME}/r $ydb_routines"

# ---------- Run mupip rundown to clear stale shared memory ----------
echo "Running mupip rundown..."
$ydb_dist/mupip rundown -reg "*" 2>/dev/null || true

# ---------- First-boot initialization marker ----------
INIT_MARKER="${VISTA_HOME}/g/.initialized"
if [ ! -f "$INIT_MARKER" ]; then
    echo "=== First boot: running VistA initialization ==="

    # If overlay install routines exist, run them
    if [ -f "${VISTA_HOME}/r/ZVEDIST.m" ]; then
        echo "  Running ZVEDIST (admin provisioning)..."
        echo "D EN^ZVEDIST(\"${VISTA_ADMIN_ACCESS}\",\"${VISTA_ADMIN_VERIFY}\")" | \
            $ydb_dist/yottadb -direct 2>&1 || echo "  ZVEDIST: skipped or no-op"
    fi
    if [ -f "${VISTA_HOME}/r/ZVEINIT.m" ]; then
        echo "  Running ZVEINIT (system init)..."
        echo "D EN^ZVEINIT" | \
            $ydb_dist/yottadb -direct 2>&1 || echo "  ZVEINIT: skipped or no-op"
    fi
    if [ -f "${VISTA_HOME}/r/ZVESEED.m" ]; then
        echo "  Running ZVESEED (seed data)..."
        echo "D EN^ZVESEED" | \
            $ydb_dist/yottadb -direct 2>&1 || echo "  ZVESEED: skipped or no-op"
    fi

    touch "$INIT_MARKER"
    echo "=== Initialization complete ==="
else
    echo "Already initialized (found ${INIT_MARKER})"
fi

# ---------- Runtime customization sync (safe to run every boot) ----------
if [ -x "${VISTA_HOME}/sync-runtime.sh" ]; then
    echo "Running ZVEINIT runtime sync..."
    su -s /bin/bash vista -c '/opt/vista/sync-runtime.sh' \
        || echo "  ZVEINIT: skipped or no-op"
fi

# ---------- Start SSH (optional) ----------
if [ "$SSH_ENABLED" = "true" ]; then
    echo "Starting SSH daemon..."
    /usr/sbin/sshd 2>/dev/null || echo "SSH: failed to start (non-fatal)"
fi

# ---------- Start TaskMan manager (optional, local distro only) ----------
if [ "$TASKMAN_ENABLED" = "true" ] && [ -x "${VISTA_HOME}/start-taskman.sh" ]; then
    echo "Starting TaskMan manager..."
    : > "${VISTA_HOME}/g/taskman.log"
    su -s /bin/bash vista -c '/opt/vista/start-taskman.sh' >> "${VISTA_HOME}/g/taskman.log" 2>&1 \
        || echo "TaskMan: failed to launch (non-fatal)"
    sleep 2
    if [ -x "${VISTA_HOME}/check-taskman.sh" ] && su -s /bin/bash vista -c '/opt/vista/check-taskman.sh' | grep -q '^RUNNING\^'; then
        echo "TaskMan manager is running."
    else
        echo "TaskMan manager is not running after launch attempt. See /opt/vista/g/taskman.log"
    fi
fi

# ---------- Configure xinetd for RPC Broker ----------
echo "Configuring RPC Broker on port ${BROKER_PORT}..."
mkdir -p /etc/xinetd.d
cat > /etc/xinetd.d/vista-broker <<XINETD
service vista-broker
{
    type         = UNLISTED
    protocol     = tcp
    port         = ${BROKER_PORT}
    bind         = ${BROKER_BIND}
    socket_type  = stream
    wait         = no
    user         = vista
    server       = ${ydb_dist}/yottadb
    server_args  = -direct  -run XWBTCPL
    env          = ydb_gbldir=${ydb_gbldir}
    env         += ydb_routines=${ydb_routines}
    env         += ydb_chset=M
    env         += LC_ALL=C
    env         += gtm_dist=${ydb_dist}
    log_on_failure += USERID HOST
    log_on_success += PID HOST DURATION
    disable      = no
}
XINETD

echo "Starting RPC Broker via xinetd (port ${BROKER_PORT})..."
echo "Build info:"
cat "${VISTA_HOME}/build-info.txt" 2>/dev/null || echo "  (no build info)"

# ---------- Start xinetd in foreground ----------
exec /usr/sbin/xinetd -dontfork
