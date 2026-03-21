# Live VistA RPC and Routine Availability Matrix

> Status: LIVE_UTF8_MATRIX
> Date: 2026-03-21
> Source: live probe against `local-vista-utf8`

## Summary Matrix

| Domain | Probe method | Result | Live evidence | Tenant-admin impact |
|------|------|------|------|------|
| Runtime readiness | Canonical UTF-8 healthcheck | PASS | 5 PASS / 0 FAIL | Safe to continue live probing |
| Interactive sign-on | PTY login helper | PASS | reached `ACCESS CODE`, `VERIFY CODE`, and menu prompt | Live operator shell exists |
| Systems menu shell | PTY login helper | PASS | `<LOCAL SANDBOX> Select Systems Manager Menu Option:` | Real menu-backed environment |
| Menu records | M probe on `^DIC(19,...)` | PASS | `XUCORE`, `EVE` nodes present | Kernel menu tree exists |
| Users | M probe on `^VA(200,...)` | PASS | `POSTMASTER`, `SHARED,MAIL`, `PROGRAMMER,ONE` | User discovery is grounded |
| Divisions | M probe on `^DG(40.8,...)` | PASS | `VEHU DIVISION`, `VEHU-PRRTP`, `VEHU CBOC` | Division/facility discovery is grounded |
| Clinics | M probe on `^SC(...)` | PASS | `ALCOHOL`, `DRUGSTER`, `SPINAL CORD INJURY WARD` | Clinic/location discovery is grounded |
| Wards | M probe on `^DIC(42,...)` | PASS | `PSYCHIATRY`, `ALCOHOL`, `DRUGSTER` | Ward discovery is grounded |
| External broker semantic call | Archived Node XWB client | UNVERIFIED | read timeout | Do not claim end-to-end API wiring yet |

## Routines

| Routine | Result | Probe output | Interpretation |
|------|------|------|------|
| `ZVEINIT` | PRESENT | `ZVEINIT: present` | Runtime bootstrap overlay entry exists |
| `ZVEPROB` | MISSING | `ZVEPROB: missing` | Prior probe utility not installed here |
| `ZVESDSEED` | MISSING | `ZVESDSEED: missing` | Optional SDES seed helper absent |
| `VEMCTX3` | MISSING | `VEMCTX3: missing` | Safe context-adder utility absent in this lane |

## Tenant-Admin-Relevant Read RPCs

| RPC | Result | IEN | Interpretation |
|------|------|------|------|
| `ORWU NEWPERS` | REGISTERED | 213 | User search surface exists in File 8994 |
| `ORWU HASKEY` | REGISTERED | 306 | Security-key check surface exists |
| `XUS GET USER INFO` | REGISTERED | 595 | Current-user detail surface exists |
| `XUS DIVISION GET` | REGISTERED | 596 | Division discovery surface exists |
| `ORWU CLINLOC` | REGISTERED | 254 | Clinic/location lookup surface exists |
| `ORQPT WARDS` | REGISTERED | 159 | Ward listing surface exists |

## Scheduling / SDES Readiness

| RPC | Result | Interpretation |
|------|------|------|
| `SDES GET APPT TYPES` | MISSING | Scheduling admin slice should not start here |
| `SDES GET CANCEL REASONS` | MISSING | Scheduling admin slice should not start here |
| `SDES GET RESOURCE BY CLINIC` | MISSING | Scheduling admin slice should not start here |
| `SDES GET CLIN AVAILABILITY` | MISSING | Scheduling admin slice should not start here |

## Decision Signals

- Green: live user, division, clinic, and ward truth exists now.
- Green: the classic Kernel/ORWU read-side RPC names expected by tenant-admin
  are registered now.
- Yellow: registration is not the same as proven over-broker execution.
- Red: SDES-backed scheduling administration is not the first truthful slice in
  this runtime.