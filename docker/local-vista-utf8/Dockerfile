# =============================================================================
# vista-evolved-vista-distro -- Local VistA Docker Build (UTF-8 lane)
# =============================================================================
# Builds a parallel UTF-8-first VistA instance from the local WorldVistA
# VEHU Plan VI source snapshot in upstream/VistA-VEHU-M-plan-vi. No network
# fetch during build.
#
# Build (from repo root):
#   docker build -f docker/local-vista-utf8/Dockerfile -t vista-distro:local-utf8 .
#
# Run:
#   docker run -d -p 9434:9430 -p 2226:22 \
#     -e VISTA_ADMIN_ACCESS=PRO1234 \
#     -e VISTA_ADMIN_VERIFY=PRO1234!! \
#     --name local-vista-utf8 \
#     vista-distro:local-utf8
#
# Build context: repo root (so COPY upstream/VistA-VEHU-M-plan-vi/... works)
# =============================================================================

ARG YOTTADB_IMAGE=yottadb/yottadb-debian:r2.02

FROM ${YOTTADB_IMAGE} AS builder

ARG BUILD_SHA=dev
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="vista-evolved-vista-distro (local UTF-8 build)" \
    org.opencontainers.image.description="Full VistA from local WorldVistA/VistA-VEHU-M plan-vi snapshot, UTF-8 lane" \
      org.opencontainers.image.revision="${BUILD_SHA}" \
      org.opencontainers.image.created="${BUILD_DATE}"

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    locales \
    recode \
    unzip \
    && sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/vista-build
COPY upstream/VistA-VEHU-M-plan-vi/Packages /opt/vista-build/VistA-VEHU-M-plan-vi/Packages

RUN mkdir -p /opt/vista/r /opt/vista/g /opt/vista/o /opt/vista/scripts

RUN find /opt/vista-build/VistA-VEHU-M-plan-vi/Packages -name "*.m" -exec cp {} /opt/vista/r/ \;

RUN bash -c '\
        echo "=== Preparing local snapshot for UTF-8 import ===" && \
        find /opt/vista-build/VistA-VEHU-M-plan-vi/Packages -name "*.zwr" -print0 | \
            xargs -0 -n 1 sed -i "1cOSEHRA ZGO Export: THIS GLOBAL UTF-8" && \
        find /opt/vista/r -name "*.m" -print0 | \
            xargs -0 -n 1 recode -f iso8859-1..utf-8 && \
        echo "=== UTF-8 snapshot preparation complete ===" \
'

# NOTE: Overlay routines are copied AFTER Kernel-GTM bundle (which overwrites
# upstream .m files). See the overlay COPY below the compile step.

COPY docker/local-vista-utf8/entrypoint.sh /opt/vista/entrypoint.sh
COPY docker/local-vista-utf8/health-check.sh /opt/vista/health-check.sh
COPY docker/local-vista-utf8/vista-login.sh /opt/vista/vista-login.sh
COPY docker/local-vista-utf8/start-taskman.sh /opt/vista/start-taskman.sh
COPY docker/local-vista-utf8/check-taskman.sh /opt/vista/check-taskman.sh
COPY docker/local-vista-utf8/sync-runtime.sh /opt/vista/sync-runtime.sh
RUN chmod +x /opt/vista/entrypoint.sh /opt/vista/health-check.sh /opt/vista/vista-login.sh /opt/vista/start-taskman.sh /opt/vista/check-taskman.sh /opt/vista/sync-runtime.sh

RUN bash -c '\
    export gtm_dist=/opt/yottadb/current && \
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    export ydb_chset=UTF-8 && \
    source /opt/yottadb/current/ydb_env_set && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    export gtmgbldir=/opt/vista/g/vista.gld && \
    echo "=== Configuring YottaDB database for UTF-8 VistA ===" && \
    printf "%s\n" \
      "c -s DEFAULT -ACCESS_METHOD=BG -BLOCK_SIZE=4096 -ALLOCATION=200000 -EXTENSION_COUNT=1024 -GLOBAL_BUFFER_COUNT=4096 -LOCK_SPACE=400 -FILE=/opt/vista/g/vista.dat" \
      "a -s TEMP -ACCESS_METHOD=MM -BLOCK_SIZE=4096 -ALLOCATION=10000 -EXTENSION_COUNT=1024 -GLOBAL_BUFFER_COUNT=4096 -LOCK_SPACE=400 -FILE=/opt/vista/g/temp.dat" \
      "c -r DEFAULT -RECORD_SIZE=16368 -KEY_SIZE=1019 -NOJOURNAL -DYNAMIC_SEGMENT=DEFAULT -NULL_SUBSCRIPTS=ALWAYS" \
      "a -r TEMP -RECORD_SIZE=16368 -KEY_SIZE=1019 -NOJOURNAL -DYNAMIC_SEGMENT=TEMP -NULL_SUBSCRIPTS=ALWAYS" \
      "a -n TMP -r=TEMP" "a -n TEMP -r=TEMP" "a -n UTILITY -r=TEMP" \
      "a -n XTMP -r=TEMP" "a -n XUTL -r=TEMP" "a -n HLTMP -r=TEMP" \
      "a -n BMXTMP -r=TEMP" "a -n VPRHTTP -r=TEMP" "a -n KMPTMP -r=TEMP" \
      "sh -a" \
    | $ydb_dist/yottadb -run GDE && \
    $ydb_dist/mupip create && \
    echo "=== Database configured ===" \
'

# mupip load's internal CLI parser splits arguments on spaces regardless of OS
# quoting. Workaround: stage all .zwr files in a flat directory with underscores
# replacing spaces, then load from there.
RUN bash -c '\
    export gtm_dist=/opt/yottadb/current && \
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    export ydb_chset=UTF-8 && \
    source /opt/yottadb/current/ydb_env_set && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    export ydb_routines="/opt/vista/r $ydb_routines" && \
    echo "=== Loading VEHU Plan VI globals (UTF-8 lane) ===" && \
    TOTAL=$(find /opt/vista-build/VistA-VEHU-M-plan-vi/Packages -name "*.zwr" | wc -l) && \
    echo "  Found $TOTAL .zwr files" && \
    echo "  Staging .zwr files (removing spaces from filenames)..." && \
    mkdir -p /tmp/zwr-stage && \
    find /opt/vista-build/VistA-VEHU-M-plan-vi/Packages -name "*.zwr" -print0 | \
      while IFS= read -r -d "" src; do \
        rel="${src#/opt/vista-build/VistA-VEHU-M-plan-vi/Packages/}"; \
        safename=$(echo "$rel" | tr " /" "__"); \
        cp "$src" "/tmp/zwr-stage/$safename"; \
      done && \
    STAGED=$(ls /tmp/zwr-stage/*.zwr | wc -l) && \
    echo "  Staged $STAGED files" && \
    CORES=$(($(getconf _NPROCESSORS_ONLN) - 1)) && \
    if [ $CORES -lt 1 ]; then CORES=1; fi && \
    echo "  Using $CORES cores for parallel loading" && \
    find /tmp/zwr-stage -name "*.zwr" -print0 | \
      xargs -0 -n 1 -P $CORES $ydb_dist/mupip load \
      >> /opt/vista/g/globals-load.log 2>&1 ; \
    ERRS=$(grep -c "YDB-E-" /opt/vista/g/globals-load.log 2>/dev/null || echo 0) && \
    echo "=== Globals loading complete ($TOTAL source files, $STAGED staged, errors: $ERRS) ===" && \
    rm -rf /tmp/zwr-stage \
'

RUN echo "BUILD_SHA=${BUILD_SHA}" > /opt/vista/build-info.txt && \
    echo "BUILD_DATE=${BUILD_DATE}" >> /opt/vista/build-info.txt && \
    echo "VISTA_SOURCE=upstream/VistA-VEHU-M-plan-vi" >> /opt/vista/build-info.txt && \
    echo "BUILD_LANE=UTF-8" >> /opt/vista/build-info.txt && \
    echo "ROUTINE_COUNT=$(ls /opt/vista/r/*.m 2>/dev/null | wc -l)" >> /opt/vista/build-info.txt && \
    echo "GLOBAL_FILES=$(find /opt/vista-build/VistA-VEHU-M-plan-vi/Packages -name '*.zwr' | wc -l)" >> /opt/vista/build-info.txt

ARG KERNEL_GTM_RELEASE=XU-8.0-10006
ARG KERNEL_GTM_ZIP_URL=https://github.com/shabiel/Kernel-GTM/releases/download/XU-8.0-10006/virgin_install.zip

RUN bash -c '\
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    export ydb_chset=UTF-8 && \
    source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 && \
    export ydb_chset=UTF-8 && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    ROUTINE_LIBS="$ydb_dist/utf8/libyottadbutil.so" && \
    if [ -f "$ydb_dist/plugin/o/utf8/_ydbposix.so" ]; then ROUTINE_LIBS="$ydb_dist/plugin/o/utf8/_ydbposix.so $ROUTINE_LIBS"; fi && \
    export ydb_routines="/opt/vista/r $ROUTINE_LIBS" && \
    export gtmroutines="$ydb_routines" && \
    echo "=== Applying Kernel-GTM compatibility bundle (${KERNEL_GTM_RELEASE}) ===" && \
    curl -fsSLo /tmp/virgin_install.zip "${KERNEL_GTM_ZIP_URL}" && \
    unzip -qo /tmp/virgin_install.zip -d /opt/vista/r/ && \
    rm -f /tmp/virgin_install.zip && \
    find /opt/vista/r -maxdepth 1 -name "*.o" -delete && \
    echo "=== Compiling routines under UTF-8 ===" && \
    CORES=$(($(getconf _NPROCESSORS_ONLN) - 1)) && \
    if [ $CORES -lt 1 ]; then CORES=1; fi && \
    cd /opt/vista/r && \
    set +e && \
    find . -maxdepth 1 -name "*.m" -print0 | \
      xargs -0 -n 1 -P $CORES $ydb_dist/mumps \
            >> /opt/vista/g/compile.log 2>&1 ; \
        COMPILE_STATUS=$? && \
    set -e && \
    echo "=== Routine compile complete (status: ${COMPILE_STATUS}) ===" \
'

# Apply overlay routines AFTER Kernel-GTM bundle + compile (Kernel-GTM overwrites
# upstream copies of XLFIPV.m, XUSHSH.m, etc.). Must be a separate layer so
# overlay files take precedence.
COPY overlay/routines/ /tmp/overlay-routines/
RUN bash -c '\
    export ydb_chset=UTF-8 && \
    source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    ROUTINE_LIBS="$ydb_dist/utf8/libyottadbutil.so" && \
    if [ -f "$ydb_dist/plugin/o/utf8/_ydbposix.so" ]; then ROUTINE_LIBS="$ydb_dist/plugin/o/utf8/_ydbposix.so $ROUTINE_LIBS"; fi && \
    export ydb_routines="/opt/vista/r $ROUTINE_LIBS" && \
    export gtmroutines="$ydb_routines" && \
    echo "=== Applying overlay routines ===" && \
    cp /tmp/overlay-routines/*.m /opt/vista/r/ && \
    rm -rf /tmp/overlay-routines && \
    cd /opt/vista/r && \
    for f in XLFIPV.m XUSHSH.m XUS1A.m ZVEINIT.m ZVECREUSER.m; do \
        [ -f "$f" ] && { rm -f "${f%.m}.o"; $ydb_dist/mumps "$f" >> /opt/vista/g/compile.log 2>&1 || true; echo "  Compiled: $f"; } \
    done && \
    echo "=== Overlay routines applied and compiled ===" \
'

COPY docker/local-vista/KBANTCLN.m /opt/vista/r/KBANTCLN.m
RUN bash -c '\
    export ydb_chset=UTF-8 && \
    source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    ROUTINE_LIBS="$ydb_dist/utf8/libyottadbutil.so" && \
    if [ -f "$ydb_dist/plugin/o/utf8/_ydbposix.so" ]; then ROUTINE_LIBS="$ydb_dist/plugin/o/utf8/_ydbposix.so $ROUTINE_LIBS"; fi && \
    export ydb_routines="/opt/vista/r $ROUTINE_LIBS" && \
    export gtmroutines="$ydb_routines" && \
    rm -f /opt/vista/r/KBANTCLN.o && \
    cd /opt/vista/r && \
    $ydb_dist/mumps KBANTCLN.m >> /opt/vista/g/compile.log 2>&1 \
'
RUN bash -c '\
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    export ydb_chset=UTF-8 && \
    source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 && \
    export ydb_chset=UTF-8 && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    ROUTINE_LIBS="$ydb_dist/utf8/libyottadbutil.so" && \
    if [ -f "$ydb_dist/plugin/o/utf8/_ydbposix.so" ]; then ROUTINE_LIBS="$ydb_dist/plugin/o/utf8/_ydbposix.so $ROUTINE_LIBS"; fi && \
    export ydb_routines="/opt/vista/r $ROUTINE_LIBS" && \
    export gtmroutines="$ydb_routines" && \
    echo "=== Running KBANTCLN (UTF-8 lane) ===" && \
    $ydb_dist/yottadb -run %XCMD \
      "D START^KBANTCLN(\"ROU\",\"VAH\",999,\"DEMO SYSTEM UTF8\",\"LOCALHOST\")" \
            > /opt/vista/g/kbantcln.log 2>&1 || { cat /opt/vista/g/kbantcln.log; exit 253; } && \
    echo "Exit code: $?" && \
    echo "=== KBANTCLN complete ===" \
'

RUN bash -c '\
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8 && \
    export ydb_chset=UTF-8 && \
    source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 && \
    export ydb_chset=UTF-8 && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    ROUTINE_LIBS="$ydb_dist/utf8/libyottadbutil.so" && \
    if [ -f "$ydb_dist/plugin/o/utf8/_ydbposix.so" ]; then ROUTINE_LIBS="$ydb_dist/plugin/o/utf8/_ydbposix.so $ROUTINE_LIBS"; fi && \
    export ydb_routines="/opt/vista/r $ROUTINE_LIBS" && \
    export gtmroutines="$ydb_routines" && \
    echo "=== Creating demo user (UTF-8 lane) ===" && \
    $ydb_dist/yottadb -run ZVECREUSER > /opt/vista/g/createuser.log 2>&1 || { cat /opt/vista/g/createuser.log; exit 253; } && \
    echo "=== Demo user created ===" \
'

RUN find /opt/vista/r -name "*.o" -delete 2>/dev/null || true

FROM ${YOTTADB_IMAGE} AS runtime

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    xinetd \
    openssh-server \
    netcat-openbsd \
    locales \
    && sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

RUN groupadd -r vista && useradd -r -g vista -d /opt/vista -s /bin/bash vista && \
    echo "vista:vista" | chpasswd

COPY --from=builder /opt/vista /opt/vista

RUN chown -R vista:vista /opt/vista

RUN sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "AllowUsers vista" >> /etc/ssh/sshd_config && \
    sed -i 's/^#*PrintMotd.*/PrintMotd no/' /etc/ssh/sshd_config && \
    sed -i 's/^#*PrintLastLog.*/PrintLastLog no/' /etc/ssh/sshd_config && \
    sed -i '/^AcceptEnv/d' /etc/ssh/sshd_config && \
    echo "Banner none" >> /etc/ssh/sshd_config && \
    : > /etc/motd && rm -f /etc/update-motd.d/* && \
    ssh-keygen -A

RUN echo '/opt/vista/vista-login.sh' >> /etc/shells && \
    usermod -s /opt/vista/vista-login.sh vista

ENV VISTA_BROKER_PORT=9430 \
    VISTA_HOME=/opt/vista \
    VISTA_ADMIN_ACCESS="" \
    VISTA_ADMIN_VERIFY="" \
    VISTA_BROKER_BIND=0.0.0.0 \
    VISTA_SSH_ENABLED=true \
    VISTA_TASKMAN_ENABLED=true \
    VISTA_SYSID=LOCAL-VISTA-UTF8 \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    ydb_chset=UTF-8 \
    gtm_dist=/opt/yottadb/current

EXPOSE 9430 22

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
    CMD /opt/vista/health-check.sh || exit 1

WORKDIR /opt/vista
ENTRYPOINT ["/opt/vista/entrypoint.sh"]