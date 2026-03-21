# How to install ZVEUSMG / ZVECLNM / ZVEWRDM overlay RPCs

These routines live in `overlay/routines/` and register remote procedures in File **8994**.

## Steps

1. Build or copy the `.m` source into the VistA instance `r/` directory as `ZVEUSMG.m`, `ZVECLNM.m`, `ZVEWRDM.m`. Optional: copy `ZVEPROB.m` and run `mumps -r PROBE^ZVEPROB` to print IENs for clinical + **DDR** RPCs in File 8994 (no writes).
2. From programmer mode (DUZ with FileMan privileges), run:
   - `D INSTALL^ZVEUSMG`
   - `D INSTALL^ZVECLNM`
   - `D INSTALL^ZVEWRDM`
3. Add RPCs to the broker application context if required (same pattern as other custom RPC installers).
4. From the tenant-admin host, verify `GET /api/tenant-admin/v1/vista/ddr-probe` and then exercise `POST .../users/:duz/keys` with a sandbox key name.

## RPC names registered

| Routine | RPC name | Tag |
|---------|-----------|-----|
| ZVEUSMG | ZVE USMG KEYS | KEYS |
| ZVEUSMG | ZVE USMG ESIG | ESIG |
| ZVEUSMG | ZVE USMG CRED | CRED |
| ZVEUSMG | ZVE USMG ADD | ADD |
| ZVEUSMG | ZVE USMG DEACT | DEACT |
| ZVEUSMG | ZVE USMG REACT | REACT |
| ZVECLNM | ZVE CLNM ADD | ADD |
| ZVECLNM | ZVE CLNM EDIT | EDIT |
| ZVEWRDM | ZVE WRDM EDIT | EDIT |

## Safety

- Keys use `^XUSEC(KEY,DUZ)` — appropriate for sandboxes; production should follow local IRM policy.
- `DEACT` sets File **200** field **9** (termination date) — confirm against your site's data dictionary.
