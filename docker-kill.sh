#!/bin/bash
# docker-kill.sh - Stops a Docker container when killed in psdoom-ng
# Called by psdoom-ng with: docker-kill.sh <signal> <pseudo-pid>
# We ignore the signal and use the pseudo-pid to find the container

MAPFILE="/tmp/docker-containers.map"

# psdoom-ng calls kill command as: PSDOOMKILLCMD <signal> <pid>
# Default is "kill -9 <pid>", so we receive signal as $1 (e.g., "-9") and pid as $2
SIGNAL="$1"
PSEUDO_PID="$2"

# If called with just one argument, assume it's the PID
if [ -z "$PSEUDO_PID" ]; then
    PSEUDO_PID="$SIGNAL"
fi

# Look up container ID from mapping file
if [ -f "$MAPFILE" ]; then
    CONTAINER_INFO=$(grep "^$PSEUDO_PID " "$MAPFILE")
    if [ -n "$CONTAINER_INFO" ]; then
        CONTAINER_ID=$(echo "$CONTAINER_INFO" | awk '{print $2}')
        CONTAINER_NAME=$(echo "$CONTAINER_INFO" | awk '{print $3}')

        echo "Stopping container: $CONTAINER_NAME ($CONTAINER_ID)"
        docker stop "$CONTAINER_ID" 2>/dev/null

        # Log the kill
        echo "$(date): Stopped container $CONTAINER_NAME ($CONTAINER_ID)" >> /tmp/docker-kills.log
    else
        echo "Container with pseudo-PID $PSEUDO_PID not found in mapping"
    fi
else
    echo "Mapping file not found: $MAPFILE"
fi
