# PhysicsBox

A containerised development environment for C and Python scientific computing. Built on Debian Trixie, designed to work identically on macOS, Linux, and Windows via VS Code Dev Containers.

Inspired by [FermiBottle](https://github.com/fermi-lat/FermiBottle), the Docker-based environment used by the Fermi LAT collaboration.

---

## What's inside

**C** - GCC 14, CMake, pkg-config, and the following libraries: GSL (GNU Scientific Library), FFTW3, HDF5, LAPACK, BLAS, OpenSSL.

**Gnuplot** - installed for scripted plotting to PNG, PDF, SVG, and EPS. Interactive windows require X11 forwarding (see [X11 forwarding](#x11-forwarding-interactive-gnuplot-windows)).

**Python 3.11** - managed by conda in an environment called `physicsbox`, activated automatically on every shell. Includes numpy, scipy, pandas, matplotlib, seaborn, sympy, statsmodels, scikit-learn, astropy, plotly, streamlit, jupyterlab, and more.

To see everything installed:

```bash
conda list -n physicsbox
```


---

## Requirements

### macOS and Linux

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Mac) or Docker Engine + Compose plugin (Linux)
- [VS Code](https://code.visualstudio.com/) with the **Dev Containers** extension (`ms-vscode-remote.remote-containers`)

### Windows

- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) - sets up WSL2 automatically, no manual WSL configuration needed
- [VS Code](https://code.visualstudio.com/) with the **Dev Containers** extension

> **Windows:** Clone this repo from inside a WSL2 terminal, not from Windows Explorer or PowerShell. This keeps files on the Linux filesystem and avoids slow cross-boundary I/O.
>
> ```bash
> git clone https://github.com/krishnatejavedula/physicsbox.git ~/Apps/physicsbox
> cd ~/Apps/physicsbox
> code .
> ```

---

## Project structure

```
physicsbox/
├── .devcontainer/
│   └── devcontainer.json        # VS Code Dev Containers configuration
├── workspace/                   # Your code - bind-mounted into the container
├── shared/                      # Data files and outputs - bind-mounted into the container
├── Dockerfile                   # Multistage image definition
├── entrypoint.sh                # Container startup script
├── docker-compose.yml           # Service, volume, and port configuration
├── environment.lean.yml         # Lean conda environment
├── environment.full.yml         # Full conda environment
├── .bashrc                      # Shell configuration baked into the image
├── setup.sh                     # Management script
└── README.md
```

`workspace/` and `shared/` live on your host machine and survive container rebuilds and image deletions entirely. Keep all work there.

---

## Setup

```bash
git clone https://github.com/krishnatejavedula/physicsbox.git ~/Apps/physicsbox
cd ~/Apps/physicsbox
chmod +x setup.sh entrypoint.sh
./setup.sh --install
```

Then open in VS Code:

```bash
code ~/Apps/physicsbox
```

VS Code will prompt **Reopen in Container** in the bottom-right corner. Click it. If you miss the prompt, press `F1` → **Dev Containers: Reopen in Container**.

---

## Daily use

```bash
docker compose up -d        # start the container
docker compose stop         # stop it
code ~/Apps/physicsbox      # open in VS Code - attaches to the running container
```

Open a terminal inside VS Code with `` Ctrl+` ``. You will land at:

```
(physicsbox) dev@physicsbox:/workspace$
```

To launch JupyterLab:

```bash
notebook
```

Then open [http://localhost:8888](http://localhost:8888) in your browser.

---

## Gnuplot

Gnuplot is installed in the image. Because the container is headless (no display), interactive GUI windows are not available by default - gnuplot outputs to files which open automatically in VS Code.

Add these two lines at the end of every gnuplot script to close the file and open it in VS Code:

```gnuplot
set output
system("code plot.png")
```

### A basic script

```gnuplot
# ===========================
# Color scheme
# ===========================
cb_red    = "#D55E00"
cb_blue   = "#0072B2"
cb_green  = "#009E73"

# ===========================
# Terminal and output
# ===========================
set terminal pngcairo enhanced font "Arial,14" size 1600,1200
set output "plot.png"

# ===========================
# Style
# ===========================
set tics nomirror
set mxtics 10
set mytics 10
set xlabel "x"
set ylabel "y"
set key right top

# ===========================
# Plot
# ===========================
plot sin(x) w l lw 3 lc rgb cb_red   title "sin(x)", \
     cos(x) w l lw 3 lc rgb cb_blue  title "cos(x)"

# ===========================
# Open in VS Code
# ===========================
set output
system("code plot.png")
```

Run it from the terminal:

```bash
gnuplot script.gp
```

The plot opens automatically in a VS Code tab.

### Supported output formats

```gnuplot
set terminal pngcairo       # PNG
set terminal pdfcairo       # PDF - good for papers
set terminal epscairo       # EPS - for LaTeX
set terminal svg            # SVG
```

### Shortcomings in this environment

**No interactive window.** The `qt`, `wxt`, and `x11` terminals require a display and will fail inside the container. Always set a file-based terminal explicitly - forgetting to do so is the most common mistake.

**No live preview.** The workflow is edit → run → view. For rapid iteration matplotlib in a Jupyter notebook is more convenient.

**X11 forwarding is possible** on Mac (via XQuartz) and Linux (via `xhost`) but requires extra setup and is not supported on Windows without VcXsrv. See the X11 forwarding section below if you need interactive windows.

---

## X11 forwarding (interactive gnuplot windows)

Only needed if you want live interactive gnuplot windows. Not required for file output.

### Mac

1. Install [XQuartz](https://www.xquartz.org/)
2. In XQuartz → Preferences → Security → check **Allow connections from network clients**
3. Add to `docker-compose.yml` under `environment` and `volumes`:

```yaml
environment:
  - DISPLAY=host.docker.internal:0
volumes:
  - /tmp/.X11-unix:/tmp/.X11-unix
```

### Linux

Run once on the host before starting the container:

```bash
xhost +local:docker
```

Add to `docker-compose.yml`:

```yaml
environment:
  - DISPLAY=${DISPLAY}
volumes:
  - /tmp/.X11-unix:/tmp/.X11-unix
```

### Windows

1. Install [VcXsrv](https://sourceforge.net/projects/vcxsrv/)
2. Launch XLaunch → on screen 3 check **Disable Access Control** → save as a `.xlaunch` file for future use
3. Add to your WSL2 `~/.bashrc`:

```bash
export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
export LIBGL_ALWAYS_INDIRECT=1
```

4. Add to `docker-compose.yml`:

```yaml
environment:
  - DISPLAY=${DISPLAY:-host.docker.internal:0}
```

Once X11 is set up, use `set terminal qt` or `set terminal x11` in gnuplot for interactive windows.

---

## Managing packages

### Python packages - temporary

Packages installed this way work immediately but are lost if the image is rebuilt.

```bash
pip install lmfit
conda install astroml -c conda-forge
```

### Python packages - permanent

To make a package part of the image permanently, add it to the `mamba create` block in the `Dockerfile` (mamba is used internally in the Dockerfile for speed - conda commands are for day-to-day use inside the container):

```dockerfile
RUN mamba create -n physicsbox python=3.11 \
        ...
        lmfit \          # ← add your package here
        -c conda-forge && \
```

Then rebuild:

```bash
./setup.sh --rebuild
```

### System libraries - temporary

```bash
sudo apt-get install libgoogle-perftools-dev
```

Lost on rebuild. For anything you use regularly, make it permanent.

### System libraries - permanent

Add the package to the `apt-get install` block in the `Dockerfile`:

```dockerfile
RUN apt-get install -y --no-install-recommends \
        ...
        libgoogle-perftools-dev \    # ← add here
```

Then rebuild:

```bash
./setup.sh --rebuild
```

---

## Conda environments

The default environment is `physicsbox` and is activated automatically. You can create additional environments inside the container for projects that need isolated dependencies.

### Create a new environment

```bash
conda create -n myenv python=3.11 numpy scipy -c conda-forge
conda activate myenv
```

### List all environments

```bash
conda env list
```

### Switch environments

```bash
conda activate myenv
conda activate physicsbox    # switch back to default
```

### Install packages into a specific environment

```bash
conda install -n myenv lmfit -c conda-forge
# or activate it first, then install
conda activate myenv
pip install lmfit
```

### Remove an environment

```bash
conda deactivate
conda env remove -n myenv
```

### Make a new environment persistent

Additional environments created at runtime are lost on rebuild since they live inside the container's filesystem. To make one permanent, add a second `mamba create` block in the `Dockerfile` after the existing one:

```dockerfile
RUN mamba create -n myenv python=3.11 \
        lmfit \
        corner \
        -c conda-forge && \
    mamba clean -a -y
```

Then rebuild:

```bash
./setup.sh --rebuild
```

---

## Personalisation

Store dotfiles in `workspace/` and symlink them so they survive rebuilds:

```bash
mkdir -p /workspace/dotfiles
vim /workspace/dotfiles/.bashrc.local
vim /workspace/dotfiles/.vimrc

ln -s /workspace/dotfiles/.bashrc.local ~/.bashrc.local
ln -s /workspace/dotfiles/.vimrc ~/.vimrc
```

Add to the bottom of `~/.bashrc` to pick up your local overrides:

```bash
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
```

---

## setup.sh reference

```
./setup.sh --install [lean|full]           First-time setup (default: lean)
./setup.sh --uninstall                     Remove container and image (files untouched)
./setup.sh --rebuild [lean|full] [--clean] Rebuild image (default: lean, cached)
./setup.sh --doctor                        Check everything is working correctly
```

### Build variants

| Variant | Contents | Approx size |
|---|---|---|
| `lean` (default) | numpy, scipy, matplotlib, jupyterlab, ipykernel, ipython | ~1.5 GB |
| `full` | Everything in lean + pandas, sympy, seaborn, statsmodels, uncertainties, astropy, h5py, plotly, scikit-learn, numba, dask, pyarrow, streamlit, s3fs, brotli, wordcloud | ~4.5 GB |

```bash
# First time
./setup.sh --install              # lean - recommended for students
./setup.sh --install full         # full - for your own machine

# After changing Dockerfile, .bashrc, .vimrc, or environment files
./setup.sh --rebuild              # lean, cached (fast)
./setup.sh --rebuild full         # full, cached
./setup.sh --rebuild --clean      # lean, no cache (thorough)
./setup.sh --rebuild full --clean # full, no cache

# Maintenance
./setup.sh --doctor               # check everything is healthy
./setup.sh --uninstall            # free up disk space (files untouched)
```

### --rebuild and image cleanup

Every time you rebuild, Docker keeps the old image layers on disk as dangling images - unnamed, untagged leftovers that are no longer referenced by anything. Over multiple rebuilds these accumulate and waste significant disk space.

`--rebuild` automatically removes them after each build using `docker image prune`. This is safe - it only targets dangling layers and will never touch your named `physicsbox:latest` image, any other images on your machine, your containers, or your volumes and files.

You can check what's on disk at any time:

```bash
docker images              # all images including dangling
docker system df           # total disk usage by images, containers, volumes
```

To manually clean up dangling images without rebuilding:

```bash
docker image prune
```

---

## Linux note

On Linux, export your host UID before starting the container to avoid permission issues in bind mounts:

```bash
export HOST_USER_ID=$(id -u)
docker compose up -d
```

Add it to your `~/.bashrc` so it is always set. On macOS and Windows this is handled automatically.

---

## Troubleshooting

**Files created inside VS Code don't appear on the host.**
This happens if `workspace/` didn't exist before the first `docker compose up`. Fix:
```bash
docker compose down && docker compose up -d
```
Using `./setup.sh --install` prevents this entirely.

**Container fails to start - entrypoint error.**
```bash
chmod +x entrypoint.sh
```

**conda environment not activating.**
```bash
source /opt/conda/etc/profile.d/conda.sh
conda activate physicsbox
```

**Build fails with exit code 100.**
A Debian mirror timed out. Try again. If it keeps failing check your internet connection and Docker's DNS settings.

**Deleted files are gone permanently.**
There is no recycle bin on a Linux filesystem by default. Deleting from the VS Code explorer or with `rm` removes files immediately with no recovery. This applies equally to WSL.

PhysicsBox includes two layers of protection:

**1. Remote Trash extension** (`Zwyx.remotetrash`) - adds a **Delete** option to the VS Code file explorer context menu that sends files to trash instead of deleting them permanently. Install it from the VS Code extensions panel. Right-click a file → **Delete** to use it. Note that VS Code's built-in delete key still bypasses this - always right-click.

**2. trash-cli** - command line trash tool for terminal use. Use it instead of `rm`:

```bash
trash myfile.c          # send to trash
trash-list              # see what's in trash
trash-restore           # restore a file interactively
trash-empty             # empty the trash
```

The trash lives at `workspace/.local/share/Trash/` so it persists across container rebuilds.

**3. Git** - the ultimate safety net. Keep your code in a git repo and nothing is ever truly gone:

```bash
git checkout -- deleted_file.c    # restore a deleted file
```

---

## Uninstalling

```bash
./setup.sh --uninstall
```

Removes the image and container. `workspace/` and `shared/` are untouched. Run `./setup.sh --install` to restore.