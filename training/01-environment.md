# Module 01 — Environment

Get the DSE 5.1 training cluster running on your machine using **Docker or Colima** with Compose.

## Goals

- Install/verify Docker or Colima and Compose
- Bring up the DSE cluster (seed + 2 nodes)
- Confirm the cluster is healthy and accessible

## Prerequisites Check

**Docker:**

```bash
docker --version
docker-compose --version
# Or: docker compose version
```

**Colima:**

```bash
colima --version
# On Apple Silicon (arm64): use x86_64 VM so DSE image (linux/amd64) runs natively (no platform warning)
colima start --arch aarch64 --vm-type=vz --vz-rosetta --cpu 8 --memory 16 # Apple Silicon (if Colima already runs arm64: colima stop, then this)
# colima start --cpu 8 --memory 16 # Run this on an Intel Mac
docker-compose --version
# Or: docker compose version
```

Set `CONTAINER_RUNTIME=docker` or `CONTAINER_RUNTIME=colima` in `.env` so the scripts use the correct commands.

## Step 1: Clone or Open the Repo

Ensure you have the training repo and are in its root:

```bash
cd /path/to/DSE-ops-training
```

## Step 2: Configure Environment (Optional)

Copy the example env and adjust if needed (runtime, image tags, heap size):

```bash
cp .env.example .env
# Use Colima: set CONTAINER_RUNTIME=colima in .env (run: colima start)
# Edit .env if you need different DSE image or heap
```

Defaults use:

- `datastax/dse-server:5.1.49-ubi7` (or the tag in your `.env`)
- Cluster name `DSE`, DC `DC1`
- JVM heap of 1500M maximum (suitable for laptops)

## Step 3: Pull Images (First Time)

Pull images (or run `./scripts/up-cluster.sh`, which will pull as needed):

```bash
docker-compose pull
# Or: docker compose pull
```

This may take a few minutes. If a specific tag (e.g. `5.1.25`) is not found on Docker Hub, check [datastax/dse-server tags](https://hub.docker.com/r/datastax/dse-server/tags) and set `DSE_IMAGE` in `.env` to an available 5.1.x tag.

## Step 4: Start the Cluster

Use the provided script so the seed starts first and becomes healthy before other nodes start:

```bash
./scripts/up-cluster.sh
```

What it does:

1. Starts the **seed node** (`dse-seed`).
2. Waits until the seed reports **UN** in `nodetool status`.
3. Starts **2 more nodes** (3-node cluster).

Give the cluster about **2 minutes** after the script finishes for all nodes to join and become **UN**.

## Step 5: Verify the Cluster

**Nodetool (from seed):**

```bash
./scripts/nodetool.sh status
```

Expected: all three nodes in state **UN** (Up, Normal).

**CQL shell:**

```bash
./scripts/cqlsh.sh
```

In cqlsh:

```cql
DESCRIBE CLUSTER;
DESCRIBE KEYSPACES;
exit
```

## Step 6: Optional — Create a Training Keyspace

So later modules have something to backup and repair:

```bash
./scripts/cqlsh.sh -f training/labs/sample-keyspace.cql
```

Or run the same statements inline with `./scripts/cqlsh.sh -e "..."` (see the CQL file for the full script).

## Important paths and files in the container

Inside each DSE container (e.g. after `./scripts/shell.sh` or `./scripts/shell.sh dse-node-1`), these paths matter for operations and troubleshooting. All paths are the same on every node unless noted.

| Purpose | Path | Notes |
|--------|------|--------|
| **Config** | `/opt/dse/resources/cassandra/conf/cassandra.yaml` | Main Cassandra config (replication, seeds, etc.). |
| | `/opt/dse/resources/dse/conf/dse.yaml` | DSE-specific config (graph, search, analytics, security, etc.). |
| | `/opt/dse/resources/cassandra/conf/jvm.options` | JVM options (heap, GC); may be overridden by `JVM_EXTRA_OPTS` in Docker. |
| **Logs** | `/var/log/cassandra/system.log` | Primary log for startup, errors, and repair. |
| | `/var/log/cassandra/debug.log` | Verbose debug output. |
| **Data** | `/var/lib/cassandra/data/` | SSTable data per keyspace/table; snapshots live under `data/<keyspace>/<table>/snapshots/<name>/`. |
| | `/var/lib/cassandra/commitlog/` | Commit log (replayed on restart). |
| | `/var/lib/cassandra/saved_caches/` | Saved row/key caches. |
| | `/var/lib/cassandra/hints/` | Hinted handoff hints (for down replicas). |

Use these when viewing logs ([04 – Monitoring](04-monitoring-nodetool.md), [07 – Troubleshooting](07-troubleshooting.md)), taking snapshots or restoring ([05 – Backup & Restore](05-backup-restore.md)), or tuning config.

## Stopping the Environment

Stop the cluster:

```bash
docker-compose down
# Or: docker compose down
```

## Troubleshooting

- **Seed never becomes UN**: Check logs with `docker-compose logs dse-seed` (Or: `docker compose logs dse-seed`). Ensure enough memory (e.g. 4 GB).
- **Port 9042 in use**: Change port mappings in `docker-compose.yml` or stop the process using the port.
- **Nodes not joining**: Ensure `SEEDS` points to the seed service name (`dse-seed`) and wait 2–3 minutes; run `nodetool status` again.

## Next

Go to [02 – Architecture](02-architecture.md) to learn how DSE 5.1 organizes nodes, datacenters, and replication.
