# Copilot Agent Instructions

## Working Directory

You are working in `/srv/homelab-config` (source of truth).

## Core Rules

### 1. Evidence-First Approach

Any change must create an artifact under `/srv/artifacts/hc/`.

This ensures:
- All changes are documented with evidence
- Traceability of modifications
- Audit trail for infrastructure changes
- Reproducibility of configurations

### Artifact Requirements

When making changes:
1. Create a timestamped artifact in `/srv/artifacts/hc/` before or during the change
2. Include relevant context, commands, outputs, or configuration snapshots
3. Name artifacts descriptively with timestamps (e.g., `YYYY-MM-DD-HH-MM-description.txt`)

### Example Workflow

```bash
# Before making a change, create an artifact
mkdir -p /srv/artifacts/hc
echo "Change: Updated ZFS pool configuration" > /srv/artifacts/hc/2026-02-02-zfs-update.txt
echo "Previous config:" >> /srv/artifacts/hc/2026-02-02-zfs-update.txt
zpool status >> /srv/artifacts/hc/2026-02-02-zfs-update.txt

# Make the change
# ... perform operations ...

# Document the result
echo "New config:" >> /srv/artifacts/hc/2026-02-02-zfs-update.txt
zpool status >> /srv/artifacts/hc/2026-02-02-zfs-update.txt
```

## Repository Context

This repository manages homelab configuration for:
- ZFS storage pools (tank0)
- Docker volumes
- Infrastructure datasets
- Backup strategies
- GitOps-managed configurations

## Best Practices

- Always reference `/srv/homelab-config` as the working directory
- Document all infrastructure changes with artifacts
- Maintain evidence trail for auditing and rollback purposes
- Use descriptive names for artifacts that indicate their purpose
