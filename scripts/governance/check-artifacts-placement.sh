#!/usr/bin/env bash
# check-artifacts-placement.sh — FAIL if evidence/verification files appear in docs/

set -euo pipefail

EXIT_CODE=0

# Check for common evidence file patterns in docs/
EVIDENCE_PATTERNS=(
  "docs/**/*-output.*"
  "docs/**/*-evidence.*"
  "docs/**/*-proof.*"
  "docs/**/*.log"
  "docs/**/*-report.json"
)

for pattern in "${EVIDENCE_PATTERNS[@]}"; do
  MATCHES=$(find docs/ -name "$(basename "$pattern")" 2>/dev/null || true)
  if [ -n "$MATCHES" ]; then
    echo "WARN: possible evidence file in docs/: $MATCHES"
    echo "  → Evidence should go in artifacts/, not docs/"
  fi
done

# Check for reports/ directory
if [ -d "reports" ] || [ -d "docs/reports" ]; then
  echo "FAIL: forbidden directory found (reports/ or docs/reports/)"
  EXIT_CODE=1
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "PASS: no evidence files found in docs/, no forbidden directories"
fi

exit $EXIT_CODE
