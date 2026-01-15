# psdoom-docker

A Dockerized version of **psdoom-ng** - the classic DOOM game where monsters represent running Docker containers. Kill a monster, stop a container!

## Project Overview

This project packages psdoom-ng in a Docker container with VNC/noVNC access, modified to target Docker containers instead of system processes. It's a fun and visual way to manage containers.

## Project Structure

```
psdoom-docker/
├── Dockerfile           # Multi-stage build for psdoom-ng with VNC
├── docker-compose.yml   # Service definition with Docker socket mount
├── start.sh             # Container entrypoint (Xvfb, VNC, noVNC)
├── docker-ps.sh         # Lists containers in psdoom format
├── docker-kill.sh       # Stops containers when killed in game
├── psdoom-docker.sh     # Wrapper script for running psdoom-ng
└── README.md            # User documentation
```

## Key Components

### Dockerfile
- Base: Ubuntu 22.04
- Builds psdoom-ng from source (ChrisTitusTech/psdoom-ng)
- Includes Xvfb, x11vnc, noVNC, fluxbox
- Downloads DOOM shareware WAD
- Installs Docker CLI for container management

### Docker Integration Scripts

| Script | Purpose |
|--------|---------|
| `docker-ps.sh` | Lists running containers in psdoom format (user, pid, name, daemon_flag) |
| `docker-kill.sh` | Maps pseudo-PIDs to container IDs and runs `docker stop` |
| `psdoom-docker.sh` | Wrapper that sets environment variables and launches game |

### Environment Variables
- `PSDOOMPSCMD` - Path to process listing script (`/usr/local/bin/docker-ps.sh`)
- `PSDOOMKILLCMD` - Path to kill script (`/usr/local/bin/docker-kill.sh`)
- `DISPLAY` - X11 display (`:99` for Xvfb)

## Ports

| Port | Service |
|------|---------|
| 5900 | VNC server |
| 6080 | noVNC web interface |

## Development Commands

### Build
```bash
docker compose build
```

### Run
```bash
docker compose up -d
```

### Access
- Browser: http://localhost:6080 (password: `1234`)
- VNC client: localhost:5900

### Launch game manually
```bash
docker exec -e DISPLAY=:99 psdoom-ng psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window
```

### View logs
```bash
docker compose logs -f psdoom-ng
```

### Stop
```bash
docker compose down
```

## How Container Killing Works

1. `docker-ps.sh` runs periodically, listing containers with pseudo-PIDs (starting at 10000)
2. Mapping stored in `/tmp/docker-containers.map` (format: `pseudo-pid container-id container-name`)
3. When a monster dies, psdoom-ng calls `docker-kill.sh` with the pseudo-PID
4. `docker-kill.sh` looks up the container ID and runs `docker stop`
5. Kill events logged to `/tmp/docker-kills.log`

## Testing

Create test containers to appear as enemies:
```bash
docker run -d --name test1 nginx
docker run -d --name test2 redis
docker run -d --name test3 alpine sleep 3600
```

## Important Notes

- The psdoom-ng container excludes itself from the enemy list
- Container names truncated to 8 characters for display
- Requires Docker socket mount (`/var/run/docker.sock`) for container management
- VNC password is hardcoded as `1234`

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No enemies in game | Check if other containers are running: `docker ps` |
| VNC connection refused | Verify container is running: `docker compose ps` |
| Game won't start | Check Xvfb: `docker exec psdoom-ng xdpyinfo -display :99` |
| Container not stopping | Check Docker socket mount and permissions |
| WAD file missing | Rebuild image or manually download doom1.wad |

## Game Controls

- **Arrow keys** - Move
- **Ctrl** - Shoot
- **Space** - Open doors
- **Shift** - Run
- **1-7** - Select weapon
- **Esc** - Menu
