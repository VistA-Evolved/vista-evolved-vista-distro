#!/usr/bin/env bash
# check-adr-index.sh — 5-gate distro ADR governance check
# Gate 1: Every ADR file in docs/adrs/ must be registered in decision-index.yaml
# Gate 2: No legacy ADR filenames (ADR-NNNN-*) allowed
# Gate 3: No duplicate ADR files (same base name, different prefix)
# Gate 4: H1 line must start with enterprise ID (VE-DISTRO-ADR-NNNN)
# Gate 5: No duplicate enterprise IDs in decision-index.yaml

set -euo pipefail

INDEX="docs/reference/decision-index.yaml"
EXIT_CODE=0
GATES_CHECKED=0

if [ ! -f "$INDEX" ]; then
  echo "FAIL: decision index not found at $INDEX"
  exit 1
fi

# Gate 1: Every ADR file is registered
for adr in docs/adrs/VE-DISTRO-ADR-*.md; do
  [ -e "$adr" ] || continue
  if ! grep -q "$(basename "$adr")" "$INDEX"; then
    echo "FAIL [Gate 1]: ADR not registered in decision index: $adr"
    EXIT_CODE=1
  fi
done
GATES_CHECKED=$((GATES_CHECKED + 1))

# Gate 2: Reject legacy ADR filenames
for legacy in docs/adrs/ADR-[0-9]*.md; do
  [ -e "$legacy" ] || continue
  echo "FAIL [Gate 2]: legacy ADR filename found (must be VE-DISTRO-ADR-*): $legacy"
  EXIT_CODE=1
done
GATES_CHECKED=$((GATES_CHECKED + 1))

# Gate 3: Duplicate file detection (same suffix, different prefix)
declare -A SEEN_BASES
for adr in docs/adrs/*.md; do
  [ -e "$adr" ] || continue
  base=$(basename "$adr")
  [ "$base" = "index.md" ] && continue
  # Strip any prefix up to the first digit group
  suffix=$(echo "$base" | sed 's/^.*ADR-[0-9]*//')
  if [ -n "${SEEN_BASES[$suffix]+x}" ]; then
    echo "FAIL [Gate 3]: duplicate ADR files with same base: ${SEEN_BASES[$suffix]} and $base"
    EXIT_CODE=1
  fi
  SEEN_BASES[$suffix]="$base"
done
GATES_CHECKED=$((GATES_CHECKED + 1))

# Gate 4: H1 must start with enterprise ID
for adr in docs/adrs/VE-DISTRO-ADR-*.md; do
  [ -e "$adr" ] || continue
  base=$(basename "$adr" .md)
  # Extract the enterprise ID from the filename (e.g., VE-DISTRO-ADR-0001)
  eid=$(echo "$base" | grep -oP '^VE-DISTRO-ADR-\d+' || true)
  if [ -z "$eid" ]; then
    echo "FAIL [Gate 4]: cannot extract enterprise ID from filename: $adr"
    EXIT_CODE=1
    continue
  fi
  h1=$(head -1 "$adr")
  if ! echo "$h1" | grep -q "^# ${eid}:"; then
    echo "FAIL [Gate 4]: H1 does not start with enterprise ID ($eid): $adr"
    echo "  Found: $h1"
    EXIT_CODE=1
  fi
done
GATES_CHECKED=$((GATES_CHECKED + 1))

# Gate 5: No duplicate enterprise IDs in decision-index
DUPES=$(grep -oP 'id:\s+\K\S+' "$INDEX" 2>/dev/null | sort | uniq -d)
if [ -n "$DUPES" ]; then
  echo "FAIL [Gate 5]: duplicate ADR IDs in decision index: $DUPES"
  EXIT_CODE=1
fi
GATES_CHECKED=$((GATES_CHECKED + 1))

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "PASS: all ADR governance checks passed ($GATES_CHECKED gates)"
fi

exit $EXIT_CODE
