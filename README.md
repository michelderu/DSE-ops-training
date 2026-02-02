# DSE 5.1 Operations Training

A **comprehensive DataStax Enterprise 5.1 training** for operations teams, using a **local Docker or Podman** environment with Compose so you can run everything on your laptop with minimal setup.

## What’s Included

- **Docker or Podman** Compose stack: 3-node DSE 5.1 cluster
- **Training modules** (concepts + hands-on): environment, architecture, lifecycle, monitoring (nodetool), backup/restore, repair, troubleshooting  
- **Helper scripts**: bring up cluster in order, run `cqlsh` and `nodetool` on the seed (runtime chosen via `CONTAINER_RUNTIME`)  

## Prerequisites

- **Docker** or **Podman**:
  - **Docker**: Docker Engine + Docker Compose (plugin `docker compose` or standalone `docker-compose`)
  - **Podman**: Podman + `podman compose` (Podman 4+) or `podman-compose`
- **4 GB+ RAM** for the host (8 GB recommended for 3-node cluster)
- A few GB free disk for images and data

## Quick Start

```bash
# 1. Clone or open this repo
cd DSE-ops-training

# 2. (Optional) Copy and edit .env for runtime, image tags, or heap size
cp .env.example .env
# Use Podman instead of Docker: set CONTAINER_RUNTIME=podman in .env

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

All scripts are intended to be run from the **repository root**.

## Configuration

- **Runtime**: Set `CONTAINER_RUNTIME=docker` or `CONTAINER_RUNTIME=podman` in `.env`. Scripts use this to run `docker compose` / `podman compose` and `docker exec` / `podman exec`.
- **Images**: Set `DSE_IMAGE` in `.env` (see `.env.example`).  
  For DSE 5.1 use a 5.1.x tag from [Docker Hub](https://hub.docker.com/r/datastax/dse-server/tags) (e.g. `datastax/dse-server:5.1.25`).
- **Cluster**: `CLUSTER_NAME`, `DC` in `.env` (defaults: `DSE-Ops-Training`, `DC1`).
- **Heap**: `JVM_EXTRA_OPTS` in `.env` (default: `-Xms1g -Xmx1g` for laptops).

## Stopping and Cleaning Up

Use the same compose command as your runtime (scripts use `CONTAINER_RUNTIME` from `.env`):

```bash
# With Docker
docker compose down

# With Podman
podman compose down
# or: podman-compose down

# Wipe data: remove the data/ directory after stopping
# rm -rf data/
```

## Data persistence

DSE data is stored in the **local directory** `./data/` (bind-mounted into the containers):

- `./data/seed` — seed node
- `./data/node1` — second node
- `./data/node2` — third node

Data survives `docker compose down` / `podman compose down`. To wipe data and start fresh, remove the `data/` directory (after stopping the cluster).

## Production Note

This setup runs **multiple DSE nodes on one host** for training only. In production, run **one DSE node per physical host** to avoid a single point of failure. See [DataStax Docker recommended settings](https://docs.datastax.com/en/docker/managing/recommended-settings.html).

## References

- [DSE 5.1 Documentation](https://docs.datastax.com/en/dse/5.1/)
- [DataStax Docker Guide](https://docs.datastax.com/en/docker/)
