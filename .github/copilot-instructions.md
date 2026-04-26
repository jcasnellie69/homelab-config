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

## Agent quick-start (concise)

- Working directory: `/srv/homelab-config` (source of truth).
- Evidence artifact: always create a timestamped file under `/srv/artifacts/hc/` for any change (see "Artifact Requirements" above).
- Useful commands (run from repo root or `/srv/homelab-config`):
	- Build docs: `mkdocs build` (site output -> `site/`)
	- Serve docs locally: `mkdocs serve`
	- Run shell scripts: `bash scripts/<path>.sh` or `pwsh scripts\<path>.ps1` on Windows
- Key locations:
	- Docs: `docs/` and `mkdocs.yml`
	- Automation scripts: `scripts/` (helpers for telemetry, HC, session automation)
	- Evidence artifacts: `artifacts/hc/`
	- Repository onboarding: `CONTRIBUTING.md`, `Readme.md`

### For AI coding agents — quick rules

- Preserve existing content in this file; add only short, actionable guidance and links.
- Prefer linking to docs ("link, don't embed"). If a full explanation exists in `docs/` or `CONTRIBUTING.md`, add a link rather than copy.
- Keep `description` fields in customizations explicit and keyword-rich (use the "Use when:" pattern).
- Avoid `applyTo: "**"` unless the instruction truly applies everywhere.

If you make edits to repo files, add an artifact in `artifacts/hc/` documenting the change and the commands you ran. See the repository `CONTRIBUTING.md` for local lint/test guidance.
