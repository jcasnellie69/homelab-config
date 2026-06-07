# Reporting flow

This repository follows a strict separation of concerns for the homelab reporting pipeline:

- scripts collect data → publish scripts generate docs → GitHub Actions keeps pages current

Key rules:

- Collection scripts are authoritative and runnable manually from the repository root.
- Scripts produce three artifacts for every run:
  - Raw logs (human-readable) under `/srv/artifacts/hc/` (never deleted)
  - JSON metadata describing the run under `/srv/artifacts/hc/`
  - Markdown fragments under `/srv/artifacts/hc/fragments/` which are consumed by the publish step
- Publishing is done by `scripts/reporting/publish_docs.sh` which reads fragments and writes pages into `docs/inventory/` and `docs/health/`.
- GitHub Actions only orchestrates runs (schedule and manual dispatch) and commits generated docs when content changes — it does not implement collection logic.

How to run manually (from repo root):

Build the docs locally after collecting and publishing:

```bash
./scripts/reporting/collect_inventory.sh
./scripts/reporting/collect_health.sh
./scripts/reporting/publish_docs.sh
mkdocs build
```

To avoid leaving untracked changes after running scripts, use the helper to stage/commit/push:

```bash
./scripts/git_stage_and_push.sh "chore(reporting): update generated docs"
```

This will stage all changes, commit with the provided message (or a timestamped default), and push to the current branch.

Running collection across cluster nodes
-------------------------------------

This repo includes an Action and helper script to run the collection scripts on all Proxmox nodes in the cluster. The approach is:

- Standardize a repo path on each node: `~/homelab-config/` will contain the `scripts/` tree copied from the repo.
- The GitHub Action `reporting-remote.yml` SSHes to each node, uploads the `scripts/` directory, and runs the collection scripts (`scripts/reporting/collect_inventory.sh` and `scripts/reporting/collect_health.sh`) on each node.
- Each node writes raw evidence to `/srv/artifacts/hc/` locally — the Action does not move or delete raw evidence.

Required repository secrets (set in GitHub repo Settings → Secrets):

- `SSH_PRIVATE_KEY` — private SSH key for `SSH_USER` that can connect to all nodes.
- `SSH_NODES` — comma-separated list of IPs or hostnames for the Proxmox nodes (e.g., `10.0.0.2,10.0.0.3,10.0.0.4`).
- `SSH_USER` — username to SSH as (user must have permission to write `~/homelab-config/` and to create `/srv/artifacts/hc/`, or configure `RUN_AS_SUDO` below).
- Optional: `SSH_PORT` (default 22), and `RUN_AS_SUDO` (`true`|`false`). If `RUN_AS_SUDO=true` the remote commands will be prefixed with `sudo` (useful when writing to `/srv/artifacts/hc/` requires root).

How the Action works
--------------------

1. The Action checks out the repo, writes `SSH_PRIVATE_KEY` to `~/.ssh/id_rsa` in the runner.
2. It sets `NODES`, `SSH_USER`, `SSH_PORT`, and `RUN_AS_SUDO` as environment variables.
3. It runs `./scripts/ci/remote_run_on_nodes.sh`, which uploads the `scripts/` directory to `~/homelab-config/` on each node and invokes the collection scripts there.

Security notes
--------------

- `SSH_PRIVATE_KEY` should be a deploy key or machine user key with narrow permissions. Consider using a key that is limited to pushing artifacts only and not a personal account key.
- Ensure branch protection or repository policies allow Actions to push if the workflow needs to commit back; by default this action does not fetch artifacts back to repo — it merely triggers collection on nodes.


Docs generation targets:

- `docs/inventory/index.md` — created from fragments with `-inventory.md` suffix
- `docs/health/index.md` — created from fragments with `-health.md` suffix

Evidence retention:

All raw evidence and metadata are stored under `/srv/artifacts/hc/` and must not be removed by the publish step or by CI.

Local runner (recommended for LAN-only homelab)
---------------------------------------------

If GitHub-hosted runners cannot reach your LAN, run the pipeline locally on a machine inside your homelab (for example the fileserver that mounts this repo as `Z:/`). Two options are provided:

- Use the GitHub Action on a self-hosted runner labeled `homelab` (see `.github/workflows/homelab-inventory-health.yml`). Configure your self-hosted runner to run on the homelab network so it has access to nodes and `/srv`.
- Or run the provided local runner and systemd timer on the fileserver directly:

  - `scripts/hc/local-runner.sh` — wrapper that runs validation, inventory collection, and publish from the repo root.
  - `scripts/hc/systemd/local-runner.service` and `scripts/hc/systemd/local-runner.timer` — example units to run daily at 06:00 local time. Update `WorkingDirectory` and `ExecStart` paths to match the mounted repository path on the fileserver.

Installation sketch for systemd (example):

```sh
# copy service and timer to /etc/systemd/system/
sudo cp scripts/hc/systemd/local-runner.* /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now local-runner.timer
```

The local-runner invokes `./scripts/inventory/inventory-collect.sh` and `./scripts/publish/publish-health-docs.sh` and will commit generated docs only if content changed.

