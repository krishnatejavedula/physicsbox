#!/bin/bash
# =============================================================================
# setup.sh - PhysicsBox management script
# =============================================================================
# Usage:
#   ./setup.sh --install    First-time setup: create dirs and build image
#   ./setup.sh --uninstall  Remove Docker image and container (files untouched)
#   ./setup.sh --rebuild    Rebuild the image after Dockerfile changes
#   ./setup.sh --doctor     Check everything is in place and working
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="physicsbox:latest"
CONTAINER_NAME="physicsbox"
REQUIRED_FILES=("Dockerfile" "entrypoint.sh" "docker-compose.yml" ".devcontainer/devcontainer.json")

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------
ok()   { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; }
info() { echo "  → $1"; }

check_docker_running() {
  if ! command -v docker &>/dev/null; then
    fail "Docker not found. Install Docker Desktop first."
    echo "    https://www.docker.com/products/docker-desktop/"
    exit 1
  fi
  if ! docker info &>/dev/null 2>&1; then
    fail "Docker daemon is not running. Start Docker Desktop first."
    exit 1
  fi
}

# -----------------------------------------------------------------------------
# --install
# -----------------------------------------------------------------------------
cmd_install() {
  echo ""
  echo "  ╔═══════════════════════════════════════╗"
  echo "  ║   PhysicsBox - Install                ║"
  echo "  ╚═══════════════════════════════════════╝"
  echo ""

  echo "[ 1/3 ] Checking prerequisites..."
  check_docker_running
  ok "Docker found: $(docker --version)"
  ok "Docker daemon is running"

  echo ""
  echo "[ 2/3 ] Creating host directories..."
  for dir in workspace shared .devcontainer; do
    target="$SCRIPT_DIR/$dir"
    if [ -d "$target" ]; then
      ok "$dir/ already exists"
    else
      mkdir -p "$target"
      ok "$dir/ created"
    fi
  done

  echo ""
  echo "[ 3/3 ] Building PhysicsBox image..."
  info "This takes 10-20 minutes on first run."
  echo ""
  cd "$SCRIPT_DIR"
  docker compose build

  echo ""
  echo "  ╔═══════════════════════════════════════════════════════╗"
  echo "  ║   Install complete!                                   ║"
  echo "  ║                                                       ║"
  echo "  ║   Next steps:                                         ║"
  echo "  ║   1. Open this folder in VS Code                      ║"
  echo "  ║   2. Install the Dev Containers extension             ║"
  echo "  ║   3. Click 'Reopen in Container' when prompted        ║"
  echo "  ╚═══════════════════════════════════════════════════════╝"
  echo ""
}

# -----------------------------------------------------------------------------
# --uninstall
# -----------------------------------------------------------------------------
cmd_uninstall() {
  echo ""
  echo "  ╔═══════════════════════════════════════╗"
  echo "  ║   PhysicsBox - Uninstall              ║"
  echo "  ╚═══════════════════════════════════════╝"
  echo ""
  echo "  This will remove the Docker container and image."
  echo "  Your files in workspace/ and shared/ will NOT be touched."
  echo ""
  read -r -p "  Are you sure? [y/N] " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    info "Aborted."
    exit 0
  fi

  check_docker_running
  cd "$SCRIPT_DIR"

  echo ""
  echo "[ 1/2 ] Stopping and removing container..."
  if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker compose down
    ok "Container removed"
  else
    info "No container found, skipping"
  fi

  echo ""
  echo "[ 2/2 ] Removing image..."
  if docker image inspect "$IMAGE_NAME" &>/dev/null 2>&1; then
    docker rmi "$IMAGE_NAME"
    ok "Image $IMAGE_NAME removed"
  else
    info "No image found, skipping"
  fi

  echo ""
  ok "Uninstall complete. Your workspace/ and shared/ files are untouched."
  info "Run ./setup.sh --install to set up again."
  echo ""
}

# -----------------------------------------------------------------------------
# --rebuild [--clean]
# -----------------------------------------------------------------------------
cmd_rebuild() {
  local clean=false
  [[ "${2:-}" == "--clean" ]] && clean=true

  echo ""
  echo "  ╔═══════════════════════════════════════╗"
  echo "  ║   PhysicsBox - Rebuild                ║"
  echo "  ╚═══════════════════════════════════════╝"
  echo ""

  if $clean; then
    info "Mode: clean build (--no-cache) - all layers rebuilt from scratch"
  else
    info "Mode: cached build - only changed layers rebuilt"
    info "Use './setup.sh --rebuild --clean' to force a full clean rebuild"
  fi
  echo ""

  check_docker_running
  cd "$SCRIPT_DIR"

  echo "[ 1/3 ] Stopping container if running..."
  if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    docker compose stop
    ok "Container stopped"
  else
    info "Container not running, skipping"
  fi

  echo ""
  echo "[ 2/3 ] Rebuilding image..."
  if $clean; then
    docker compose build --no-cache
  else
    docker compose build
  fi

  echo ""
  echo "[ 3/3 ] Cleaning up dangling images..."
  DANGLING=$(docker images -f "dangling=true" -q)
  if [ -n "$DANGLING" ]; then
    docker image prune -f
    ok "Dangling images removed"
  else
    info "No dangling images found, skipping"
  fi

  echo ""
  ok "Rebuild complete. Run 'docker compose up -d' or reopen in VS Code."
  echo ""
}

# -----------------------------------------------------------------------------
# --doctor
# -----------------------------------------------------------------------------
cmd_doctor() {
  echo ""
  echo "  ╔═══════════════════════════════════════╗"
  echo "  ║   PhysicsBox - Doctor                 ║"
  echo "  ╚═══════════════════════════════════════╝"
  echo ""

  ISSUES=0

  # Docker
  echo "[ Docker ]"
  if command -v docker &>/dev/null; then
    ok "Docker installed: $(docker --version)"
  else
    fail "Docker not found"
    ISSUES=$((ISSUES + 1))
  fi

  if docker info &>/dev/null 2>&1; then
    ok "Docker daemon is running"
  else
    fail "Docker daemon is not running"
    ISSUES=$((ISSUES + 1))
  fi

  if docker compose version &>/dev/null 2>&1; then
    ok "Docker Compose available: $(docker compose version)"
  else
    fail "Docker Compose not found"
    ISSUES=$((ISSUES + 1))
  fi

  # Required files
  echo ""
  echo "[ Files ]"
  for f in "${REQUIRED_FILES[@]}"; do
    if [ -f "$SCRIPT_DIR/$f" ]; then
      ok "$f"
    else
      fail "$f missing"
      ISSUES=$((ISSUES + 1))
    fi
  done

  if [ -x "$SCRIPT_DIR/entrypoint.sh" ]; then
    ok "entrypoint.sh is executable"
  else
    fail "entrypoint.sh is not executable  →  run: chmod +x entrypoint.sh"
    ISSUES=$((ISSUES + 1))
  fi

  # Directories
  echo ""
  echo "[ Directories ]"
  for dir in workspace shared; do
    if [ -d "$SCRIPT_DIR/$dir" ]; then
      ok "$dir/ exists"
    else
      fail "$dir/ missing  →  run: ./setup.sh --install"
      ISSUES=$((ISSUES + 1))
    fi
  done

  # Image
  echo ""
  echo "[ Image ]"
  if docker image inspect "$IMAGE_NAME" &>/dev/null 2>&1; then
    SIZE=$(docker image inspect "$IMAGE_NAME" --format='{{.Size}}' | awk '{printf "%.1f GB", $1/1073741824}')
    ok "Image $IMAGE_NAME exists ($SIZE)"
  else
    fail "Image $IMAGE_NAME not found  →  run: ./setup.sh --install"
    ISSUES=$((ISSUES + 1))
  fi

  # Container
  echo ""
  echo "[ Container ]"
  if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    ok "Container is running"
  elif docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    info "Container exists but is stopped  →  run: docker compose up -d"
  else
    info "Container not created yet  →  run: docker compose up -d"
  fi

  # Environment (only if container is running)
  echo ""
  echo "[ Environment ]"
  if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    if docker exec "$CONTAINER_NAME" conda run -n physicsbox python -c "import numpy, scipy, astropy" &>/dev/null 2>&1; then
      ok "Python environment (physicsbox) is healthy"
      PYVER=$(docker exec "$CONTAINER_NAME" conda run -n physicsbox python --version 2>&1)
      ok "$PYVER"
    else
      fail "Python environment (physicsbox) has issues"
      ISSUES=$((ISSUES + 1))
    fi

    if docker exec "$CONTAINER_NAME" gsl-config --version &>/dev/null 2>&1; then
      GSLVER=$(docker exec "$CONTAINER_NAME" gsl-config --version)
      ok "GSL version $GSLVER"
    else
      fail "GSL not found in container"
      ISSUES=$((ISSUES + 1))
    fi

    if docker exec "$CONTAINER_NAME" gcc --version &>/dev/null 2>&1; then
      GCCVER=$(docker exec "$CONTAINER_NAME" gcc --version | head -1)
      ok "$GCCVER"
    else
      fail "GCC not found in container"
      ISSUES=$((ISSUES + 1))
    fi
  else
    info "Container not running - skipping environment checks"
    info "Start with 'docker compose up -d' then re-run --doctor"
  fi

  # Summary
  echo ""
  echo "  ───────────────────────────────────────"
  if [ "$ISSUES" -eq 0 ]; then
    echo "  ✓ All checks passed. PhysicsBox is healthy."
  else
    echo "  ✗ $ISSUES issue(s) found. See above for details."
  fi
  echo ""
}

# -----------------------------------------------------------------------------
# Entry point
# -----------------------------------------------------------------------------
case "${1:-}" in
  --install)   cmd_install   ;;
  --uninstall) cmd_uninstall ;;
  --rebuild)   cmd_rebuild "$@" ;;
  --doctor)    cmd_doctor    ;;
  *)
    echo ""
    echo "  Usage: ./setup.sh [flag]"
    echo ""
    echo "  Flags:"
    echo "    --install          First-time setup: create directories and build image"
    echo "    --uninstall        Remove container and image (workspace/ and shared/ untouched)"
    echo "    --rebuild          Rebuild using cache - only changed layers rebuilt (fast)"
    echo "    --rebuild --clean  Full clean rebuild from scratch (slow but thorough)"
    echo "    --doctor           Check everything is installed and working correctly"
    echo ""
    ;;
esac