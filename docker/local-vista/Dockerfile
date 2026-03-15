# =============================================================================
# vista-evolved-vista-distro -- Local VistA Docker Build
# =============================================================================
# Builds a full VistA instance from locally-imported WorldVistA source
# snapshots in upstream/VistA-M. No network fetch during build.
#
# Build (from repo root):
#   docker build -f docker/local-vista/Dockerfile -t vista-distro:local .
#
# Run:
#   docker run -d -p 9433:9430 -p 2225:22 \
#     -e VISTA_ADMIN_ACCESS=PRO1234 \
#     -e VISTA_ADMIN_VERIFY=PRO1234!! \
#     --name local-vista \
#     vista-distro:local
#
# Build context: repo root (so COPY upstream/VistA-M/... works)
# =============================================================================

ARG YOTTADB_IMAGE=yottadb/yottadb-debian:r2.02

# =============================================================================
# Stage 1: Builder -- load routines + globals from local VistA-M snapshot
# =============================================================================
FROM ${YOTTADB_IMAGE} AS builder

ARG BUILD_SHA=dev
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="vista-evolved-vista-distro (local build)" \
      org.opencontainers.image.description="Full VistA from local WorldVistA/VistA-M snapshot" \
      org.opencontainers.image.revision="${BUILD_SHA}" \
      org.opencontainers.image.created="${BUILD_DATE}"

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy VistA-M Packages from local snapshot (no git clone needed)
WORKDIR /opt/vista-build
COPY upstream/VistA-M/Packages /opt/vista-build/VistA-M/Packages

# Prepare directory structure
RUN mkdir -p /opt/vista/r /opt/vista/g /opt/vista/o /opt/vista/scripts

# --- Copy routines from all packages ---
RUN find /opt/vista-build/VistA-M/Packages -name "*.m" -exec cp {} /opt/vista/r/ \;

# --- Copy overlay routines (ZVE* custom namespace, if any) ---
# Copy the overlay dir, then move any .m files into /opt/vista/r/
COPY overlay/routines/ /tmp/overlay-routines/
RUN find /tmp/overlay-routines -name "*.m" -exec cp {} /opt/vista/r/ \; 2>/dev/null ; \
    rm -rf /tmp/overlay-routines

# --- Copy entrypoint and runtime scripts ---
COPY docker/local-vista/entrypoint.sh /opt/vista/entrypoint.sh
COPY docker/local-vista/health-check.sh /opt/vista/health-check.sh
COPY docker/local-vista/vista-login.sh /opt/vista/vista-login.sh
COPY docker/local-vista/start-taskman.sh /opt/vista/start-taskman.sh
COPY docker/local-vista/check-taskman.sh /opt/vista/check-taskman.sh
COPY docker/local-vista/sync-runtime.sh /opt/vista/sync-runtime.sh
RUN chmod +x /opt/vista/entrypoint.sh /opt/vista/health-check.sh /opt/vista/vista-login.sh /opt/vista/start-taskman.sh /opt/vista/check-taskman.sh /opt/vista/sync-runtime.sh

# --- Configure YottaDB database for VistA ---
# RECORD_SIZE=16368 KEY_SIZE=1019 BLOCK_SIZE=4096
# Temp region for HLTMP/TMP/UTILITY/XTMP etc.
RUN bash -c '\
    export gtm_dist=/opt/yottadb/current && \
    export ydb_chset=M && \
    export LC_ALL=C && \
    source /opt/yottadb/current/ydb_env_set && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    export gtmgbldir=/opt/vista/g/vista.gld && \
    echo "=== Configuring YottaDB database for VistA ===" && \
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

# --- Load globals from VistA-M ---
RUN bash -c '\
    export gtm_dist=/opt/yottadb/current && \
    export ydb_chset=M && \
    export LC_ALL=C && \
    source /opt/yottadb/current/ydb_env_set && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    export ydb_routines="/opt/vista/r $ydb_routines" && \
    echo "=== Loading VistA-M globals ===" && \
    TOTAL=$(find /opt/vista-build/VistA-M/Packages -name "*.zwr" | wc -l) && \
    echo "  Found $TOTAL .zwr files" && \
    CORES=$(($(getconf _NPROCESSORS_ONLN) - 1)) && \
    if [ $CORES -lt 1 ]; then CORES=1; fi && \
    echo "  Using $CORES cores for parallel loading" && \
    find /opt/vista-build/VistA-M/Packages -name "*.zwr" -print0 | \
      xargs -0 -I{} -n 1 -P $CORES $ydb_dist/mupip load \"{}\" \
      >> /opt/vista/g/globals-load.log 2>&1 ; \
    ERRS=$(grep -c "%-E-" /opt/vista/g/globals-load.log 2>/dev/null || echo 0) && \
    echo "=== Globals loading complete ($TOTAL files, errors: $ERRS) ===" \
'

# Write build metadata
RUN echo "BUILD_SHA=${BUILD_SHA}" > /opt/vista/build-info.txt && \
    echo "BUILD_DATE=${BUILD_DATE}" >> /opt/vista/build-info.txt && \
    echo "VISTA_SOURCE=local-snapshot-import" >> /opt/vista/build-info.txt && \
    echo "ROUTINE_COUNT=$(ls /opt/vista/r/*.m 2>/dev/null | wc -l)" >> /opt/vista/build-info.txt && \
    echo "GLOBAL_FILES=$(find /opt/vista-build/VistA-M/Packages -name '*.zwr' | wc -l)" >> /opt/vista/build-info.txt

# --- Run KBANTCLN to initialize VistA kernel (ZTMGRSET replacement) ---
# This populates ^%ZOSF, renames % routines (%ZOSV, %ZISH, %DT, etc.),
# runs DINIT (FileMan init), and configures devices/Taskman.
# Pattern: WorldVistA docker-vista (Sam Habiel)
COPY docker/local-vista/KBANTCLN.m /opt/vista/r/KBANTCLN.m
RUN bash -c '\
    source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    export ydb_chset=M && \
    export ydb_routines="/opt/vista/r $ydb_dist/libyottadbutil.so" && \
    rm -f /opt/vista/r/KBANTCLN.o && \
    cd /opt/vista/r && \
    $ydb_dist/mumps KBANTCLN.m >> /opt/vista/g/compile.log 2>&1 \
'
RUN bash -c '\
    export ydb_chset=M && \
    export LC_ALL=C && \
    source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 && \
    export ydb_chset=M && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    export ydb_routines="/opt/vista/r $ydb_dist/libyottadbutil.so" && \
    echo "=== Running KBANTCLN (VistA kernel init) ===" && \
    $ydb_dist/yottadb -run %XCMD \
      "D START^KBANTCLN(\"ROU\",\"VAH\",999,\"DEMO SYSTEM\",\"LOCALHOST\")" \
      > /opt/vista/g/kbantcln.log 2>&1 && \
    echo "Exit code: $?" && \
    echo "=== KBANTCLN complete ===" \
'

# --- Create demo user (PROV123 / PROV123!!) ---
# Uses VistA kernel APIs: XUSHSH for hashing, UPDATE^DIE for filing
RUN bash -c '\
    export ydb_chset=M && \
    export LC_ALL=C && \
    source /opt/yottadb/current/ydb_env_set >/dev/null 2>&1 && \
    export ydb_chset=M && \
    export ydb_gbldir=/opt/vista/g/vista.gld && \
    export ydb_routines="/opt/vista/r $ydb_dist/libyottadbutil.so" && \
    echo "=== Creating demo user ===" && \
    $ydb_dist/yottadb -run ZVECREUSER > /opt/vista/g/createuser.log 2>&1 && \
    echo "=== Demo user created ===" \
'

# Clean up build-time .o object files (will be recompiled at runtime)
RUN find /opt/vista/r -name "*.o" -delete 2>/dev/null || true

# =============================================================================
# Stage 2: Runtime -- VistA server with RPC Broker + SSH
# =============================================================================
FROM ${YOTTADB_IMAGE} AS runtime

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    xinetd \
    openssh-server \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/sshd

# Create non-root VistA user
RUN groupadd -r vista && useradd -r -g vista -d /opt/vista -s /bin/bash vista && \
    echo "vista:vista" | chpasswd

# Copy built artifacts from builder stage
COPY --from=builder /opt/vista /opt/vista

RUN chown -R vista:vista /opt/vista

# Configure SSH — suppress banners, lock down locale forwarding
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
    VISTA_SYSID=LOCAL-VISTA \
    ydb_chset=M \
    LC_ALL=C \
    gtm_dist=/opt/yottadb/current

EXPOSE 9430 22

HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=3 \
    CMD /opt/vista/health-check.sh || exit 1

WORKDIR /opt/vista
ENTRYPOINT ["/opt/vista/entrypoint.sh"]
