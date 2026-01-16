#!/bin/bash
# select-mode.sh - Interactive mode selector for containerdoom
# Allows user to choose between Docker and Kubernetes modes

CONFIG_FILE="/tmp/psdoom-config.env"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

clear
echo -e "${RED}"
cat << 'EOF'
   ____            _        _                 ____
  / ___|___  _ __ | |_ __ _(_)_ __   ___ _ __|  _ \  ___   ___  _ __ ___
 | |   / _ \| '_ \| __/ _` | | '_ \ / _ \ '__| | | |/ _ \ / _ \| '_ ` _ \
 | |__| (_) | | | | || (_| | | | | |  __/ |  | |_| | (_) | (_) | | | | | |
  \____\___/|_| |_|\__\__,_|_|_| |_|\___|_|  |____/ \___/ \___/|_| |_| |_|
EOF
echo -e "${NC}"
echo -e "${BOLD}Kill containers by playing DOOM!${NC}"
echo ""
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo ""

# Check if mode is already set via environment
if [ -n "$PSDOOM_MODE" ] && [ "$PSDOOM_MODE" != "select" ]; then
    echo -e "${GREEN}Mode pre-configured: $PSDOOM_MODE${NC}"
    if [ "$PSDOOM_MODE" = "k8s" ] || [ "$PSDOOM_MODE" = "kubernetes" ]; then
        echo -e "Context: ${K8S_CONTEXT:-default}"
        echo -e "Namespace: ${K8S_NAMESPACE:-default}"
    fi
    echo ""
    # Write config and exit
    echo "PSDOOM_MODE=$PSDOOM_MODE" > "$CONFIG_FILE"
    echo "K8S_CONTEXT=${K8S_CONTEXT:-}" >> "$CONFIG_FILE"
    echo "K8S_NAMESPACE=${K8S_NAMESPACE:-default}" >> "$CONFIG_FILE"
    exit 0
fi

# Interactive mode selection
echo -e "${CYAN}Select target mode:${NC}"
echo ""
echo -e "  ${BOLD}1)${NC} Docker Containers (local)"
echo -e "  ${BOLD}2)${NC} Kubernetes Cluster"
echo ""
read -p "Enter choice [1-2]: " mode_choice

case $mode_choice in
    1)
        PSDOOM_MODE="docker"
        echo ""
        echo -e "${GREEN}Selected: Docker Containers${NC}"

        # Show available containers
        echo ""
        echo -e "${CYAN}Currently running containers:${NC}"
        docker ps --format "  - {{.Names}} ({{.Image}})" 2>/dev/null || echo "  No containers found or Docker not available"
        ;;
    2)
        PSDOOM_MODE="k8s"
        echo ""
        echo -e "${GREEN}Selected: Kubernetes Cluster${NC}"

        # Get available contexts
        echo ""
        echo -e "${CYAN}Available contexts:${NC}"
        contexts=($(kubectl config get-contexts -o name 2>/dev/null))

        if [ ${#contexts[@]} -eq 0 ]; then
            echo -e "${RED}No Kubernetes contexts found!${NC}"
            echo "Make sure kubeconfig is mounted and valid."
            exit 1
        fi

        i=1
        for ctx in "${contexts[@]}"; do
            current=""
            if [ "$ctx" = "$(kubectl config current-context 2>/dev/null)" ]; then
                current=" ${YELLOW}(current)${NC}"
            fi
            echo -e "  ${BOLD}$i)${NC} $ctx$current"
            ((i++))
        done

        echo ""
        read -p "Select context [1-${#contexts[@]}]: " ctx_choice

        if [ -z "$ctx_choice" ] || [ "$ctx_choice" -lt 1 ] || [ "$ctx_choice" -gt ${#contexts[@]} ] 2>/dev/null; then
            K8S_CONTEXT="${contexts[0]}"
        else
            K8S_CONTEXT="${contexts[$((ctx_choice-1))]}"
        fi

        echo -e "${GREEN}Using context: $K8S_CONTEXT${NC}"

        # Get namespaces
        echo ""
        echo -e "${CYAN}Available namespaces:${NC}"
        namespaces=($(kubectl --context="$K8S_CONTEXT" get namespaces -o jsonpath='{.items[*].metadata.name}' 2>/dev/null))

        if [ ${#namespaces[@]} -eq 0 ]; then
            echo "  Could not fetch namespaces, using 'default'"
            K8S_NAMESPACE="default"
        else
            i=1
            for ns in "${namespaces[@]}"; do
                echo -e "  ${BOLD}$i)${NC} $ns"
                ((i++))
            done

            echo ""
            read -p "Select namespace [1-${#namespaces[@]}]: " ns_choice

            if [ -z "$ns_choice" ] || [ "$ns_choice" -lt 1 ] || [ "$ns_choice" -gt ${#namespaces[@]} ] 2>/dev/null; then
                K8S_NAMESPACE="default"
            else
                K8S_NAMESPACE="${namespaces[$((ns_choice-1))]}"
            fi
        fi

        echo -e "${GREEN}Using namespace: $K8S_NAMESPACE${NC}"

        # Show pods
        echo ""
        echo -e "${CYAN}Running pods in $K8S_NAMESPACE:${NC}"
        kubectl --context="$K8S_CONTEXT" -n "$K8S_NAMESPACE" get pods --field-selector=status.phase=Running -o custom-columns="NAME:.metadata.name" --no-headers 2>/dev/null | while read pod; do
            echo "  - $pod"
        done || echo "  No running pods found"
        ;;
    *)
        echo -e "${RED}Invalid choice, defaulting to Docker${NC}"
        PSDOOM_MODE="docker"
        ;;
esac

# Write configuration
echo "PSDOOM_MODE=$PSDOOM_MODE" > "$CONFIG_FILE"
echo "K8S_CONTEXT=${K8S_CONTEXT:-}" >> "$CONFIG_FILE"
echo "K8S_NAMESPACE=${K8S_NAMESPACE:-default}" >> "$CONFIG_FILE"

echo ""
echo -e "${YELLOW}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}Configuration saved!${NC}"
echo ""
echo -e "${BOLD}To start the game, run:${NC}"
echo -e "  psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window"
echo ""
echo -e "${RED}WARNING: Killing monsters will STOP real containers/pods!${NC}"
echo ""
