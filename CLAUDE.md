# CLAUDE.md

D070726 | CHG-REPO-HEALTH-LAND-001 | add repo-level operating guidance during
repo-health-curator landing | JC | ct409

D082626 | CHG-PP-ATTRIBUTION-001 | require p.p. attribution on agent-made
change headers | p.p. claude-sonnet-5 for JC | ct409

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Standing orders

These apply to every session working in this repository, not just this change:

- Every created/modified file gets a compact column change header:
  `D<MMDDYY> | CHG-ID | reason | <signature> | target system`, where
  `<signature>` is `JC` (operator edited directly) or
  `p.p. <agent-identifier> for JC` (an agent edited on the operator's
  authority) — see the next bullet.
- The signature slot is a signature, not a label: it identifies who is
  accountable for the change. When an agent (not the operator directly)
  made the edit, the slot reads `p.p. <agent-identifier> for JC` — the
  classic business-letter "per procurationem" mark for someone acting on
  another's authority, borrowed here so a reader can tell at a glance
  whether the operator or a delegated agent touched the file, without
  hunting through session logs. `JC` alone means the operator made the
  edit directly. This does not change who is accountable (the operator
  always is, per the operator-directs-agents model); it only changes what
  the file itself discloses about who physically made the edit.
- Never overwrite a file without a timestamped backup (`D<MMDDYY>T<HHMM>` suffix).
- Never delete logs or backups; session histories count as logs.
- Nothing runs on a schedule unless the code it executes is committed.
- `/root` (on any control node) is a workbench, not a destination — matured
  work lands in a repo with an origin.
- Idempotent Ansible; modules over shell where a module exists.
- The only writable checkout of `homelab-config` is on CT 409 (`pve-ansible`).

## What this repo is

`homelab-config` is the Git-tracked configuration, automation, and
documentation repo for a Proxmox VE homelab (cluster `pve-plex`: `alpha`
192.168.4.10, `charlie` 192.168.4.30, `bravo` 192.168.4.249). It covers
Ansible playbooks/roles/inventory, systemd units deployed to cluster hosts,
GitHub Actions automation, and MkDocs Material documentation published to
GitHub Pages (`gh-pages` branch).

**The only writable checkout is on CT 409** (`pve-ansible` LXC on `alpha`),
at `/mnt/repos/homelab-config`. Other hosts (e.g. a retired fileserver
install) may have read-only or stale clones — do not assume a clone
elsewhere is authoritative or current.

**Known clutter, not to "clean up" incidentally:** the repo root has ~28
per-AI-tool skill/config directories (`.adal/`, `.agents/`, `.claude/`,
`.codebuddy/`, `.commandcode/`, `.continue/`, `.crush/`, `.factory/`,
`.goose/`, `.iflow/`, `.junie/`, `.kilocode/`, `.kiro/`, `.kode/`,
`.mcpjam/`, `.mux/`, `.neovate/`, `.openhands/`, `.pi/`, `.pochi/`,
`.qoder/`, `.qwen/`, `.roo/`, etc.) plus a root-level `skills/` — apparently
from a multi-tool sync process. Large, low-risk to ignore, out of scope for
unrelated changes. A `.recycle/` directory also contains **nested separate
git repositories** (its own `.git`, plus `.git` dirs inside
`_pr8_clean/`/`_wt_pr8/`) — do not run recursive git operations across
`.recycle/` without accounting for this.

## Repository Health Curator subsystem

Automation that inventories Git repositories on server storage and turns
accumulated drift into secret-safe checkpoint commits and draft PRs, without
force-pushing, discarding work, or touching a protected branch directly.
Full behavioral spec: `skills/repo-health-curator/SKILL.md` and
`skills/repo-health-curator/references/policy.md` — read these before
changing curator logic; the Python scripts implement what's specified there.

- `scripts/reporting/scan_repositories.py` — read-only inventory of Git repos
  under `/home`, `/mnt/repos`, `/srv`. Never fetches/pulls/commits/pushes.
- `scripts/reporting/curate_repositories.py` — policy-driven: checks for
  in-progress merges/rebases, unmerged paths, oversized files, and
  high-confidence secrets (fingerprinted, never logged in plaintext); runs
  hard vs. advisory validations from `configs/repository-curator.json`; if
  clean, commits and — only in `checkpoint-push` mode with an allowlisted
  remote — pushes to `repo-health/<host>/<UTC timestamp>`.
- `ops/systemd/repository-{scan,curator}-agent.{service,timer}` — deployed via
  `deploy/ansible/playbooks/repository-scan-agent.yml`.
- `.github/workflows/repo-health-curator.yml` — opens a draft PR on any push
  to `repo-health/**`.

**Current state on CT 409 (as of this landing):** `repository-scan-agent.timer`
is enabled and running hourly (read-only, no risk). `repository-curator-agent.timer`
is installed but **deliberately disabled** — the checkpoint-push path was left
gated on installing/authenticating the `gh` CLI, which has not been done.
**Do not enable this timer or install/authenticate `gh` without explicit
operator sign-off** — that gate is intentional, not an oversight.

## Known automation conflict: `auto-stage-lint.yml`

`.github/workflows/auto-stage-lint.yml` ran on an hourly schedule with an
unscoped `git add -A` + auto-commit + direct push to whatever branch
triggered it — on a `schedule` trigger, that means **pushing straight to
`main`, unreviewed**. This directly contradicts the repo-health-curator's own
first invariant (never push directly to a protected branch). Its schedule
trigger has been disabled (see the workflow file's own header comment for
the investigation of why ~1,360 "successful" hourly runs never produced a
visible commit — most likely a missing `permissions: contents: write` block
meant its `GITHUB_TOKEN` could never actually push). `workflow_dispatch` is
left in place for manual runs if ever needed; do not re-enable the schedule
without re-scoping the script (targeted paths, not `-A`) and adding explicit
write permissions deliberately.

## Docs and session logs

- Published via MkDocs Material (`mkdocs.yml`) to GitHub Pages.
  `docs/DOCS_INDEX.md` is the docs overview; keep both in sync when adding docs.
- `docs/session-logs/<timestamp>-<TOPIC>.md` is the established session-log
  convention for recording infrastructure work sessions — check this
  directory before assuming prior work here is undocumented.
- `TURNOVER-CC-FILESERVER.md` and `TURNOVER-CODEX-SESSIONS.md` (repo root)
  are handoff documents between agent sessions/hosts — read them first when
  picking up work on this repo after a gap.
