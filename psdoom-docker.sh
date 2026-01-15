#!/bin/bash
# Wrapper script to run psdoom-ng with Docker container mode enabled

export PSDOOMPSCMD="/usr/local/bin/docker-ps.sh"
export PSDOOMKILLCMD="/usr/local/bin/docker-kill.sh"

echo "Starting psdoom-ng in Docker Container Mode..."
echo "Enemies represent running Docker containers!"
echo ""

# Run psdoom-ng with all passed arguments
exec psdoom-ng "$@"
