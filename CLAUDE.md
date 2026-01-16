# ContainerDoom

Kill Docker containers or Kubernetes pods by playing DOOM!

## Project Overview

This project packages psdoom-ng in a Docker container with VNC/noVNC access. It supports two backends:
- **Docker**: Kill local Docker containers
- **Kubernetes**: Delete pods in a K8s cluster

## Project Structure

```
containerdoom/
├── Dockerfile              # Build with Docker CLI + kubectl
├── docker-compose.yml      # Service definition with mounts
├── start.sh                # Container entrypoint (Xvfb, VNC, noVNC)
├── scripts/
│   ├── select-mode.sh      # Interactive mode selector (TUI)
│   ├── ps-wrapper.sh       # Routes to docker/k8s ps script
│   ├── kill-wrapper.sh     # Routes to docker/k8s kill script
│   ├── ps/
│   │   ├── docker-ps.sh    # Lists Docker containers
│   │   └── k8s-ps.sh       # Lists Kubernetes pods
│   └── kill/
│       ├── docker-kill.sh  # Stops Docker containers
│       └── k8s-kill.sh     # Deletes Kubernetes pods
└── README.md
```

## Key Components

### Mode Selection

| Mode | Description |
|------|-------------|
| `select` | Interactive TUI menu (default) |
| `docker` | Docker containers only |
| `k8s` | Kubernetes pods only |

### Environment Variables

| Variable | Purpose | Default |
|----------|---------|---------|
| `PSDOOM_MODE` | Backend selection | `select` |
| `K8S_CONTEXT` | Kubernetes context | (current) |
| `K8S_NAMESPACE` | Kubernetes namespace | `default` |
| `PSDOOMPSCMD` | Process listing script | `/usr/local/bin/scripts/ps-wrapper.sh` |
| `PSDOOMKILLCMD` | Kill script | `/usr/local/bin/scripts/kill-wrapper.sh` |

### Volumes

| Mount | Purpose |
|-------|---------|
| `/var/run/docker.sock` | Docker daemon access |
| `~/.kube:/root/.kube:ro` | Kubernetes config (read-only) |

## Development Commands

### Build
```bash
docker compose build
```

### Run (Interactive)
```bash
docker compose up -d
```

### Run (Docker mode)
```bash
PSDOOM_MODE=docker docker compose up -d
```

### Run (K8s mode)
```bash
PSDOOM_MODE=k8s K8S_CONTEXT=minikube K8S_NAMESPACE=default docker compose up -d
```

### View logs
```bash
docker compose logs -f containerdoom
```

### Stop
```bash
docker compose down
```

## How It Works

1. `ps-wrapper.sh` checks `PSDOOM_MODE` and calls appropriate backend
2. Backend script lists targets and creates mapping in `/tmp/psdoom-targets.map`
3. Mapping format: `<pseudo-pid> <id> <name> <type>`
4. When monster dies, `kill-wrapper.sh` routes to correct kill script
5. Kill script looks up target in mapping and executes stop/delete
6. Actions logged to `/tmp/psdoom-kills.log`

## Testing

### Docker targets
```bash
docker run -d --name test1 nginx
docker run -d --name test2 redis
```

### K8s targets
```bash
kubectl run test1 --image=nginx
kubectl run test2 --image=redis
```

## Ports

| Port | Service |
|------|---------|
| 5900 | VNC server |
| 6080 | noVNC web interface |

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No enemies | Check targets exist: `docker ps` or `kubectl get pods` |
| K8s auth failed | Verify kubeconfig: `kubectl --context=X get pods` |
| Mode not switching | Source config: `source /tmp/psdoom-config.env` |
| VNC black screen | Check Xvfb: `docker exec containerdoom xdpyinfo -display :99` |
