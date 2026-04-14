# Getting Started

## Requirements

### macOS and Linux

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) (Mac) or Docker Engine + Compose plugin (Linux)
- [VS Code](https://code.visualstudio.com/) with the **Dev Containers** extension (`ms-vscode-remote.remote-containers`)

### Windows

- [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/)
- [VS Code](https://code.visualstudio.com/) with the **Dev Containers** extension
- Git for Windows (includes Git Bash) - installed via the one-liner below

> All commands on Windows are run from **Git Bash**, not PowerShell or Command Prompt. Git Bash gives you a bash terminal that works identically to Mac and Linux.

---

## Installation

### macOS and Linux

```bash
git clone https://github.com/krishnatejavedula/physicsbox.git ~/Apps/physicsbox
cd ~/Apps/physicsbox
chmod +x setup.sh entrypoint.sh
make install
```

Then open in VS Code:

```bash
code ~/Apps/physicsbox
```

VS Code will prompt **Reopen in Container** in the bottom-right corner. Click it. If you miss the prompt press `F1` → **Dev Containers: Reopen in Container**.

---

### Windows

**Step 1 - Install prerequisites**

Open PowerShell and run:

```powershell
winget install -e --id Git.Git
winget install -e --id Docker.DockerDesktop
winget install -e --id Microsoft.VisualStudioCode
```

Restart your machine after installation completes.

**Step 2 - Open Git Bash**

Search for **Git Bash** in the Start menu and open it. All remaining steps are done here - never in PowerShell or Command Prompt.

**Step 3 - Clone and install**

```bash
git clone https://github.com/krishnatejavedula/physicsbox.git ~/Apps/physicsbox
cd ~/Apps/physicsbox
chmod +x setup.sh entrypoint.sh
make install
```

**Step 4 - Open in VS Code**

```bash
code ~/Apps/physicsbox
```

Click **Reopen in Container** when prompted.

> From this point on, all commands (`make start`, `make stop`, `./setup.sh`, etc.) are run from Git Bash. The workflow is identical to Mac and Linux.