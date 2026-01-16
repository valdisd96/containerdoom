# ContainerDoom

Kill Docker containers or Kubernetes pods by playing DOOM!

A Dockerized version of **psdoom-ng** with support for both local Docker containers and Kubernetes clusters.

## Features

- Play DOOM in your browser via noVNC
- **Docker mode**: Monsters represent running Docker containers
- **Kubernetes mode**: Monsters represent pods in your cluster
- Interactive mode selector or environment variable configuration
- Support for multiple K8s contexts and namespaces

## Prerequisites

- Docker & Docker Compose
- (Optional) kubectl configured with cluster access

## Quick Start

### Build

```bash
docker compose build
```

### Run

```bash
docker compose up -d
```

### Play

1. Open browser: **http://localhost:6080**
2. Password: `1234`
3. Right-click → Terminal
4. Run mode selector:

```bash
/usr/local/bin/scripts/select-mode.sh
```

5. Start the game:

```bash
source /tmp/psdoom-config.env && psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window
```

## One-Command Launch

Start the game directly from your terminal (no VNC interaction needed):

### Docker Mode

```bash
docker exec -d -e DISPLAY=:99 -e PSDOOM_MODE=docker containerdoom psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window
```

### Kubernetes Mode

```bash
docker exec -d -e DISPLAY=:99 -e PSDOOM_MODE=k8s -e K8S_CONTEXT=my-cluster -e K8S_NAMESPACE=default containerdoom psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window
```

Then open http://localhost:6080 to play.

## Configuration Modes

### Interactive Mode (Default)

```bash
docker compose up -d
# Then use the mode selector in VNC terminal
```

### Docker Mode (Direct)

```bash
PSDOOM_MODE=docker docker compose up -d
```

### Kubernetes Mode (Direct)

```bash
PSDOOM_MODE=k8s K8S_CONTEXT=my-cluster K8S_NAMESPACE=default docker compose up -d
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PSDOOM_MODE` | `select`, `docker`, or `k8s` | `select` |
| `K8S_CONTEXT` | Kubernetes context name | (current context) |
| `K8S_NAMESPACE` | Kubernetes namespace | `default` |

## Create Test Targets

### Docker containers

```bash
for i in {1..15}; do docker run -d --name victim$i alpine sleep 3600; done 
for i in {1..15}; do docker rm -f victim$i 2>/dev/null; done # delete after
```

### Kubernetes pods

```bash
kubectl run victim1 --image=nginx
kubectl run victim2 --image=redis
kubectl run victim3 --image=alpine -- sleep 3600
```

## Project Structure

```
containerdoom/
├── Dockerfile              # Multi-stage build with Docker CLI + kubectl
├── docker-compose.yml      # Service definition
├── start.sh                # Container entrypoint
├── scripts/
│   ├── select-mode.sh      # Interactive mode selector
│   ├── ps-wrapper.sh       # Unified process listing
│   ├── kill-wrapper.sh     # Unified kill handler
│   ├── ps/
│   │   ├── docker-ps.sh    # Docker container listing
│   │   └── k8s-ps.sh       # Kubernetes pod listing
│   └── kill/
│       ├── docker-kill.sh  # Docker container stop
│       └── k8s-kill.sh     # Kubernetes pod delete
└── README.md
```

## Ports

| Port | Description |
|------|-------------|
| 5900 | VNC server |
| 6080 | noVNC web interface |

## Game Controls

| Key | Action |
|-----|--------|
| Arrow keys | Move |
| Ctrl | Shoot |
| Space | Open doors |
| Shift | Run |
| 1-7 | Select weapon |
| Esc | Menu |

## Warning

⚠️ **This can actually stop your containers/pods!** Use with caution. Consider using dedicated test targets.

## Stopping

```bash
docker compose down
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No enemies | Start some containers/pods as targets |
| K8s connection failed | Check kubeconfig mount and permissions |
| Can't connect to VNC | Verify container is running: `docker compose ps` |
| Permission denied | Ensure Docker socket is accessible |

## Credits

### Original psDooM
- **Dennis Chao** - Original concept (University of New Mexico)
- **David Koppenhofer** - Primary developer

### psdoom-ng
- **Orson Teodoro** - Chocolate Doom adaptation
- **ChrisTitusTech** - Current maintainer

### Other
- **Simon Howard** - Chocolate Doom engine
- **id Software** - Original DOOM

## References

- [Original psDooM](https://psdoom.sourceforge.net/)
- [psdoom-ng](https://github.com/ChrisTitusTech/psdoom-ng)
- [Chocolate Doom](https://www.chocolate-doom.org/)

## License

GPL-2.0 (inherited from psDooM and Chocolate Doom)
