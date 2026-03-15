#!/usr/bin/env bash
# check-doc-roots.sh — FAIL if unapproved directories exist under docs/
# Approved: tutorials, how-to, reference, explanation, adrs, runbooks

set -euo pipefail

APPROVED="tutorials how-to reference explanation adrs runbooks"
EXIT_CODE=0

for dir in docs/*/; do
  dirname=$(basename "$dir")
  if ! echo "$APPROVED" | grep -qw "$dirname"; then
    echo "FAIL: unapproved directory docs/$dirname/"
    EXIT_CODE=1
  fi
done

# Check for stray .md files at docs root (index.md is allowed)
for f in docs/*.md; do
  [ -e "$f" ] || continue
  fname=$(basename "$f")
  if [ "$fname" != "index.md" ] && [ "$fname" != "vista_evolved_project_context_master.md" ]; then
    echo "WARN: stray file at docs root: $fname (should be in a subcategory)"
  fi
done

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "PASS: all doc directories are approved"
fi

exit $EXIT_CODE
