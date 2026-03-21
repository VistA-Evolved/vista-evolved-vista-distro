# Live VistA Tenant Admin Feasibility Decision

> Status: GO_WITH_BOUNDARIES
> Date: 2026-03-21
> Basis: live UTF-8 probe package in this repo

## Decision

Proceed to the next slice, but only within a narrow read-only tenant-admin
boundary grounded in live Kernel/ORWU data domains.

## Why This Is A Go

- The primary UTF-8 lane is live and healthy.
- Interactive sign-on and menu-shell proof are real, not inferred.
- Real users, divisions, clinics, and wards are present in the live runtime.
- The specific classic read-side RPC names that tenant-admin expects are
  registered in File 8994:
  - `ORWU NEWPERS`
  - `ORWU HASKEY`
  - `XUS GET USER INFO`
  - `XUS DIVISION GET`
  - `ORWU CLINLOC`
  - `ORQPT WARDS`

## Why This Is Not A Broad Go

- External broker semantics are not yet proven from the actual platform-side
  client path. A read-only Node probe timed out before returning data.
- SDES scheduling RPCs are missing in this lane.
- Optional custom routines that would support broader probing or context setup
  are not installed here.
- No write path has been proven.

## First-Slice Boundary Implied By Live Truth

The first truthful tenant-admin slice should stay inside classic read-side
administrative discovery, not scheduling administration and not write flows.

Allowed first-slice candidates:

- current user and division discovery
- user search and security-key inspection
- clinic/location lookup
- ward listing where needed for topology proof

Disallowed first-slice candidates:

- SDES scheduling administration
- any write or guided-write flow
- any feature that depends on `ZVEPROB`, `ZVESDSEED`, or `VEMCTX3`

## Required Next Truth Gate

Before claiming a live tenant-admin integration slice in the platform repo,
prove at least one actual over-broker read RPC end-to-end on the UTF-8 lane
using the intended client path. The minimum acceptable proof is one of:

- `XUS GET USER INFO`
- `XUS DIVISION GET`
- `ORWU CLINLOC`
- `ORWU NEWPERS`

If that proof fails, stop the queue and classify the next slice as a broker
semantic repair/proof slice instead of a tenant-admin feature slice.

## Bottom Line

The live distro runtime says yes to a narrow, classic read-side tenant-admin
starting point. It does not justify a scheduling-heavy admin slice, a custom
overlay-dependent slice, or any write claim.