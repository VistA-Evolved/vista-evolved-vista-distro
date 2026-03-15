#!/bin/bash
# TCP probe for RPC Broker health check
BROKER_PORT="${VISTA_BROKER_PORT:-9430}"
nc -z -w 3 127.0.0.1 "$BROKER_PORT"
