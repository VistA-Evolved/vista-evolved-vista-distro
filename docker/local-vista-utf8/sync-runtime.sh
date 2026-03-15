#!/bin/bash
set -e
VISTA_HOME="${VISTA_HOME:-/opt/vista}"
export gtm_dist=/opt/yottadb/current
export ydb_dist=/opt/yottadb/current
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"
export ydb_chset="${ydb_chset:-UTF-8}"
# NOTE: ydb_env_set bypassed -- its Robustify creates broken SHM when
# before-image journaling is not configured. Set vars directly instead.
export ydb_icu_version=$(pkg-config --modversion icu-io 2>/dev/null || echo "67.1")
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
"$ydb_dist/mupip" rundown -reg "*" >/dev/null 2>&1 || true
echo 'D TERMDEV^ZVEINIT HALT' | "$ydb_dist/yottadb" -direct >/dev/null 2>&1 || true
exec "$ydb_dist/yottadb" -run EN^ZVEINIT