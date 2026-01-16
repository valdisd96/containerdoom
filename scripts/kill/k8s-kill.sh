#!/bin/bash
# k8s-kill.sh - Deletes a Kubernetes pod when killed in psdoom-ng

MAPFILE="/tmp/psdoom-targets.map"
LOGFILE="/tmp/psdoom-kills.log"

# Get context and namespace from environment
CONTEXT="${K8S_CONTEXT:-}"
NAMESPACE="${K8S_NAMESPACE:-default}"

# Build kubectl command with optional context
KUBECTL_CMD="kubectl"
if [ -n "$CONTEXT" ]; then
    KUBECTL_CMD="$KUBECTL_CMD --context=$CONTEXT"
fi
KUBECTL_CMD="$KUBECTL_CMD -n $NAMESPACE"

# psdoom-ng calls kill command as: PSDOOMKILLCMD <signal> <pid>
SIGNAL="$1"
PSEUDO_PID="$2"

# If called with just one argument, assume it's the PID
if [ -z "$PSEUDO_PID" ]; then
    PSEUDO_PID="$SIGNAL"
fi

# Look up pod name from mapping file
if [ -f "$MAPFILE" ]; then
    POD_INFO=$(grep "^$PSEUDO_PID " "$MAPFILE" | grep "k8s$")
    if [ -n "$POD_INFO" ]; then
        POD_NAME=$(echo "$POD_INFO" | awk '{print $2}')

        echo "[K8S] Deleting pod: $POD_NAME (context: ${CONTEXT:-default}, namespace: $NAMESPACE)"
        $KUBECTL_CMD delete pod "$POD_NAME" --grace-period=0 --force 2>/dev/null

        # Log the kill
        echo "$(date): [K8S] Deleted pod $POD_NAME (context: ${CONTEXT:-default}, namespace: $NAMESPACE)" >> "$LOGFILE"
    fi
fi
