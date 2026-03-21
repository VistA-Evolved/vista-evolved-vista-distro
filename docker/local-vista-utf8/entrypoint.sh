#!/bin/bash
set -e

BROKER_PORT="${VISTA_BROKER_PORT:-9430}"
BROKER_BIND="${VISTA_BROKER_BIND:-0.0.0.0}"
VISTA_HOME="${VISTA_HOME:-/opt/vista}"
SSH_ENABLED="${VISTA_SSH_ENABLED:-true}"
TASKMAN_ENABLED="${VISTA_TASKMAN_ENABLED:-true}"

if [ -z "$VISTA_ADMIN_ACCESS" ] || [ -z "$VISTA_ADMIN_VERIFY" ]; then
    echo "ERROR: VISTA_ADMIN_ACCESS and VISTA_ADMIN_VERIFY must be set."
    echo "  Example: -e VISTA_ADMIN_ACCESS=PRO1234 -e VISTA_ADMIN_VERIFY=PRO1234!!"
    exit 1
fi

export gtm_dist=/opt/yottadb/current
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export ydb_chset="${ydb_chset:-UTF-8}"
# NOTE: ydb_env_set bypassed -- its Robustify creates broken SHM when
# before-image journaling is not configured (NOTBEFOREIMAGEJOURNAL -> REQRUNDOWN).
# Set env vars directly instead.
export ydb_dist=/opt/yottadb/current
export ydb_icu_version=$(pkg-config --modversion icu-io 2>/dev/null || echo "67.1")
export gtm_sysid="${VISTA_SYSID:-LOCAL-VISTA-UTF8}"
export ydb_sysid="${VISTA_SYSID:-LOCAL-VISTA-UTF8}"
export ydb_gbldir="${VISTA_HOME}/g/vista.gld"
ROUTINE_LIBS="${ydb_dist}/utf8/libyottadbutil.so"
if [ -f "${ydb_dist}/plugin/o/utf8/_ydbposix.so" ]; then
    ROUTINE_LIBS="${ydb_dist}/plugin/o/utf8/_ydbposix.so ${ROUTINE_LIBS}"
fi
export ydb_routines="${VISTA_HOME}/r ${ROUTINE_LIBS}"
export gtmroutines="${ydb_routines}"

echo "Running mupip rundown..."
# Clear ALL orphaned System V IPC objects from previous boot (safe: no other processes at this point)
for shmid in $(ipcs -m 2>/dev/null | awk 'NR>3 && $2~/^[0-9]+$/ {print $2}'); do
    ipcrm -m "$shmid" 2>/dev/null || true
done
for semid in $(ipcs -s 2>/dev/null | awk 'NR>3 && $2~/^[0-9]+$/ {print $2}'); do
    ipcrm -s "$semid" 2>/dev/null || true
done
$ydb_dist/mupip rundown -reg "*" 2>/dev/null || true
su -s /bin/bash vista -c "export ydb_dist=${ydb_dist}; export ydb_gbldir=${VISTA_HOME}/g/vista.gld; $ydb_dist/mupip rundown -reg '*'" 2>/dev/null || true

# Recreate TEMP database on every boot (^TMP, ^XUTL, ^XTMP — transient only)
# Stale TN and lock artifacts from crashed processes cause GVPUTFAIL on login.
echo "Recreating TEMP database..."
rm -f "${VISTA_HOME}/g/temp.dat"
$ydb_dist/mupip create -reg TEMP 2>/dev/null || true
chown vista:vista "${VISTA_HOME}/g/temp.dat" 2>/dev/null || true

INIT_MARKER="${VISTA_HOME}/g/.initialized"
if [ ! -f "$INIT_MARKER" ]; then
    echo "=== First boot: running VistA initialization (UTF-8 lane) ==="

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

if [ -x "${VISTA_HOME}/sync-runtime.sh" ]; then
    echo "Running ZVEINIT runtime sync..."
    su -s /bin/bash vista -c '/opt/vista/sync-runtime.sh' \
        || echo "  ZVEINIT: skipped or no-op"
fi

# Language pack loading + site language (every boot, idempotent)
# NOTE: We bypass ydb_env_set here because its Robustify function creates broken
# SHM when before-image journaling is not configured (NOTBEFOREIMAGEJOURNAL).
# Instead we set env vars directly and mupip rundown before running M code.
if [ -f "${VISTA_HOME}/r/ZVELPACK.m" ]; then
    echo "Loading language packs..."
    su -s /bin/bash vista -c "export ydb_dist=${ydb_dist}; \
        export gtm_dist=${ydb_dist}; \
        export ydb_chset=${ydb_chset}; \
        export ydb_icu_version=${ydb_icu_version}; \
        export ydb_gbldir=${VISTA_HOME}/g/vista.gld; \
        export ydb_routines='${VISTA_HOME}/r ${ROUTINE_LIBS}'; \
        export LANG=${LANG}; export LC_ALL=${LC_ALL}; \
        ${ydb_dist}/mupip rundown -reg '*' 2>/dev/null; \
        echo 'D BOOT^ZVELPACK HALT' | ${ydb_dist}/yottadb -direct" 2>&1 \
        || echo "  LANGPACK: deferred (packs persist in database)"
fi

if [ "$SSH_ENABLED" = "true" ]; then
    echo "Starting SSH daemon..."
    /usr/sbin/sshd 2>/dev/null || echo "SSH: failed to start (non-fatal)"
fi

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
    server_args  = -run GTMLNX^XWBTCPM
    env          = ydb_gbldir=${ydb_gbldir}
    env         += ydb_routines=${ydb_routines}
    env         += ydb_chset=${ydb_chset}
    env         += ydb_icu_version=${ydb_icu_version}
    env         += LANG=${LANG}
    env         += LC_ALL=${LC_ALL}
    env         += gtm_dist=${ydb_dist}
    log_on_failure += USERID HOST
    log_on_success += PID HOST DURATION
    disable      = no
}
XINETD

echo "Starting RPC Broker via xinetd (port ${BROKER_PORT})..."
echo "Build info:"
cat "${VISTA_HOME}/build-info.txt" 2>/dev/null || echo "  (no build info)"

exec /usr/sbin/xinetd -dontfork