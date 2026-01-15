# psdoom-ng

A Dockerized version of **psdoom-ng** - the classic DOOM game where monsters represent running processes on your system. Kill a monster, kill a process!

## What is psdoom?

psdoom-ng is a fork of the original psdoom (Process DOOM) - a version of DOOM where each monster represents a running process. When you kill a monster in the game, the corresponding process gets terminated. It's a fun (and dangerous!) way to manage processes.

## Prerequisites

- Docker
- Docker Compose

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

1. Open your browser and go to **http://localhost:6080**
2. Enter VNC password: `1234`
3. The game starts automatically, or run manually:

```bash
docker exec -e DISPLAY=:99 -e USER=root psdoom-ng psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window
```

## Ports

| Port | Description |
|------|-------------|
| 5900 | VNC server (for VNC clients) |
| 6080 | noVNC web interface (browser access) |

## Controls

- **Arrow keys** - Move
- **Ctrl** - Shoot
- **Space** - Open doors
- **Shift** - Run
- **1-7** - Select weapon

## Warning

This is for entertainment purposes only. The game can actually kill processes on the system where it's running. Use with caution!

## Stopping

```bash
docker compose down
```
