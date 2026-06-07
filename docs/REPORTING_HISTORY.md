# Reporting Pipeline: History, Current State, and Next Steps

This document records the design decisions, current status, and next steps for the homelab reporting pipeline. Use this as the authoritative history from this point forward so future changes avoid bringing drifted or experimental code into the main flow.

Status snapshot (2026-04-26)
- Branch: `palette-docs-ux-8223692010619523150`
- Key artifacts already added to the repo:
  - Collection scripts and wrappers: `scripts/inventory/inventory-collect.sh`, `scripts/hc/hc-validate.sh`, `scripts/publish/publish-health-docs.sh` (and local-runner/systemd examples)
  - Self-hosted workflow: `.github/workflows/homelab-inventory-health.yml` targeting label `homelab`
  - Remote orchestrator: `scripts/ci/remote_run_on_nodes.sh` (SSH-based remote runner)
  - Evidence artifact(s) under `artifacts/hc/` created during development

Why this document exists
- The repository has gone through several direction changes and edits (some accidental). This file locks in the intended architecture and implementation conventions so subsequent work follows a single, auditable path.

Goals and constraints
- Evidence-first: raw outputs and backups must be stored under `/srv/artifacts/hc/<host>-<timestamp>/` and never be committed into Git.
- Generated documentation (polished output) lives under `docs/health/` and `docs/inventory/` and may be committed when changed.
- Git commits that publish docs must be made only when content changes; use `scripts/git_stage_and_push.sh` or equivalent to commit and push.
- GitHub-hosted runners cannot access the homelab LAN; runs requiring LAN access must execute on a self-hosted runner or directly on the fileserver LXC (NFS export, mounted as `Z:/` in Windows). Prefer self-hosted runner on the fileserver LXC or systemd timer on the LXC for scheduled runs.
- Do not commit secrets or raw logs to the repository.

Core scripts (intended behavior)

1) `scripts/hc/hc-validate.sh`
- Purpose: preflight validation for collectors and publisher. It must:
  - Confirm `ARTIFACT_BASE` (default `/srv/artifacts/hc`) exists and is writable, creating it if safe and permitted.
  - Verify required commands exist (`git`, `tar`, `df`, `ss`, `systemctl`), and if optional commands are missing (e.g., `zpool`, `docker`) log that the feature will be skipped.
  - Exit non-zero on fatal errors so orchestration fails fast.

2) `scripts/inventory/inventory-collect.sh`
- Purpose: produce raw evidence for inventory collection.
- Behavior:
  - Create a timestamped directory: `/srv/artifacts/hc/<hostname>-<ISO8601-timestamp>/` (use UTC or clearly documented local timezone — ISO format recommended: `YYYY-MM-DDTHHMMSSZ`).
  - Collect outputs into `raw/` (e.g., `raw/df.txt`, `raw/lsblk.txt`, `raw/zpool-status.txt`, `raw/docker-ps.txt`, `raw/ss-listening.txt`, `raw/journalctl.txt`).
  - Create `json/metadata.json` with fields: `timestamp`, `hostname`, `branch`, `commit`, `artifact_dir`, `collector_version` and the list of files collected.
  - Create `summary.md` (brief Markdown summary with table of key fields) suitable for `publish-health-docs.sh` to copy into `docs/`.
- Implementation notes:
  - Prefer using `python -c` with `json` library if Python is available for JSON; otherwise produce reasonably well-formed JSON with careful quoting.
  - Skip expensive collections or commands that are not present; record these omissions in `metadata.json`.

3) `scripts/publish/publish-health-docs.sh`
- Purpose: generate polished documentation from the latest artifact for that host.
- Behavior:
  - Determine latest artifact by timestamp in `/srv/artifacts/hc/` or accept `--artifact <path>`.
  - Create a timestamped backup of the current docs into `/srv/artifacts/hc/<host>-<ts>-backup-docs/` before overwriting files under `docs/health/` or `docs/inventory/`.
  - Write `docs/health/latest.md`, `docs/health/index.md`, `docs/inventory/latest.md`, and `docs/inventory/index.md` (index pages can include lists of available artifacts and links to the artifact directories).
  - Only commit and push if `git` shows changes (use `scripts/git_stage_and_push.sh` which should be idempotent and safe for CI use).

Project structure updates and `mkdocs.yml`
- Inspect `mkdocs.yml` before edits and append new `nav` entries under the existing `nav:` section. If `nav:` does not exist, create it following existing site structure conventions.
- Preferred placement: Add `Inventory` and `Health` sections under a `Docs` group if such grouping exists. Example (append under `nav:`):
  - Docs:
    - Inventory: `docs/inventory/index.md`
    - Health: `docs/health/index.md`
- Do not add raw artifact paths to the site; only the polished `latest.md` pages should be part of the site.

Data to gather for health and inventory
- Storage: `df -h`, `lsblk -J`, `zpool status` (if ZFS present)
- Containers: `docker ps -a` (if Docker present), `podman ps -a` if applicable
- Network: `ip -br addr`, `ss -tunlp` to list listening services
- Service health: `systemctl --failed`, `journalctl -p err -n 200`
- Proxmox specifics: `pvesh`/`qm`/`pct` outputs, if present
- All collected raw outputs should be stored in `raw/` and referenced from `json/metadata.json` and `summary.md`.

Testing and CI
- Add a small unit test script `scripts/ci/tests/check_script_paths.sh` that scans repository `.sh` files for references to paths like `scripts/...*.sh` and fails if those referenced files are missing. This will catch mismatches like `scripts/reporting/collect_inventory.sh` vs `scripts/inventory/inventory-collect.sh`.
- Add a GitHub Actions workflow `.github/workflows/ci-checks.yml` to run the script on push and pull request, ensuring path sanity before merges.

Remote orchestration vs local-runner
- Remote SSH orchestration: `scripts/ci/remote_run_on_nodes.sh` uploads current `scripts/` tree to nodes and runs `scripts/reporting/collect_*` on the remote host under `~/homelab-config/`.
- Compatibility: to avoid updating orchestration scripts when the canonical collectors live elsewhere, create small wrapper scripts under `scripts/reporting/` that `exec` the canonical scripts under `scripts/inventory/` or `scripts/hc/`. These wrappers are simple, idempotent, and safe to create with automation (e.g. Ansible playbook).
- Local-runner/systemd: the `scripts/hc/local-runner.sh` and `systemd` unit/timer examples are intended to run the collect→publish flow directly on the fileserver LXC (preferred for scheduled local-only runs).

Ansible automation plan
- Use the repository's Ansible control host to:
  - Ensure `dos2unix` is installed and shell scripts have correct line endings and executable bits
  - Create wrapper scripts under `scripts/reporting/` to match orchestrator expectations
  - Install `scripts/ci/tests/check_script_paths.sh` and run it once to surface issues
  - Optionally copy systemd unit/timer files to `/etc/systemd/system/` and enable the timer

Operational notes and safety
- Never commit raw logs or secrets. The `publish-health-docs.sh` script must not embed raw content — only brief summaries and links to artifact paths.
- When running on the fileserver LXC, prefer executing scripts as a dedicated user with appropriate permissions; where sudo is required, document the sudoers rule in `docs/REPORTING.md`.
- Ensure the repo's `artifacts/hc/` is treated as the canonical evidence store and is included in backups and retention policies.

Change history and auditing
- Any code edits touching `scripts/` must be accompanied by an evidence artifact under `artifacts/hc/` documenting the change, commands run, and output (example: `artifacts/hc/YYYY-MM-DD-HH-MM-description.txt`). This is a process requirement for repository changes.

Course correction (2026-05-17)
- Context: GitBook sync hit the 5,000 page import limit because the repository contains generated agent/tooling directories in addition to the docs source. A `.gitbook.yaml` file was added on `main` to scope GitBook to `./docs`.
- Local cleanup decision: keep intentional repository instruction files such as `.github/AGENTS.md` and `.github/copilot-instructions.md`, but do not commit auto-discovered agent skill mirrors or local runtime/cache copies.
- Ignore policy: generated agent skill mirrors and duplicate cache folders such as `.adal/`, `.agents/`, `.claude/skills/`, `.goose/`, `.recycle/`, `.roo/`, `.trae/`, `.windsurf/`, `.zencoder/`, and top-level `skills/` are ignored. Repo-owned agent instructions should live in intentional files, not copied skill libraries.
- Rationale: this keeps GitBook, GitHub search, and CI focused on source docs and repo automation while still allowing local agent tools to discover and use their runtime skills.

Next immediate actions (short list)
1. Create compatibility wrapper scripts in `scripts/reporting/` (safe, low-risk).
2. Add `scripts/ci/tests/check_script_paths.sh` and run locally / in CI.
3. Add `docs/REPORTING_HISTORY.md` (this file) and update `docs/REPORTING.md` with the operational how-to (Ansible steps, systemd instructions).
4. Add `ci-checks.yml` to run the path-check test on PRs.

If you want, I will now:
- create the wrapper scripts and the `check_script_paths.sh` test and open a branch with the changes, OR
- create the Ansible playbook in `ansible/playbooks/` and a README to run it against `fileserver` inventory.

Appendix: Helpful commands
- Normalize scripts and add exec bits (run on LXC):
  ```bash
  sudo apt-get update && sudo apt-get install -y dos2unix
  find . -type f -name '*.sh' -print0 | xargs -0 dos2unix
  find scripts -type f -name '*.sh' -exec chmod +x {} \;
  ```
- Run the script-path test:
  ```bash
  bash scripts/ci/tests/check_script_paths.sh
  ```

Document authored by: automation agent (session snapshot)
Date: 2026-04-26
