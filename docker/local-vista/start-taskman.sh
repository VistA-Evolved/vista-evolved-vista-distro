#!/bin/bash
set -e
VISTA_HOME="${VISTA_HOME:-/opt/vista}"
export gtm_dist=/opt/yottadb/current
export ydb_dist=/opt/yottadb/current
source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1
export ydb_chset=M
export LC_ALL=C
export gtm_sysid="${VISTA_SYSID:-LOCAL-VISTA}"
export ydb_sysid="${VISTA_SYSID:-LOCAL-VISTA}"
export ydb_gbldir="${VISTA_HOME}/g/vista.gld"
export ydb_routines="${VISTA_HOME}/r $ydb_dist/libyottadbutil.so"
unset gtm_repl_instance
unset ydb_repl_instance
"$ydb_dist/mupip" rundown -reg "*" >/dev/null 2>&1 || true
exec "$ydb_dist/yottadb" -run START^ZVETASK
