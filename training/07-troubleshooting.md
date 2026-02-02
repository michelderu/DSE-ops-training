# Module 07 — Troubleshooting

Find and fix common issues in a DSE 5.1 cluster using logs, nodetool, and basic recovery steps. All examples assume the Docker Compose environment.

## Goals

- Locate and read DSE logs
- Interpret **nodetool status** and **gossip**
- Handle node down, bootstrap failures, and disk/GC issues at a basic level
- Know where to look in official docs for deeper fixes

## Logs

### Where logs live (inside the container)

- **System log**: `/var/log/cassandra/system.log` (often the first place to look)
- **Debug log**: `/var/log/cassandra/debug.log`
- **GC log**: JVM GC logging (path depends on `JVM_EXTRA_OPTS` / log config)

### View logs

From repo root, use your compose command (e.g. `docker compose` or `podman compose`):

```bash
# Follow system log (run from repo root; replace with your compose command if needed)
docker compose exec dse-seed tail -f /var/log/cassandra/system.log
# Or: podman compose exec dse-seed tail -f /var/log/cassandra/system.log

# Last 200 lines
docker compose logs --tail 200 dse-seed

# All logs from all DSE containers
docker compose logs dse-seed dse-node-1 dse-node-2
```

Look for **ERROR**, **WARN**, **Exception**, **OutOfMemoryError**, and **Disk full**.

## Node Down (DN)

**Symptom**: `nodetool status` shows **DN** for one or more nodes.

**Checks:**

1. **Is the process running?**  
   `docker compose ps` — is the container up?
2. **Can other nodes reach it?**  
   From another node: `nodetool gossipinfo` and check whether the down node appears and what generation/state it has.
3. **Network**: Can the host reach the node’s IP/port (e.g. 7000)? In Compose, ensure the `dse-net` network is healthy and no firewall is blocking internode ports.
4. **Logs**: On the down node (if it’s still running but not joining), check `system.log` for bind errors, OOM, or bootstrap failures.

**Actions:**

- Restart the node: `docker compose restart <service_or_container>`
- If the node is permanently gone (e.g. disk lost), use **nodetool removenode** from another node (see official DSE docs) and then replace the node.

## Bootstrap / Join Failures

**Symptom**: New node stays in **UJ** (Up Joining) or never appears as UN.

**Checks:**

1. **Seeds**: New node must have correct `SEEDS` (e.g. `dse-seed`). In Compose, `SEEDS=dse-seed` in the `node` service.
2. **Connectivity**: From the joining node container, can it reach the seed on port 7000? (e.g. run your compose exec on the joining container: `docker compose exec <joining_container> bash -c 'nc -zv dse-seed 7000'` or use ping/telnet; get container name from `docker compose ps`.)
3. **Disk**: Bootstrap streams data; ensure the node has enough disk and that `/var/lib/cassandra` is writable.
4. **Logs**: On the joining node, `system.log` often shows “Unable to bootstrap” or streaming errors.

**Actions:**

- Fix seeds and network; restart the joining node.
- If bootstrap was partially done and the node is in a bad state, you may need to clear its data and re-bootstrap (see DSE docs for decommission/clear and re-add).

## OutOfMemoryError (OOM)

**Symptom**: Node crashes or logs show **OutOfMemoryError** / **java.lang.OutOfMemoryError: Java heap space**.

**Checks:**

- **Heap size**: In our Compose we set `JVM_EXTRA_OPTS=-Xms1g -Xmx1g`. For more data or load, increase (e.g. `-Xms2g -Xmx2g`) in `.env` and restart.
- **nodetool info**: Check “Heap” usage; if it’s constantly near 100%, heap is too small or there’s a leak.

**Actions:**

- Increase heap (and ensure the host has enough RAM). Restart the node.
- Check for large queries or compactions; tune compaction throughput if needed.

## Disk Full

**Symptom**: Writes fail or logs show “No space left on device”.

**Checks:**

- **Host**: `df -h` on the host (and inside the container if needed). Our data is in the local `./data/` directory (seed, node1, node2).
- **Snapshots**: Old snapshots consume space. List with `nodetool listsnapshots` and clear with `nodetool clearsnapshot` (see [05 – Backup & Restore](05-backup-restore.md)).

**Actions:**

- Free disk: remove old snapshots, compact/cleanup, or expand the volume.
- Prevent: schedule snapshot retention and monitor disk usage (e.g. nodetool tablestats, host monitoring).

## Repair / Streaming Hanging

**Symptom**: Repair or bootstrap seems to stall (no progress for a long time).

**Checks:**

- **nodetool netstats**: Is data streaming? Large partitions or slow disk can make streaming slow.
- **nodetool compactionstats**: Repair uses compaction; check for many pending compactions.
- **Logs**: Look for timeout or connection errors between nodes.

**Actions:**

- Allow more time on large clusters; run during low load.
- If a replica is down, repair may block until it’s back (or you use options that skip it—see DSE docs). Bring the node up or remove it from the ring first.

## Quick Reference

| Issue        | Where to look                    | Typical action                    |
|-------------|-----------------------------------|-----------------------------------|
| Node DN     | `docker compose ps`, gossip, logs | Restart container; fix network   |
| Join fails  | SEEDS, connectivity, disk, logs   | Fix config/network; clear & re-add if needed |
| OOM         | Heap in nodetool info, logs       | Increase heap; restart            |
| Disk full   | `df`, snapshots                   | Clear snapshots; add disk         |
| Repair slow | netstats, compactionstats, load   | Run in off-peak; tune compaction  |

## Official References

- [DSE 5.1 Operations](https://docs.datastax.com/en/dse/5.1/managing/operations/)
- [Troubleshooting](https://docs.datastax.com/en/dse/5.1/managing/troubleshooting/)
- [nodetool](https://docs.datastax.com/en/dse/5.1/managing/tools/nodetool/)

## End of Training

You’ve completed the DSE 5.1 Operations Training. Use the [README](../README.md) and the scripts in `scripts/` to keep practicing in the Docker or Podman environment. For production, follow DataStax recommendations: one node per host, proper sizing, backup/repair schedules, and monitoring (e.g. nodetool, JMX, logs).
