# Module 01 — Environment

Get the DSE 5.1 training cluster running on your machine using **Docker or Podman** with Compose.

## Goals

- Install/verify Docker or Podman and Compose
- Bring up the DSE cluster (seed + 2 nodes)
- Confirm the cluster is healthy and accessible

## Prerequisites Check

**Docker:**

```bash
docker --version
docker compose version   # or: docker-compose --version
```

**Podman:**

```bash
podman --version
podman compose version   # or: podman-compose --version
```

Set `CONTAINER_RUNTIME=docker` or `CONTAINER_RUNTIME=podman` in `.env` so the scripts use the correct commands.

## Step 1: Clone or Open the Repo

Ensure you have the training repo and are in its root:

```bash
cd /path/to/DSE-ops-training
```

## Step 2: Configure Environment (Optional)

Copy the example env and adjust if needed (runtime, image tags, heap size):

```bash
cp .env.example .env
# Use Podman: set CONTAINER_RUNTIME=podman in .env
# Edit .env if you need different DSE image or heap
```

Defaults use:

- `datastax/dse-server:5.1.49-ubi7` (or the tag in your `.env`)
- Cluster name `DSE`, DC `DC1`
- JVM heap of 1500M maximum (suitable for laptops)

## Step 3: Pull Images (First Time)

Use the same compose command as your runtime (or run `./scripts/up-cluster.sh`, which will pull as needed):

```bash
docker compose pull   # or: podman compose pull
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
./scripts/cqlsh.sh -f ./training/labs/sample-keyspace.cql
```

Or run the same statements inline with `./scripts/cqlsh.sh -e "..."` (see the CQL file for the full script).

## Stopping the Environment

Use the same compose command as your runtime:

```bash
docker compose down   # or: podman compose down
```

## Troubleshooting

- **Seed never becomes UN**: Check logs with `docker compose logs dse-seed` or `podman compose logs dse-seed`. Ensure enough memory (e.g. 4 GB).
- **Port 9042 in use**: Change port mappings in `docker-compose.yml` or stop the process using the port.
- **Nodes not joining**: Ensure `SEEDS` points to the seed service name (`dse-seed`) and wait 2–3 minutes; run `nodetool status` again.

## Next

Go to [02 – Architecture](02-architecture.md) to learn how DSE 5.1 organizes nodes, datacenters, and replication.
