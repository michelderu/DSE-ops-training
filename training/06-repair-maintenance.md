# Module 06 — Repair & Maintenance

Run **anti-entropy repair** and routine **maintenance** so the cluster stays consistent and disk usage is under control. All commands target the Docker Compose cluster.

## Goals

- Understand why repair is needed (replica drift, hints, failures)
- Run **nodetool repair** with common options (full vs incremental, primary-only, DC-local)
- Run **nodetool cleanup** after topology changes
- Relate repair to backup (run cleanup before backup when appropriate)

## Why Repair?

- Replicas can diverge due to writes during node outages, hints, or compaction differences.
- **Anti-entropy repair** (nodetool repair) compares Merkle trees between replicas and streams missing or differing data so replicas converge.
- Best practice: run repair regularly (e.g. within the **gc_grace_seconds** window for each table, typically every 10 days or as per policy).

## Repair in DSE 5.1

- **DSE 5.1.3+**: Default repair type is **full**. Use `-inc` for incremental repair.
- **DSE 5.1.0–5.1.2**: Default is **incremental**. Use `-full` for full repair.
- **Primary (partitioner) range**: `-pr` repairs only the primary replica per partition (recommended for routine runs; less I/O and network).
- **Datacenter**: `-local` or `-dc <name>` to limit repair to one DC.
- **Sequential**: `-seq` repairs one node after another; default in 5.0+ is parallel (all replicas in parallel).

## Running Repair

### Primary-only repair (recommended for regular runs)

Repair only primary ranges for the **local** node (seed):

```bash
./scripts/nodetool.sh repair -pr
```

Repair primary ranges on **all** nodes (run on one node; it coordinates):

```bash
./scripts/nodetool.sh repair -pr -full
```

### Full repair, local DC

```bash
./scripts/nodetool.sh repair -local -full
```

### Incremental repair (DSE 5.1.3+)

```bash
./scripts/nodetool.sh repair -pr -inc
```

### Repair a specific keyspace/table

```bash
./scripts/nodetool.sh repair training -pr
./scripts/nodetool.sh repair training sample -pr
```

## Monitoring Repair

- **nodetool compactionstats**: Repair runs as a form of compaction; you may see active compactions.
- **nodetool netstats**: Shows streaming (data transfer between nodes during repair).
- **Logs**: `docker compose logs -f dse-seed` (or the node you run repair on; use your compose command).

Repair can take a long time on large clusters; run during low-traffic windows when possible.

## Cleanup

- **When**: After adding or removing nodes, so each node only keeps data for token ranges it owns.
- **What**: Removes SSTable data that no longer belongs to this node (e.g. after a node left or tokens changed).
- Run on **each** node; it’s local to that node.

```bash
./scripts/nodetool.sh cleanup
./scripts/nodetool-node.sh dse-node-1 cleanup
./scripts/nodetool-node.sh dse-node-2 cleanup
```

Run cleanup **before** taking a snapshot when you’ve done topology changes (see [05 – Backup & Restore](05-backup-restore.md)).

## Compaction

- **Compaction** merges SSTables and reclaims space; it’s automatic. You can tune throughput and see status.
- Check: `nodetool compactionstats`
- Set throughput (MB/s): `nodetool setcompactionthroughput 32`
- Force user compaction (use with care): `nodetool compact training sample`

## Hands-On Checklist

1. Run primary-only repair on the seed:  
   `./scripts/nodetool.sh repair -pr`
2. Watch `nodetool netstats` (and optionally `compactionstats`) while repair runs.
3. Run cleanup on all three nodes.
4. Take a snapshot (see Module 05) and list snapshots.

## Next

Go to [07 – Troubleshooting](07-troubleshooting.md) for logs, common failures, and recovery steps.
