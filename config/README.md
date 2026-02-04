# Custom DSE Configuration

This directory allows you to provide custom configuration files that will be used by DSE containers instead of the default configurations.

## How It Works

The DSE Docker image includes a startup script that automatically swaps configuration files from `/config` (mapped from `./config` on the host) with the default configuration files in the container.

## Directory Structure

```
config/
├── cassandra/
│   └── conf/
│       ├── cassandra.yaml    # Override Cassandra configuration
│       └── jvm.options       # Override JVM options
└── dse/
    └── conf/
        └── dse.yaml          # Override DSE configuration
```

## Usage

1. **Copy default configs** (optional): To start with defaults, you can copy them from a running container:
   ```bash
   docker cp dse-seed:/opt/dse/resources/cassandra/conf/cassandra.yaml config/cassandra/conf/
   docker cp dse-seed:/opt/dse/resources/dse/conf/dse.yaml config/dse/conf/
   ```

2. **Edit the config files** in this directory as needed.

3. **Restart containers** to apply changes:
   ```bash
   docker-compose restart dse-seed dse-node-1 dse-node-2
   ```

## Example: Enable Incremental Backup

Create `config/cassandra/conf/cassandra.yaml`:

```yaml
incremental_backup: true
```

Then restart the containers.

## Notes

- Only include the settings you want to override. The startup script handles merging/replacement.
- This directory is gitignored, so your custom configurations won't be committed.
- Changes require a container restart to take effect.
