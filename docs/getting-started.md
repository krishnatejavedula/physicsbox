# Getting Started

## Requirements

### macOS and Linux

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Mac) or Docker Engine + Compose plugin (Linux)
- [VS Code](https://code.visualstudio.com/) with the **Dev Containers** extension (`ms-vscode-remote.remote-containers`)

### Windows

- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/) — sets up WSL2 automatically, no manual WSL configuration needed
- [VS Code](https://code.visualstudio.com/) with the **Dev Containers** extension

> `make` is available on Mac and Linux by default. Windows users running from a WSL2 terminal also have it available.

---

## Installation

```bash
git clone https://github.com/krishnatejavedula/physicsbox.git ~/Apps/physicsbox
cd ~/Apps/physicsbox
chmod +x setup.sh entrypoint.sh
make install
```

The install script will:
1. Check Docker is installed and running
2. Create `workspace/` and `shared/` on your host
3. Build the Docker image (10–20 minutes on first run)

Then open in VS Code:

```bash
code ~/Apps/physicsbox
```

VS Code will prompt **Reopen in Container** in the bottom-right corner. Click it. If you miss the prompt press `F1` → **Dev Containers: Reopen in Container**.

VS Code installs its server inside the container on first connection — this takes a minute or two. After that reopening is instant.

---

## Windows setup

Clone the repo from inside a WSL2 terminal — not from Windows Explorer or PowerShell. This keeps files on the Linux filesystem and avoids slow cross-boundary I/O.

Open a WSL2 terminal and run:

```bash
git clone https://github.com/krishnatejavedula/physicsbox.git ~/Apps/physicsbox
cd ~/Apps/physicsbox
chmod +x setup.sh entrypoint.sh
make install
```

Then open VS Code from the same terminal:

```bash
code ~/Apps/physicsbox
```

Click **Reopen in Container** when prompted.

> Docker Desktop for Windows sets up WSL2 automatically — no manual WSL configuration needed. Just install Docker Desktop, open a WSL2 terminal, and follow the steps above.
