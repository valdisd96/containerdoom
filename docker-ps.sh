#!/bin/bash
# docker-ps.sh - Lists Docker containers in psdoom-ng format
# Output format: <user> <pid> <processname> <is_daemon>
#
# Since psdoom-ng expects numeric PIDs, we assign sequential IDs
# and maintain a mapping file for the kill script to use.

MAPFILE="/tmp/docker-containers.map"

# Clear previous mapping
> "$MAPFILE"

# Counter for pseudo-PIDs (start at 10000 to avoid conflicts with real PIDs)
PID_COUNTER=10000

# Get running containers (exclude ourselves - the psdoom-ng container)
SELF_CONTAINER=$(hostname)

docker ps --format '{{.ID}}\t{{.Names}}\t{{.Image}}' 2>/dev/null | while IFS=$'\t' read -r ID NAME IMAGE; do
    # Skip if this is the psdoom container itself
    if [[ "$ID" == "$SELF_CONTAINER"* ]] || [[ "$NAME" == "psdoom-ng" ]]; then
        continue
    fi

    # Truncate name for display (psdoom shows ~7-8 chars)
    DISPLAY_NAME="${NAME:0:8}"

    # Write mapping: pseudo-PID -> container ID
    echo "$PID_COUNTER $ID $NAME" >> "$MAPFILE"

    # Output in psdoom format: user pid name daemon_flag
    # Using "docker" as user, 1 for daemon (containers are daemon-like)
    echo "docker $PID_COUNTER $DISPLAY_NAME 1"

    PID_COUNTER=$((PID_COUNTER + 1))
done
