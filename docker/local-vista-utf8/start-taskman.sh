#!/bin/bash
set -e
VISTA_HOME="${VISTA_HOME:-/opt/vista}"
export gtm_dist=/opt/yottadb/current
export ydb_dist=/opt/yottadb/current
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export ydb_chset="${ydb_chset:-UTF-8}"
source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1
export gtm_sysid="${VISTA_SYSID:-LOCAL-VISTA-UTF8}"
export ydb_sysid="${VISTA_SYSID:-LOCAL-VISTA-UTF8}"
export ydb_gbldir="${VISTA_HOME}/g/vista.gld"
ROUTINE_LIBS="$ydb_dist/utf8/libyottadbutil.so"
if [ -f "$ydb_dist/plugin/o/utf8/_ydbposix.so" ]; then
	ROUTINE_LIBS="$ydb_dist/plugin/o/utf8/_ydbposix.so $ROUTINE_LIBS"
fi
export ydb_routines="${VISTA_HOME}/r $ROUTINE_LIBS"
export gtmroutines="$ydb_routines"
unset gtm_repl_instance
unset ydb_repl_instance
"$ydb_dist/mupip" rundown -reg "*" >/dev/null 2>&1 || true
exec "$ydb_dist/yottadb" -run START^ZVETASK