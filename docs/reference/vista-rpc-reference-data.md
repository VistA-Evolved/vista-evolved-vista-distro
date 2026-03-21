# VistA RPC Reference Data

> **Purpose:** Central index of all VistA RPC reference material available across the
> VistA Evolved repos. AI coders and team members: read this FIRST before guessing
> at RPC names, parameter formats, return types, or building new RPC calls.

---

## 1. Where the RPC Reference Corpus Lives

The frozen `VistA-Evolved` repo (sibling in the multi-root workspace) contains the
richest RPC reference data accumulated over 580+ phases. These files are **read-only
reference material** — do not modify them.

### Quick Lookup Table

| Need to know... | Read this file (in VistA-Evolved repo) |
|-----------------|----------------------------------------|
| Does RPC X exist in VistA? | `data/vista/vivian/rpc_index.json` (3,747 RPCs) |
| What params does an RPC take? | `data/vista/rpcs/rpc-catalog.json` (~4,500 RPCs with full param specs) |
| What RPCs exist for a domain? | `data/vista/admin-specs/<domain>.json` (15 domain files) |
| Which RPCs are in File 8994 of VEHU? | `data/vista/vista_instance/rpc_present.json` (2,508 RPCs) |
| Which RPCs does CPRS use? | `design/contracts/cprs/v1/rpc_catalog.json` (975 RPCs) |
| How do DDR RPCs work? | `data/vista/admin-specs/fileman.json` + see DDR spec below |
| What RPC contexts exist? | `data/vista/rpcs/rpc-contexts.json` |
| Full Vivian/DOX snapshot | `docs/grounding/vivian-index.json` (~78K lines) |

### Domain Admin Spec Files

Each file has: RPC name, tag, routine, returnType, paramCount, params (name, type, required), description.

`VistA-Evolved/data/vista/admin-specs/` contains:
`fileman.json`, `rpc-broker.json`, `user-security.json`, `allergies.json`,
`order-entry.json`, `pharmacy.json`, `laboratory.json`, `scheduling.json`,
`billing.json`, `radiology.json`, `surgery.json`, `patient-registration.json`,
`clinical-notes.json`, `vitals.json`, `problem-list.json`

---

## 2. DDR RPC Family — Verified Specification

Source: actual MUMPS source code from `WorldVistA/VistA-M` repository on GitHub
(`Packages/VA FileMan/Routines/DDR.m`).

### DDR LISTER (LISTC^DDR)

- **Return type:** GLOBAL ARRAY
- **Parameter:** single LIST (REFERENCE type) with named subscripts:

| Key | Default | Description |
|-----|---------|-------------|
| `FILE` | (required) | VistA file number |
| `IENS` | `""` | Internal entry number string (subfiles) |
| `FIELDS` | (required) | Semicolon-delimited field numbers |
| `FLAGS` | `""` | LIST^DIC flags (I=IEN, P=packed) |
| `MAX` | `"*"` (all) | Max records |
| `FROM` | `""` | Pagination start |
| `PART` | `""` | Partial match |
| `XREF` | `""` | Cross-reference |
| `SCREEN` | `""` | DBS screen |
| `ID` | `""` | Identifier fields |

### DDR GETS ENTRY DATA (GETSC^DDR2) — ARRAY, single LIST param
### DDR FILER (FILEC^DDR3) — ARRAY, LIST + LITERAL params
### DDR VALIDATOR (VALC^DDR3) — ARRAY, single LIST param
### DDR FIND1 (FINDC^DDR4) — ARRAY, single LIST param

---

## 3. Custom ZVE* RPCs (This Repo)

Custom MUMPS routines in `overlay/routines/` that extend VistA:

| Routine | RPCs | Domain |
|---------|------|--------|
| `ZVEUSMG.m` | ZVE USMG ADD, ZVE USMG KEYS, ZVE USMG ESIG, ZVE USMG CRED, ZVE USMG DEACT, ZVE USMG REACT | User management |
| `ZVECLNM.m` | ZVE CLNM ADD, ZVE CLNM EDIT | Clinic management |
| `ZVEWRDM.m` | ZVE WRDM EDIT | Ward management |
| `ZVEPROB.m` | (probe utility) | RPC availability probing |
| `ZVECTXR.m` | (installer) | Context registration |

---

## 4. External Sources

| Source | URL |
|--------|-----|
| Vivian/DOX Browser | https://vivian.worldvista.org/dox |
| VistA-M (MUMPS source) | https://github.com/WorldVistA/VistA-M |
| VA VDL (manuals) | https://www.va.gov/vdl/ |
| VistApedia | https://vistapedia.net |

---

## 5. Rules for AI Coders

1. **Never guess at RPC parameters.** Check `admin-specs/<domain>.json` or `rpc-catalog.json` first.
2. **Never guess whether an RPC exists.** Check `rpc_present.json` (live VEHU) and `rpc_index.json` (Vivian).
3. **For DDR family RPCs:** Use the spec in section 2 above. The MUMPS source is authoritative.
4. **For the full platform-side reference:** See `vista-evolved-platform/docs/reference/vista-rpc-reference-data.md`.
