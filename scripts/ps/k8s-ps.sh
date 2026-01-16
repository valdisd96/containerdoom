#!/bin/bash
# k8s-ps.sh - Lists Kubernetes pods in psdoom-ng format
# Output format: <user> <pid> <processname> <is_daemon>

MAPFILE="/tmp/psdoom-targets.map"

# Get context and namespace from environment
CONTEXT="${K8S_CONTEXT:-}"
NAMESPACE="${K8S_NAMESPACE:-default}"

# Build kubectl command with optional context
KUBECTL_CMD="kubectl"
if [ -n "$CONTEXT" ]; then
    KUBECTL_CMD="$KUBECTL_CMD --context=$CONTEXT"
fi
KUBECTL_CMD="$KUBECTL_CMD -n $NAMESPACE"

# Clear previous mapping
> "$MAPFILE"

# Counter for pseudo-PIDs
PID_COUNTER=10000

# Get running pods
$KUBECTL_CMD get pods --field-selector=status.phase=Running -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.uid}{"\n"}{end}' 2>/dev/null | while IFS=$'\t' read -r NAME UID; do
    # Skip empty lines
    [ -z "$NAME" ] && continue

    # Truncate name for display (psdoom shows ~7-8 chars)
    DISPLAY_NAME="${NAME:0:8}"

    # Write mapping: pseudo-PID -> pod name
    echo "$PID_COUNTER $NAME $UID k8s" >> "$MAPFILE"

    # Output in psdoom format: user pid name daemon_flag
    echo "k8s $PID_COUNTER $DISPLAY_NAME 1"

    PID_COUNTER=$((PID_COUNTER + 1))
done
