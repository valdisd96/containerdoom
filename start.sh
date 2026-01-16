#!/bin/bash

echo "Starting ContainerDoom..."

# Start Xvfb
Xvfb :99 -screen 0 1280x1024x24 &
XVFB_PID=$!

# Wait for Xvfb to be ready
echo "Waiting for Xvfb to start..."
i=0
while [ $i -lt 30 ]; do
    if xdpyinfo -display :99 >/dev/null 2>&1; then
        echo "Xvfb is ready!"
        break
    fi
    sleep 1
    i=$((i + 1))
done

# Start window manager
DISPLAY=:99 fluxbox &
sleep 2

# Start x11vnc
echo "Starting x11vnc..."
x11vnc -display :99 -forever -shared -rfbauth /root/.vnc/passwd -rfbport 5900 -noxdamage -bg &
sleep 3

# Start noVNC websockify proxy
echo "Starting websockify..."
websockify --web=/usr/share/novnc 6080 localhost:5900 &
sleep 2

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  ContainerDoom - Kill containers by playing DOOM!"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "VNC server ready on port 5900"
echo "noVNC web interface ready on port 6080"
echo "Password: 1234"
echo ""
echo "Access:"
echo "  Browser: http://localhost:6080"
echo "  VNC:     localhost:5900"
echo ""

# Run mode selector if in interactive mode
if [ "$PSDOOM_MODE" = "select" ]; then
    echo "Mode: Interactive selection"
    echo ""
    echo "Open a terminal in the VNC session and run:"
    echo "  /usr/local/bin/scripts/select-mode.sh"
    echo ""
    echo "Then start the game with:"
    echo "  source /tmp/psdoom-config.env && psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window"
else
    echo "Mode: $PSDOOM_MODE"
    if [ "$PSDOOM_MODE" = "k8s" ] || [ "$PSDOOM_MODE" = "kubernetes" ]; then
        echo "Context: ${K8S_CONTEXT:-default}"
        echo "Namespace: ${K8S_NAMESPACE:-default}"
    fi
    echo ""
    echo "To start the game, run in terminal:"
    echo "  psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window"
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

# Export environment variables for psdoom-ng
export PSDOOMPSCMD="/usr/local/bin/scripts/ps-wrapper.sh"
export PSDOOMKILLCMD="/usr/local/bin/scripts/kill-wrapper.sh"

# Keep container running
tail -f /dev/null
