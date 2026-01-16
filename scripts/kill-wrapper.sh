#!/bin/bash
# kill-wrapper.sh - Unified kill wrapper
# Routes to appropriate backend based on PSDOOM_MODE

SCRIPT_DIR="$(dirname "$0")"

case "${PSDOOM_MODE:-docker}" in
    docker)
        exec "$SCRIPT_DIR/kill/docker-kill.sh" "$@"
        ;;
    k8s|kubernetes)
        exec "$SCRIPT_DIR/kill/k8s-kill.sh" "$@"
        ;;
    *)
        echo "Unknown mode: $PSDOOM_MODE" >&2
        exit 1
        ;;
esac
