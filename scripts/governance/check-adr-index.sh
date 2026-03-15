#!/usr/bin/env bash
# check-adr-index.sh — FAIL if ADR files are not registered in decision-index.yaml
# Also checks for duplicate enterprise IDs.

set -euo pipefail

INDEX="docs/reference/decision-index.yaml"
EXIT_CODE=0

if [ ! -f "$INDEX" ]; then
  echo "FAIL: decision index not found at $INDEX"
  exit 1
fi

# Check each ADR file is registered
for adr in docs/adrs/ADR-*.md; do
  [ -e "$adr" ] || continue
  if ! grep -q "$(basename "$adr")" "$INDEX"; then
    echo "FAIL: ADR not registered in decision index: $adr"
    EXIT_CODE=1
  fi
done

# Check for duplicate enterprise IDs
DUPES=$(grep -oP 'id:\s+\K\S+' "$INDEX" 2>/dev/null | sort | uniq -d)
if [ -n "$DUPES" ]; then
  echo "FAIL: duplicate ADR IDs in decision index: $DUPES"
  EXIT_CODE=1
fi

# Check enterprise namespace
NON_DISTRO=$(grep -oP 'id:\s+\K\S+' "$INDEX" 2>/dev/null | grep -v '^VE-DISTRO-ADR-' || true)
if [ -n "$NON_DISTRO" ]; then
  echo "WARN: non-distro ADR IDs found (cross-repo refs are OK): $NON_DISTRO"
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "PASS: all ADRs registered, no duplicate IDs"
fi

exit $EXIT_CODE
