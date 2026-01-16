#!/bin/bash
# docker-kill.sh - Stops a Docker container when killed in psdoom-ng

MAPFILE="/tmp/psdoom-targets.map"
LOGFILE="/tmp/psdoom-kills.log"

# psdoom-ng calls kill command as: PSDOOMKILLCMD <signal> <pid>
SIGNAL="$1"
PSEUDO_PID="$2"

# If called with just one argument, assume it's the PID
if [ -z "$PSEUDO_PID" ]; then
    PSEUDO_PID="$SIGNAL"
fi

# Look up container ID from mapping file
if [ -f "$MAPFILE" ]; then
    CONTAINER_INFO=$(grep "^$PSEUDO_PID " "$MAPFILE" | grep "docker$")
    if [ -n "$CONTAINER_INFO" ]; then
        CONTAINER_ID=$(echo "$CONTAINER_INFO" | awk '{print $2}')
        CONTAINER_NAME=$(echo "$CONTAINER_INFO" | awk '{print $3}')

        echo "[DOCKER] Stopping container: $CONTAINER_NAME ($CONTAINER_ID)"
        docker stop "$CONTAINER_ID" 2>/dev/null

        # Log the kill
        echo "$(date): [DOCKER] Stopped container $CONTAINER_NAME ($CONTAINER_ID)" >> "$LOGFILE"
    fi
fi
