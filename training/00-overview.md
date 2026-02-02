# DSE 5.1 Operations Training — Overview

This training is designed for **operations teams** who will run and maintain DataStax Enterprise (DSE) 5.1 clusters. It uses a **local Docker or Colima** environment with Compose so you can complete all modules on your laptop with minimal setup.

## Objectives

By the end of this training you will be able to:

- Bring up and tear down a DSE 5.1 cluster with Docker or Colima Compose
- Explain DSE 5.1 architecture (nodes, datacenters, replication, consistency)
- Perform day-to-day operations: start/stop, status, add/remove nodes
- Monitor the cluster with **nodetool** (and JMX/logs)
- Run **backup** (snapshots, incremental) and **restore**
- Schedule and interpret **repair** (anti-entropy)
- Apply basic **security** and **troubleshooting** practices

## Prerequisites

- **Docker** (Engine + Compose: `docker compose` or `docker-compose`) or **Colima** (provides Docker; run `colima start`, then scripts use `docker compose`). Set `CONTAINER_RUNTIME=docker` or `CONTAINER_RUNTIME=colima` in `.env` so the scripts use the right commands.
- **4 GB+ RAM** for the host (8 GB recommended for 3-node cluster)
- **Disk**: a few GB free for images and data
- Basic familiarity with the command line and YAML

No prior Cassandra or DSE experience is required; concepts are introduced as needed.

## Training Structure

| Module | Topic | Focus |
|--------|--------|--------|
| [01 – Environment](01-environment.md) | Docker or Colima Compose, bring up cluster | Get the lab running |
| [02 – Architecture](02-architecture.md) | Nodes, replication, consistency | How DSE works |
| [03 – Lifecycle](03-lifecycle.md) | Start, stop, scale, status | Day-to-day control |
| [04 – Monitoring & nodetool](04-monitoring-nodetool.md) | nodetool, JMX, logs | Health and performance |
| [05 – Backup & Restore](05-backup-restore.md) | Snapshots, incremental backup | Data protection |
| [06 – Repair & Maintenance](06-repair-maintenance.md) | Anti-entropy repair, cleanup | Consistency and disk |
| [07 – Troubleshooting](07-troubleshooting.md) | Logs, common failures, recovery | When things go wrong |

Each module includes **concepts**, **commands**, and **hands-on steps** you can run in the Docker or Colima environment.

## Lab Environment Summary

- **Cluster**: 1 seed node + 2 additional nodes (3 nodes total)
- **Services**: DSE (CQL 9042 on seed)
- **Access**: use `./scripts/cqlsh.sh` and `./scripts/nodetool.sh` (they use Docker or Colima based on `CONTAINER_RUNTIME` in `.env`)

## How to Use This Training

1. **Start here**: [01 – Environment](01-environment.md) to bring up the cluster.
2. Work through modules in order; later modules assume you have completed earlier ones.
3. Run every command and exercise in your local Compose environment.
4. Use the [Official DSE 5.1 Docs](https://docs.datastax.com/en/dse/5.1/) for deeper reference.

## Quick Reference

- **Start cluster**: `./scripts/up-cluster.sh` (from repo root; uses Docker or Colima per `.env`)
- **Stop all**: `docker compose down` (Docker or Colima)
- **cqlsh**: `./scripts/cqlsh.sh`
- **nodetool**: `./scripts/nodetool.sh status`
