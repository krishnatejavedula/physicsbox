# Troubleshooting

**Files created inside VS Code don't appear on the host.**
`workspace/` didn't exist before the first `docker compose up`. Fix:
```bash
docker compose down && make start
```
Using `make install` prevents this entirely.

---

**Container fails to start — entrypoint error.**
```bash
chmod +x entrypoint.sh
```

---

**conda environment not activating.**
```bash
source /opt/conda/etc/profile.d/conda.sh
conda activate physicsbox
```

---

**Build fails with exit code 100.**
A Debian mirror timed out. Try again. If it keeps failing check your internet connection and Docker's DNS settings.

---

**Deleted files are gone permanently.**
There is no recycle bin on a Linux filesystem. This applies equally to WSL.

PhysicsBox includes two layers of protection:

**Remote Trash extension** (`Zwyx.remotetrash`) — right-click a file in the VS Code explorer → **Delete** to send it to trash instead of deleting permanently. The built-in delete key still bypasses this — always right-click.

**trash-cli** — use instead of `rm` in the terminal:

```bash
trash myfile.c      # send to trash
trash-list          # see what's in trash
trash-restore       # restore a file
trash-empty         # empty the trash
```

The trash lives at `workspace/.local/share/Trash/` and persists across rebuilds.

**Git** — the ultimate safety net:

```bash
git checkout -- deleted_file.c
```

---

**Deleted files are gone permanently.**
There is no recycle bin on a Linux filesystem by default. Deleting from the VS Code explorer or with `rm` removes files immediately with no recovery. This applies equally to WSL. Keep your code in a git repo — nothing is ever truly gone.

---

## Uninstalling

```bash
make uninstall
```

Removes the Docker image and container. `workspace/` and `shared/` are untouched — your files are safe.

To restore:

```bash
make install
```
