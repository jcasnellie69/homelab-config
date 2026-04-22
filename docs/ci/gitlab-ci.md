# GitLab CI/CD Guide

## Purpose

GitLab is the primary CI/CD path for the Ansible control plane in this repo.
The pipeline is intentionally split into safe validation stages and a manual
execute stage.

## Stages

1. **lint** — compile Python automation, run workspace health, build metadata
2. **validate** — regenerate inventory, install collections, syntax-check playbooks
3. **dry-run** — manual controller-side connectivity and optional OPNsense `--check`
4. **execute** — manual live execution only after credentials are confirmed

## Required variables

Set these as GitLab CI/CD variables and keep them masked:

- `PVE_API_USER`
- `PVE_API_TOKEN_ID`
- `PVE_API_TOKEN_SECRET`
- optional: `OPNSENSE_API_KEY`
- optional: `OPNSENSE_API_SECRET`
- optional: `NETBOX_URL`
- optional: `NETBOX_API_TOKEN`

## Safe operating rules

- Do not enable the execute stage automatically.
- Use the generated inventory and the curated `inventory/lab/hosts.yml` together.
- Treat NetBox as supplemental until CT 100 service health is restored.
- Re-run `workspace: infra artifacts` after any discovery update.

## Suggested flow

1. Push the branch to GitLab.
2. Let `lint` and `validate` run automatically.
3. Trigger `dry_run_validation` manually after reviewing the generated evidence.
4. Trigger `manual_execute_opnsense` only when Proxmox credentials and rollback
   expectations are in place.
