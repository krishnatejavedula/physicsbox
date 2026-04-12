# Reference

## make commands

Run `make help` from the `physicsbox/` folder to see all commands.

| Command | Description |
|---|---|
| `make start` | Start the container |
| `make stop` | Stop the container |
| `make restart` | Restart the container |
| `make shell` | Open a shell inside the container |
| `make status` | Show container status and image size |
| `make notebook` | Launch JupyterLab |
| `make install` | First-time setup — lean build |
| `make install-full` | First-time setup — full build |
| `make rebuild` | Rebuild lean image using cache |
| `make rebuild-full` | Rebuild full image using cache |
| `make rebuild-clean` | Full clean rebuild from scratch |
| `make uninstall` | Remove container and image |
| `make doctor` | Check everything is working |
| `make test` | Run all tests |
| `make clean` | Remove dangling Docker images |

---

## setup.sh flags

The `setup.sh` script is the underlying management tool. `make` commands call it internally.

```
./setup.sh --install [lean|full]           First-time setup (default: lean)
./setup.sh --uninstall                     Remove container and image (files untouched)
./setup.sh --rebuild [lean|full] [--clean] Rebuild image (default: lean, cached)
./setup.sh --doctor                        Check everything is working correctly
```

---

## Image cleanup

Every rebuild keeps old layers on disk as dangling images. `make rebuild` removes them automatically. To clean up manually:

```bash
make clean
```

To check disk usage:

```bash
docker images
docker system df
```

---

## Linux note

On Linux, export your host UID before starting the container to avoid permission issues in bind mounts:

```bash
export HOST_USER_ID=$(id -u)
make start
```

Add it to your `~/.bashrc` so it is always set. On macOS and Windows this is handled automatically.
