# Module 05 — Backup & Restore

Use DSE 5.1 **snapshots** and **incremental backup** to protect data, and restore when needed. All steps use the Docker Compose cluster.

## Goals

- Create and list **snapshots** (full backup)
- Enable and use **incremental backup**
- Restore from snapshot (conceptually and with basic steps)
- Run **cleanup** before backup when appropriate

## Concepts

- **Snapshot**: On-disk copy of SSTable files for a keyspace/table at a point in time. Stored under `data/<keyspace>/<table>/snapshots/<snapshot_name>`.
- **Incremental backup**: DSE can keep flushed SSTables (and optionally commit logs) so they can be copied elsewhere; incremental backup does not copy files itself—it marks which files need to be backed up. Your own process or scripts copy those files.
- **Restore**: Replace data directories with snapshot/incremental files and restart (or use **sstableloader** to load into a new cluster). For a single-node or full-cluster restore, the basic idea is: stop DSE, restore files, restart.

## Prerequisites in the Lab

- Cluster up (e.g. `./scripts/up-cluster.sh`).
- Keyspace with data (e.g. `training` from [01 – Environment](01-environment.md)).

## Snapshot (Full Backup)

### Create a snapshot

Creates a snapshot named `before_repair_lab` for the whole `training` keyspace:

```bash
./scripts/nodetool.sh snapshot training -t before_repair_lab
```

List snapshots for that keyspace:

```bash
./scripts/nodetool.sh listsnapshots
```

Snapshot files live inside the container under `/var/lib/cassandra/data/.../snapshots/before_repair_lab/`. To list snapshot paths inside the seed container (from repo root, using your compose command):

```bash
docker compose exec dse-seed find /var/lib/cassandra -type d -name "snapshots" 2>/dev/null
# Or with Colima: same (docker compose exec ...). Use docker cp to copy out, or a volume backup strategy.
```

### Snapshot all keyspaces

```bash
./scripts/nodetool.sh snapshot -t full_backup_$(date +%Y%m%d)
```

### Clear old snapshots

Snapshots are not deleted automatically. Remove a specific tag or all snapshots for a keyspace to free disk:

```bash
./scripts/nodetool.sh clearsnapshot training -t before_repair_lab
# Or clear all snapshots for the keyspace
./scripts/nodetool.sh clearsnapshot training
```

## Incremental Backup

- **Incremental backup** in DSE means: after each flush, SSTables are retained (not deleted) so an external process can copy them. You still need to copy the files (e.g. to S3 or NFS) and manage retention.
- Enable per keyspace or cluster-wide.

### Enable incremental backup (cluster-wide)

In `cassandra.yaml`, `incremental_backup: true`. In Docker you’d typically set this via a custom config or env. For the lab you can enable it by running (if your image supports it) or by documenting it:

- Default in many DSE 5.1 configs is `false`. When enabled, DSE keeps flushed SSTables that would otherwise be removed by compaction until they are backed up or aged out by your process.

Enable via nodetool (if available in your version):

```bash
./scripts/nodetool.sh enablebackup
```

Check status:

```bash
./scripts/nodetool.sh statusbackup
```

Disable:

```bash
./scripts/nodetool.sh disablebackup
```

(Exact commands may vary by DSE 5.1 patch; refer to [DSE 5.1 Backup and Restore](https://docs.datastax.com/en/dse/5.1/managing/in-memory/backup-restore-data.html).)

## Cleanup Before Snapshot (Best Practice)

If you added or removed nodes and want a clean backup: run **cleanup** on each node so that node no longer holds data for token ranges it no longer owns. Then take the snapshot.

```bash
# On seed, then on each other node (from repo root)
./scripts/nodetool.sh cleanup
./scripts/nodetool-node.sh dse-node-1 cleanup
./scripts/nodetool-node.sh dse-node-2 cleanup
```

Then create the snapshot as above.

## Restore (High Level)

1. **Full restore from snapshot** (single node or full cluster):
   - Stop DSE on the node(s).
   - Replace the keyspace/table data directories with the snapshot (and any incremental) files, preserving directory layout.
   - Restart DSE.
2. **Restore into a new cluster**: use **sstableloader** to load snapshot SSTables into a new cluster (same topology/schema). See official docs for sstableloader.
For the lab, creating and listing snapshots and running cleanup is enough; full restore can be read in the docs and practiced in a dedicated exercise.

## Hands-On Checklist

1. Create snapshot: `./scripts/nodetool.sh snapshot training -t lab_backup`
2. List: `./scripts/nodetool.sh listsnapshots`
3. (Optional) Enable incremental backup and run `./scripts/nodetool.sh statusbackup`
4. Clear snapshot: `./scripts/nodetool.sh clearsnapshot training -t lab_backup`
5. Run `./scripts/nodetool.sh cleanup` on the seed and `./scripts/nodetool-node.sh dse-node-1 cleanup` and `./scripts/nodetool-node.sh dse-node-2 cleanup` on the other nodes, then take another snapshot

## Next

Go to [06 – Repair & Maintenance](06-repair-maintenance.md) for anti-entropy repair and cleanup.
