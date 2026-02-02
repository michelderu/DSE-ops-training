#!/usr/bin/env bash
# Set COMPOSE_CMD for docker compose / podman compose. Source from other scripts.
# Uses CONTAINER_RUNTIME from environment or .env (docker | podman). Default: docker.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load CONTAINER_RUNTIME from .env if not set
if [ -z "${CONTAINER_RUNTIME:-}" ] && [ -f "$REPO_ROOT/.env" ]; then
  val=$(grep -E '^CONTAINER_RUNTIME=' "$REPO_ROOT/.env" 2>/dev/null | cut -d= -f2- | tr -d '"' | xargs)
  [ -n "$val" ] && CONTAINER_RUNTIME="$val"
fi
CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-docker}"

case "$CONTAINER_RUNTIME" in
  podman)
    if command -v podman >/dev/null 2>&1 && podman compose version >/dev/null 2>&1; then
      COMPOSE_CMD="podman compose"
    elif command -v podman-compose >/dev/null 2>&1; then
      COMPOSE_CMD="podman-compose"
    else
      echo "CONTAINER_RUNTIME=podman but neither 'podman compose' nor 'podman-compose' found." >&2
      exit 1
    fi
    CONTAINER_EXEC="podman exec"
    # Suppress "Executing external compose provider" message (see podman-compose(1))
    export PODMAN_COMPOSE_WARNING_LOGS=false
    ;;
  docker)
    if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
      COMPOSE_CMD="docker compose"
    elif command -v docker-compose >/dev/null 2>&1; then
      COMPOSE_CMD="docker-compose"
    else
      echo "CONTAINER_RUNTIME=docker but neither 'docker compose' nor 'docker-compose' found." >&2
      exit 1
    fi
    CONTAINER_EXEC="docker exec"
    ;;
  *)
    echo "CONTAINER_RUNTIME must be 'docker' or 'podman', got: $CONTAINER_RUNTIME" >&2
    exit 1
    ;;
esac

export COMPOSE_CMD CONTAINER_EXEC CONTAINER_RUNTIME
