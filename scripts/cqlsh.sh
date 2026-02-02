#!/usr/bin/env bash
# Run cqlsh on the seed node. Usage: ./scripts/cqlsh.sh [cqlsh args]
# For -f <file>, use a path relative to repo root; it is mounted at /workspace in the container.
cd "$(dirname "$0")/.."
REPO_ROOT="$(pwd)"
# shellcheck source=scripts/common.sh
. "$(dirname "$0")/common.sh"

# Rewrite -f <path> to -f /workspace/<path> when path exists on host so container can read it
CQLSH_ARGS=()
while [ $# -gt 0 ]; do
  if [ "$1" = "-f" ] && [ -n "${2:-}" ]; then
    if [ -f "$REPO_ROOT/$2" ]; then
      CQLSH_ARGS+=(-f "/workspace/$2")
    else
      CQLSH_ARGS+=("$1" "$2")
    fi
    shift 2
  else
    CQLSH_ARGS+=("$1")
    shift
  fi
done

$COMPOSE_CMD exec dse-seed cqlsh "${CQLSH_ARGS[@]}"
