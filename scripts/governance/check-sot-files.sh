#!/usr/bin/env bash
# check-sot-files.sh — FAIL if required governance files are missing

set -euo pipefail

EXIT_CODE=0
REQUIRED_FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  "docs/reference/source-of-truth-index.md"
  "docs/reference/doc-governance.md"
  "docs/reference/decision-index.yaml"
  "docs/reference/runtime-truth.md"
  "docs/reference/upstream-source-strategy.md"
  "docs/reference/customization-policy.md"
  "docs/reference/runtime-readiness-levels.md"
  "docs/reference/runtime-proof-policy.md"
  "docs/reference/port-registry.md"
  "docs/explanation/governed-build-protocol.md"
  "docs/adrs/VE-DISTRO-ADR-0001-upstream-overlay-policy.md"
  "docs/adrs/VE-DISTRO-ADR-0002-local-source-first-builds.md"
  "docs/adrs/VE-DISTRO-ADR-0003-utf8-primary-lane.md"
  "locks/worldvista-sources.lock.json"
)

for f in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$f" ]; then
    echo "FAIL: required file missing: $f"
    EXIT_CODE=1
  fi
done

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "PASS: all required governance files present"
fi

exit $EXIT_CODE
