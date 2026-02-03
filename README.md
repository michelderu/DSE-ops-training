# DSE 5.1 Operations Training

A **comprehensive DataStax Enterprise 5.1 training** for operations teams, using a **local Docker or Colima** environment with Compose so you can run everything on your laptop with minimal setup.

## What’s Included

- **Docker or Colima** Compose stack: 3-node DSE 5.1 cluster
- **Training modules** (concepts + hands-on): environment, architecture, lifecycle, monitoring (nodetool), backup/restore, repair, troubleshooting  
- **Helper scripts**: bring up cluster in order, run `cqlsh` and `nodetool` on the seed (runtime chosen via `CONTAINER_RUNTIME`)  

## Prerequisites

- **Docker** or **Colima**:
  - **Docker**: Docker Engine + Docker Compose (`docker-compose` or plugin `docker compose`)
  - **Colima**: Colima (provides Docker-compatible daemon; install with `brew install colima`). On **Apple Silicon (arm64)** start Colima with an x86_64 VM so the DSE image (linux/amd64) runs natively: `colima start --arch x86_64`. On Intel Macs: `colima start`.
- **4 GB+ RAM** for the host (8 GB recommended for 3-node cluster)
- A few GB free disk for images and data

## Quick Start

```bash
# 1. Clone or open this repo
cd DSE-ops-training

# 2. (Optional) Copy and edit .env for runtime, image tags, or heap size
cp .env.example .env
# Use Colima: set CONTAINER_RUNTIME=colima in .env. On Apple Silicon: colima start --arch x86_64

# 3. Start the cluster (seed first, then 2 nodes)
./scripts/up-cluster.sh

# 4. Wait ~2 minutes, then check status
./scripts/nodetool.sh status

# 5. Connect to CQL
./scripts/cqlsh.sh
```

**Endpoint**

- **CQL**: `localhost:9042` (seed node)

## Training Curriculum

Start with **[training/00-overview.md](training/00-overview.md)** and follow the modules in order:

| Module | Topic |
|--------|--------|
| [01 – Environment](training/01-environment.md) | Bring up the Docker cluster and verify it |
| [02 – Architecture](training/02-architecture.md) | Cluster, DC, replication, consistency |
| [03 – Lifecycle](training/03-lifecycle.md) | Start, stop, status, scaling |
| [04 – Monitoring & nodetool](training/04-monitoring-nodetool.md) | nodetool, JMX, logs |
| [05 – Backup & Restore](training/05-backup-restore.md) | Snapshots and incremental backup |
| [06 – Repair & Maintenance](training/06-repair-maintenance.md) | Anti-entropy repair and cleanup |
| [07 – Troubleshooting](training/07-troubleshooting.md) | Logs, common failures, recovery |

## Scripts

| Script | Purpose |
|--------|--------|
| `scripts/up-cluster.sh` | Start seed, wait for UN, then start 2 nodes (3-node cluster) |
| `scripts/cqlsh.sh` | Run `cqlsh` on the seed (e.g. `./scripts/cqlsh.sh -e "DESCRIBE KEYSPACES"`) |
| `scripts/nodetool.sh` | Run `nodetool` on the seed (e.g. `./scripts/nodetool.sh status`) |
| `scripts/nodetool-node.sh` | Run `nodetool` on a specific node (e.g. `./scripts/nodetool-node.sh dse-seed status`) |
| `scripts/shell.sh` | Open an interactive shell in a container (e.g. `./scripts/shell.sh` or `./scripts/shell.sh dse-node-1`) |

All scripts are intended to be run from the **repository root**.

## Configuration

- **Runtime**: Set `CONTAINER_RUNTIME=docker` or `CONTAINER_RUNTIME=colima` in `.env`. Scripts use this to run `docker compose` and `docker exec` (Colima provides Docker).
- **Images**: Set `DSE_IMAGE` in `.env` (see `.env.example`).  
  For DSE 5.1 use a 5.1.x tag from [Docker Hub](https://hub.docker.com/r/datastax/dse-server/tags) (e.g. `datastax/dse-server:5.1.25`).
- **Cluster**: `CLUSTER_NAME`, `DC` in `.env` (defaults: `DSE-Ops-Training`, `DC1`).
- **Heap**: limited to 1G for use on laptops.

## Stopping and Cleaning Up

Stop the cluster:

```bash
docker-compose down
# Or: docker compose down
```

Wipe data: remove the `data/` directory after stopping.

## Production Note

This setup runs **multiple DSE nodes on one host** for training only. In production, run **one DSE node per physical host** to avoid a single point of failure. See [DataStax Docker recommended settings](https://docs.datastax.com/en/docker/managing/recommended-settings.html).

## References

- [DSE 5.1 Documentation](https://docs.datastax.com/en/dse/5.1/)
- [DataStax Docker Guide](https://docs.datastax.com/en/docker/)
