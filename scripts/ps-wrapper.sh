#!/bin/bash
# ps-wrapper.sh - Unified process listing wrapper
# Routes to appropriate backend based on PSDOOM_MODE

SCRIPT_DIR="$(dirname "$0")"

case "${PSDOOM_MODE:-docker}" in
    docker)
        exec "$SCRIPT_DIR/ps/docker-ps.sh"
        ;;
    k8s|kubernetes)
        exec "$SCRIPT_DIR/ps/k8s-ps.sh"
        ;;
    *)
        echo "Unknown mode: $PSDOOM_MODE" >&2
        exit 1
        ;;
esac
