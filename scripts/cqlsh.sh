#!/usr/bin/env bash
# Run cqlsh on the seed node. Usage: ./scripts/cqlsh.sh [cqlsh args]
cd "$(dirname "$0")/.."
# shellcheck source=scripts/common.sh
. "$(dirname "$0")/common.sh"
$COMPOSE_CMD exec dse-seed cqlsh "$@"
