# Language Availability Ledger

> Product-policy document. Single source of truth for language support
> status, scope, and readiness in the VistA Evolved distro.
>
> Scope: Terminal-shell (SSH/xterm.js) interactions only.
> Does not cover GUI/web, control-plane, or package-level text.
>
> Last updated: 2025-07-14

---

## Tier Definitions

| Tier | Label | What the user sees | Requirements |
|------|-------|-------------------|--------------|
| **Reference** | English | All prompts, menus, help text in English | Built-in. No pack needed. |
| **Shell-Ready** | Level 2+ | Sign-on, YES/NO, menu prompts, help text translated | Language pack with 26+ dialog translations, live-proven |
| **Format-Ready** | Level 1 | Locale-correct dates, numbers, ordinals | Formatting nodes loaded in LANGUAGE file (.85) |
| **Registry-Only** | Level 0 | Language entry exists in File .85; no visible difference | IEN in LANGUAGE file, UTF-8 runtime renders any text |
| **Not Registered** | — | No entry in File .85 | Would need LANGUAGE file entry + pack creation |

---

## Language Classification

| Language | ISO 639-1 | IEN (.85) | Tier | Level | Evidence | Notes |
|----------|-----------|-----------|------|-------|----------|-------|
| **English** | en | 1 | Reference | — | Built-in | VistA's native language. All text hardcoded in English. |
| **Korean** | ko | 198 | Shell-Ready | 2 | LIVE-PROVEN 2025-07-14 | 34 dialogs (4 YES/NO + 20 menu + 2 sign-on + 8 cover sheet). 3/7 formatting nodes. Full sign-on + menu proven in browser. |
| **Spanish** | es | 3 | Shell-Ready | 2 | LIVE-PROVEN 2025-07-14 | 26 dialogs (4 YES/NO + 20 menu + 2 sign-on). 7/7 formatting nodes. CRD/ORD live-proven. Sign-on + menu + help proven in browser. |
| **German** | de | 2 | Format-Ready | 1 | Container-verified | 7/7 formatting nodes loaded (Plan VI). 0 dialogs. Dates, numbers, ordinals load correctly. No browser proof yet. |
| **French** | fr | (check) | Registry-Only | 0 | File .85 entry exists | Standard VistA LANGUAGE file includes French. No pack, no formatting, no dialogs. |
| **Chinese (Traditional)** | zh | (check) | Registry-Only | 0 | File .85 entry exists | Standard VistA LANGUAGE file includes Chinese. No pack. |
| **Japanese** | ja | (check) | Registry-Only | 0 | File .85 entry exists | Standard VistA LANGUAGE file includes Japanese. No pack. |
| **Vietnamese** | vi | (check) | Registry-Only | 0 | File .85 entry may exist | High clinical demand (VA patient population). No pack. |
| **Tagalog** | tl | (check) | Registry-Only | 0 | File .85 entry may exist | Filipino healthcare workforce. No pack. |
| **Arabic** | ar | (check) | Not Registered | — | No entry found | RTL layout would require Kernel changes beyond overlay. |

---

## Promotion Criteria

### Registry-Only → Format-Ready (Level 0 → 1)
1. Verify IEN exists in LANGUAGE file (.85)
2. Create `overlay/l10n/<iso2>/formatting.m` with 7 formatting nodes (DD, FMTE, CRD, LC, UC, ORD, TIME)
3. Load into container and verify via M probes
4. Create `manifest.json` with coverage map

### Format-Ready → Shell-Ready (Level 1 → 2)
1. Translate 26 core shell dialogs (4 YES/NO + 20 menu + 2 sign-on)
2. Second-pass quality review (native speaker or critical self-review)
3. Create `overlay/l10n/<iso2>/dialogs.m` with translations
4. Load into container and verify 26/26 count
5. Live browser proof: sign-on, menu, help text, rollback

### Shell-Ready → Menu-Translated (Level 2 → 3)
1. Run `TRAMENU^UKOP6TRA` with translation API key
2. Verify translated menu item names display correctly
3. Create `overlay/l10n/<iso2>/menus.m`
4. Browser proof of translated menu items

---

## Production Policy Rules

1. **English is always the fallback.** If a dialog has no translation for
   the active language, VistA falls back to the English original.
2. **y/n shortkeys are preserved.** VistA Kernel reads `Y`, `N`, `YES`, `NO`
   for control flow. Translated YES/NO prompts display localized text but
   accept `y`/`n` input (VistA Kernel handles this via dialog 7003 mapping).
3. **No machine translation in production.** All Level 2+ dialog text must
   be human-reviewed. The `TRAMENU^UKOP6TRA` pipeline (Level 3) uses MS
   Translate API but output requires human validation before committing.
4. **Rollback is instant.** Clearing `KSP` piece 7 or the user's `^VA(200)`
   piece 7 immediately restores English for the next session.
5. **Per-user language override is supported.** A site can default to Spanish
   while individual users override to English (or vice versa).
6. **UTF-8 runtime is prerequisite.** All language packs require `ydb_chset=UTF-8`.
   The `local-vista-utf8` container provides this.

---

## Priority Queue (Next Languages)

Based on clinical demand, workforce demographics, and implementation effort:

| Priority | Language | Rationale | Effort Estimate |
|----------|----------|-----------|-----------------|
| 1 | German | Already Format-Ready (L1). Only needs 26 dialog translations to reach L2. | Small — formatting done, dialog pattern proven. |
| 2 | French | High demand in international deployments. | Medium — needs formatting nodes + 26 dialogs. |
| 3 | Tagalog | Filipino Healthcare workforce (US + PH deployments). | Medium — needs IEN check + formatting + 26 dialogs. |
| 4 | Vietnamese | VA patient population demand. | Medium — same as Tagalog. |
| 5 | Chinese (Traditional) | International. CJK rendering proven by Korean. | Medium — needs formatting + 26 dialogs. |
| 6 | Japanese | International. CJK rendering proven by Korean. | Medium — needs formatting + 26 dialogs. |
| 7 | Arabic | RTL layout is a hard Kernel constraint. | Large — RTL requires upstream changes. |

---

## Proven Patterns

These patterns are established and reusable for any new language:

- **Dialog loader**: M routine with `STARTER` entrypoint, `$C()` for Unicode,
  3 `SET ^DI(.84,...)` lines per dialog. See `ko/dialogs.m`, `es/dialogs.m`.
- **Formatting loader**: M routine setting 7 named subscripts in `^DI(.85)`.
  See `ko/formatting.m`, `es/formatting.m`.
- **Language switch utility**: `ZVELSET.m` with `SITE<ISO2>` and `USER<ISO2>`
  entry points for testing. Sets `KSP` piece 7 for site default, `^VA(200)`
  piece 7 for user override.
- **Browser proof sequence**: Open xterm.js tab → verify sign-on prompt →
  login → verify menu prompt → type `?` → verify help text → type `??` →
  verify extended help → HALT → switch language → reconnect → verify switch.
