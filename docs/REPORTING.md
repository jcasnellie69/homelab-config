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

Docs generation targets:

- `docs/inventory/index.md` — created from fragments with `-inventory.md` suffix
- `docs/health/index.md` — created from fragments with `-health.md` suffix

Evidence retention:

All raw evidence and metadata are stored under `/srv/artifacts/hc/` and must not be removed by the publish step or by CI.
