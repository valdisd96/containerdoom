# psdoom-docker

A Dockerized version of **psdoom-ng** - the classic DOOM game where monsters represent running Docker containers. Kill a monster, stop a container!

## What is psdoom?

psdoom (Process DOOM) is a modification of the classic DOOM game where each monster represents a running process. When you kill a monster, the corresponding process gets terminated. This Docker version takes it further - instead of system processes, monsters represent **Docker containers** running on your host.

## Features

- Play DOOM in your browser via noVNC
- Monsters represent running Docker containers
- Killing a monster stops the corresponding container
- Self-contained Docker environment
- No installation required - just Docker

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

1. Open your browser: **http://localhost:6080**
2. Enter VNC password: `1234`
3. Right-click on desktop → Terminal
4. Run the game:

```bash
psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window
```

Or launch directly from host:

```bash
docker exec -e DISPLAY=:99 psdoom-ng psdoom-ng -iwad /usr/share/games/doom/doom1.wad -window
```

## Create Test Targets

Start some containers to appear as enemies:

```bash
docker run -d --name victim1 nginx
docker run -d --name victim2 redis
docker run -d --name victim3 alpine sleep 3600
```

## Ports

| Port | Description |
|------|-------------|
| 5900 | VNC server (for VNC clients) |
| 6080 | noVNC web interface (browser access) |

## Game Controls

| Key | Action |
|-----|--------|
| Arrow keys | Move |
| Ctrl | Shoot |
| Space | Open doors |
| Shift | Run |
| 1-7 | Select weapon |
| Esc | Menu |

## How It Works

1. The container runs psdoom-ng with custom scripts that interface with Docker
2. `docker-ps.sh` lists running containers and assigns pseudo-PIDs
3. Containers appear as monsters in the game
4. When you kill a monster, `docker-kill.sh` runs `docker stop` on that container
5. The psdoom-ng container excludes itself from the enemy list

## Warning

⚠️ **This can actually stop your Docker containers!** Use with caution and don't run important services while playing. Consider using dedicated test containers.

## Stopping

```bash
docker compose down
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| No enemies in game | Start some containers: `docker run -d --name test nginx` |
| Can't connect to VNC | Check container is running: `docker compose ps` |
| Permission denied | Ensure Docker socket is accessible |
| Game crashes | Try rebuilding: `docker compose build --no-cache` |

## Credits

### Original psDooM
- **Dennis Chao** - Original concept and implementation at University of New Mexico
- **David Koppenhofer** - Primary developer and maintainer of psDooM

### psdoom-ng
- **Orson Teodoro** - Adapted psDooM to Chocolate Doom engine
- **ChrisTitusTech** - Current GitHub fork maintainer

### Other Contributors
- **Simon Howard** - Chocolate Doom engine
- **Hector Rivas Gandara** - External process sources and cloud services support
- **Jesse Spielman** - Mac OS X compatibility

### Foundations
- **id Software** - Original DOOM (source released under GPL in 1997)
- **Udo Munk** - XDoom (base for original psDooM)

## References

- [Original psDooM](https://psdoom.sourceforge.net/)
- [psdoom-ng on GitHub](https://github.com/ChrisTitusTech/psdoom-ng)
- [Doom as an Interface for Process Management (Paper)](https://www.cs.unm.edu/~dlchao/flake/doom/chi/chi.html)
- [Chocolate Doom](https://www.chocolate-doom.org/)

## License

This project uses components licensed under GPL-2.0, inherited from psDooM and Chocolate Doom.
