# Live VistA Capability Probe Report

> Status: VERIFIED_LIVE_UTF8_PROBE
> Date: 2026-03-21
> Lane: UTF-8 primary lane
> Container: `local-vista-utf8`
> Scope: tenant-admin grounding against the live distro runtime

## Objective

Establish live runtime truth for tenant-admin-relevant capabilities before any
platform slice claims are made. This probe was limited to what the running
UTF-8 distro lane could prove directly: container readiness, interactive
sign-on, menu shell, routine presence, RPC registration, and safe-read data
domains.

## Runtime Preconditions

The canonical UTF-8 readiness script passed against the live container:

```text
CONTAINER_STARTED : PASS
NETWORK_REACHABLE : PASS
SERVICE_READY : PASS
TERMINAL_READY : PASS
RPC_READY : PASS
Total: 5 PASS, 0 FAIL
```

This confirms the repo's primary planned operator lane was already up and
healthy before the capability probe started.

## Live Terminal Proof

The repo's PTY login helper was copied into the container, patched to the
UTF-8 lane credentials, and run against the live sign-on path. The captured
interactive output showed:

```text
VistA Evolved Local Sandbox
YottaDB-backed terminal runtime
Volume set: ROU:gtm_sysid  UCI: VAH  Device: /dev/pts/0
ACCESS CODE:
VERIFY CODE:

Good morning DOCTOR
Select TERMINAL TYPE NAME: C-VT100//
...
<LOCAL SANDBOX> Select Systems Manager Menu Option:
```

This is enough to prove that the UTF-8 lane is not merely booted; it accepts
 live interactive sign-on and lands in a real operator menu shell.

## Deterministic M Probe

A temporary M routine was loaded into the running container and executed under
the UTF-8 runtime environment. It probed:

- routine presence for overlay and utility entry points
- File 8994 RPC registration for tenant-admin-relevant read-side calls
- live menu records in `^DIC(19,...)`
- sample data from users, divisions, clinics, and wards

The resulting live output was:

```text
=== ROUTINES ===
ZVEINIT: present
ZVEPROB: missing
ZVESDSEED: missing
VEMCTX3: missing

=== RPCS ===
ORWU NEWPERS: IEN 213
ORWU HASKEY: IEN 306
XUS GET USER INFO: IEN 595
XUS DIVISION GET: IEN 596
ORWU CLINLOC: IEN 254
ORQPT WARDS: IEN 159
SDES GET APPT TYPES: missing
SDES GET CANCEL REASONS: missing
SDES GET RESOURCE BY CLINIC: missing
SDES GET CLIN AVAILABILITY: missing

=== MENU ===
^DIC(19,38,0)=XUCORE^Core Applications^^M^1039^^^^^^^14^n^^
^DIC(19,28,0)=EVE^Systems Manager Menu^^M^1039^^^^^^^^n^1^^^

=== SAMPLES ===
Users:
  .5: POSTMASTER
  .6: SHARED,MAIL
  1: PROGRAMMER,ONE
Divisions:
  1: VEHU DIVISION
  10: VEHU-PRRTP
  11: VEHU CBOC
Clinics:
  2: ALCOHOL
  3: DRUGSTER
  4: SPINAL CORD INJURY WARD
Wards:
  1: PSYCHIATRY
  2: ALCOHOL
  3: DRUGSTER
```

## What This Proves

- The live UTF-8 lane contains real tenant-admin-relevant data domains.
- The core read-side Kernel/CPRS RPC names expected by tenant-admin are
  registered in File 8994 on this runtime.
- The distro runtime exposes a live Systems Manager shell and live menu tree.
- SDES scheduling RPCs that would support a scheduling-heavy admin slice are
  not registered in this lane today.

## What This Does Not Yet Prove

- It does not prove that an external XWB client can successfully authenticate
  and execute those read-side RPCs end-to-end against the UTF-8 broker.
- It does not prove that missing custom routines such as `ZVEPROB`,
  `ZVESDSEED`, or `VEMCTX3` are installed in the current runtime.
- It does not prove any write path.

An additional read-only broker-semantic probe was attempted using the archived
repo's existing Node XWB client against port `9434`, but that attempt timed out
before returning data. That result is a client-path risk marker, not proof that
the live runtime lacks the underlying data or RPC registrations.

## Commands Run

```powershell
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
& scripts/verify/healthcheck-local-vista-utf8.ps1
docker cp artifacts/pty-login-full.sh local-vista-utf8:/tmp/pty-login-full.sh
docker exec local-vista-utf8 bash -lc "sed -i 's/PROV123!!/PRO1234!!/g; s/PROV123/PRO1234/g' /tmp/pty-login-full.sh && chmod +x /tmp/pty-login-full.sh && /tmp/pty-login-full.sh"
docker exec local-vista-utf8 bash -lc "sed -i 's/\r$//' /tmp/run-zvetapr.sh /opt/vista/r/ZVETAPR.m && chmod +x /tmp/run-zvetapr.sh && /tmp/run-zvetapr.sh"
Set-Location apps/api
$env:VISTA_HOST='127.0.0.1'
$env:VISTA_PORT='9434'
$env:VISTA_ACCESS_CODE='PRO1234'
$env:VISTA_VERIFY_CODE='PRO1234!!'
npx tsx -e "...archived rpc probe..."
```

## Honest Boundary

The runtime/container slice is PASS. The data and registration slice is PASS.
External broker semantics for the tenant-admin read path are still unproven and
must be treated as the next truth gate before anyone claims a live platform
integration slice is complete.