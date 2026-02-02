#!/usr/bin/env bash
# Bring up DSE cluster in correct order: seed first, then scale node to 2 (3 nodes total).
# Usage: from repo root, ./scripts/up-cluster.sh

set -e
cd "$(dirname "$0")/.."
# shellcheck source=scripts/common.sh
. "$(dirname "$0")/common.sh"

echo "==> Starting seed node ($CONTAINER_RUNTIME)..."
$COMPOSE_CMD up -d dse-seed

echo "==> Waiting for seed to be UN and accept connections..."
until $COMPOSE_CMD exec -T dse-seed nodetool status 2>/dev/null | grep -q "UN"; do
  echo "    waiting..."
  sleep 10
done
echo "    Seed is up."

echo "==> Starting dse-node-1..."
$COMPOSE_CMD up -d dse-node-1

echo "==> Waiting for dse-node-1 to be UN..."
until $COMPOSE_CMD exec -T dse-node-1 nodetool status 2>/dev/null | grep -q "UN"; do
  echo "    waiting..."
  sleep 10
done
echo "    dse-node-1 is up."

echo "==> Starting dse-node-2..."
$COMPOSE_CMD up -d dse-node-2

echo ""
echo "==> Cluster is coming up. Wait ~1–2 minutes for dse-node-2 to join, then:"
echo "    nodetool status:  ./scripts/nodetool.sh status"
echo "    cqlsh:            ./scripts/cqlsh.sh"
echo ""
