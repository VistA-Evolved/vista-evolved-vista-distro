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

patch_yottadb_terminal_routines() {
	local routine_dir="${VISTA_HOME}/r"
	local changed=0
	if [ -f "${routine_dir}/_ZISUTL.m" ] && grep -Fq ".I +\$\$VERSION^%ZOSV'>2010 S %=\$ZUTIL(68,40,1)" "${routine_dir}/_ZISUTL.m"; then
		sed -i "s/\.I +\$\$VERSION\^%ZOSV'>2010 S %=\$ZUTIL(68,40,1)/.I +\$\$VERSION^%ZOSV'>2010 S %=1/" "${routine_dir}/_ZISUTL.m"
		changed=1
	fi
	if [ -f "${routine_dir}/_ZIS4.m" ] && grep -Fq '. S (%,%1)=$ZGETDVI($I,"TT_ACCPORNAM")' "${routine_dir}/_ZIS4.m"; then
		sed -i 's/\. S (%,%1)=$ZGETDVI($I,"TT_ACCPORNAM")/. X "S (%,%1)=$ZGETDVI($I,""TT_ACCPORNAM"")"/' "${routine_dir}/_ZIS4.m"
		changed=1
	fi
	if [ "$changed" -eq 1 ]; then
		rm -f "${routine_dir}/_ZISUTL.o" "${routine_dir}/_ZIS4.o"
		(
			cd "${routine_dir}" &&
			"$ydb_dist/mumps" _ZISUTL.m >/dev/null 2>&1 &&
			"$ydb_dist/mumps" _ZIS4.m >/dev/null 2>&1
		)
	fi
}

patch_yottadb_terminal_routines
echo 'D TERMDEV^ZVEINIT HALT' | "$ydb_dist/yottadb" -direct >/dev/null 2>&1 || true
"$ydb_dist/mupip" rundown -reg "*" >/dev/null 2>&1 || true
exec "$ydb_dist/yottadb" -run EN^ZVEINIT