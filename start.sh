#!/bin/bash

echo "Starting psdoom-ng container..."

# Set up psdoom-ng to show Docker containers instead of processes
export PSDOOMPSCMD="/usr/local/bin/docker-ps.sh"
export PSDOOMKILLCMD="/usr/local/bin/docker-kill.sh"

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

echo "VNC server ready on port 5900"
echo "noVNC web interface ready on port 6080"
echo "Password: 1234"
echo ""
echo "=== DOCKER CONTAINER MODE ==="
echo "Monsters in the game represent running Docker containers!"
echo "Killing a monster will STOP the corresponding container."
echo ""
echo "To play:"
echo "1. Connect via browser: http://localhost:6080"
echo "2. Or VNC client: localhost:5900"
echo ""
echo "In the desktop, right-click -> Terminal, then run:"
echo "  psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window"
echo ""
echo "TIP: Start some test containers on your host to see them as enemies!"
echo "  docker run -d --name test1 nginx"
echo "  docker run -d --name test2 redis"
echo ""
echo "Container is ready!"

# Keep container running
tail -f /dev/null
