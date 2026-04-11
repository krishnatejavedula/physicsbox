#!/bin/bash
# =============================================================================
# entrypoint.sh - Physics Dev Container
# =============================================================================
# Runs as root at container start.
# 1. Remaps the 'dev' user UID to match HOST_USER_ID (avoids volume permission
#    mismatches on both Mac and Linux).
# 2. Sets ownership on shared volumes.
# 3. Copies .bashrc from image on first run.
# 4. Drops to the dev user via gosu or su.
# =============================================================================

set -e

# ---------------------------------------------------------------------------
# 1. UID remapping
#    On Linux the host UID matters for file ownership in bind mounts.
#    On Mac, Docker Desktop handles this transparently, but we still apply it.
# ---------------------------------------------------------------------------
USER_ID=${HOST_USER_ID:-1000}
CURRENT_UID=$(id -u dev)

if [ "${CURRENT_UID}" != "${USER_ID}" ]; then
  echo "[entrypoint] Remapping dev UID: ${CURRENT_UID} → ${USER_ID}"
  usermod -u "${USER_ID}" dev
fi

export HOME=/home/dev
export USER=dev
export LOGNAME=dev
export PATH=/opt/conda/bin:$PATH
export CONDA_PREFIX=/opt/conda

# ---------------------------------------------------------------------------
# 2. Volume ownership
# ---------------------------------------------------------------------------
for dir in /shared /workspace; do
  if [ -d "$dir" ]; then
    chown -R dev:wheel "$dir"
    chmod -R g+rwx "$dir"
  fi
done

chown -R dev:dev /home/dev

# ---------------------------------------------------------------------------
# 3. First-run shell bootstrap
# ---------------------------------------------------------------------------
MARKER="$HOME/.physicsbox-container"

if [ ! -f "$MARKER" ]; then
  touch "$MARKER"

  # .bash_profile - sources .bashrc for login shells
  cat > "$HOME/.bash_profile" <<'EOF'
export PATH=/opt/conda/bin:$PATH
export CONDA_PREFIX=/opt/conda
[[ -f ~/.bashrc ]] && source ~/.bashrc
EOF

  # .bashrc and .vimrc - copied from image
  cp /etc/physicsbox/bashrc "$HOME/.bashrc"
  cp /etc/physicsbox/vimrc  "$HOME/.vimrc"

  chown dev:dev "$HOME/.bash_profile" "$HOME/.bashrc" "$HOME/.vimrc" "$MARKER"
fi

# ---------------------------------------------------------------------------
# 4. Drop to dev user and exec the requested command
#    We use 'su' with login shell so .bash_profile is sourced.
#    If gosu is available it's cleaner (signals pass through properly).
# ---------------------------------------------------------------------------
echo ""
echo "  ╔═══════════════════════════════════════╗"
echo "  ║   Physics Dev Container - ready       ║"
echo "  ║   conda env : physicsbox (Python 3.11) ║"
echo "  ║   workspace : /workspace              ║"
echo "  ║   shared    : /shared                 ║"
echo "  ╚═══════════════════════════════════════╝"
echo ""

if command -v gosu &>/dev/null; then
  exec gosu dev "$@"
else
  exec su -l dev -c "exec $*"
fi
