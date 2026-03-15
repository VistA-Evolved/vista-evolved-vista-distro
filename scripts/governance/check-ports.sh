#!/usr/bin/env bash
# check-ports.sh — WARN for suspicious hardcoded ports in scripts and Docker files

set -euo pipefail

EXIT_CODE=0

# Known registered ports (from docs/reference/port-registry.md)
KNOWN_PORTS="9433|2225|9434|2226"

# Scan for hardcoded port numbers in scripts and Docker files
# Exclude lock files, artifacts, upstream, and node_modules
SUSPICIOUS=$(grep -rn --include='*.ps1' --include='*.sh' --include='*.yml' --include='*.yaml' \
  --include='Dockerfile' --include='*.json' \
  -E ':[0-9]{4,5}|port[= ]+[0-9]{4,5}' \
  scripts/ docker/ 2>/dev/null | \
  grep -vE "($KNOWN_PORTS)" | \
  grep -vE '(lock\.json|\.git/|upstream/|artifacts/)' || true)

if [ -n "$SUSPICIOUS" ]; then
  echo "WARN: possible unregistered ports found (check docs/reference/port-registry.md):"
  echo "$SUSPICIOUS"
else
  echo "PASS: no suspicious unregistered ports found"
fi

exit $EXIT_CODE
