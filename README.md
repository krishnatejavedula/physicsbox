# PhysicsBox

![CI](https://github.com/krishnatejavedula/physicsbox/actions/workflows/ci.yml/badge.svg)
![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)

A containerised development environment for C and Python scientific computing. Built on Debian Trixie, designed to work identically on macOS, Linux, and Windows via VS Code Dev Containers.

Inspired by [FermiBottle](https://github.com/fermi-lat/FermiBottle), the Docker-based environment used by the Fermi LAT collaboration.

---

## Requirements

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [VS Code](https://code.visualstudio.com/) with the **Dev Containers** extension

---

## Quick start

```bash
git clone https://github.com/krishnatejavedula/physicsbox.git ~/Apps/physicsbox
cd ~/Apps/physicsbox
chmod +x setup.sh entrypoint.sh
make install
```

Open in VS Code:

```bash
code ~/Apps/physicsbox
```

Click **Reopen in Container** when prompted.

---

## Documentation

| | |
|---|---|
| [Getting Started](docs/getting-started.md) | Requirements, installation, and Windows-specific setup |
| [Daily Use](docs/daily-use.md) | Starting and stopping the container, opening a terminal, and launching JupyterLab |
| [Environment](docs/environment.md) | Lean and full build variants, adding packages, and managing conda environments |
| [Gnuplot](docs/gnuplot.md) | File-based plotting, script template, output formats, and X11 forwarding |
| [Personalisation](docs/personalisation.md) | Dotfiles, shell config, and mounting additional project folders |
| [Reference](docs/reference.md) | Full `make` command list, `setup.sh` flags, and image cleanup |
| [Troubleshooting](docs/troubleshooting.md) | Common issues, deleted files, and uninstalling |