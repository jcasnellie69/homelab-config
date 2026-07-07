# TURNOVER-CC-FILESERVER.md

D070626 | CHG-AGENT-MOVE-001 | CC relocation to ansible LXC | JC | fileserver->ct409

This Claude Code install (running on the `fileserver` host, `192.168.4.60` / Proxmox VM 101 on alpha) is being retired. A new install on the Ansible LXC (CT 409, `pve-ansible`, on alpha) takes over all work in this repo from here. This document is written for that successor session, which will start with zero memory of this one.

---

## ⚠️ READ THIS FIRST — UNCOMMITTED WORK EXISTS

Despite the instruction that there should be nothing uncommitted, there is:

1. **`network-inventory` repo has an uncommitted, unpushed change to `README.md`** (one-line Pages URL fix, see below). It is sitting in the working tree at `/srv/network-inventory` on this fileserver only. **Not committed, not pushed.**
2. **`homelab-config` has an untracked `staged/` directory** at repo root containing two pasted Codex session-transcript `.txt` files used as reference material during this session (not meant to be permanent repo content — see IN-FLIGHT section).
3. **A separate, unrelated `homelab-config` checkout on CT 409 itself** (`/mnt/repos/homelab-config`, where you will be running) **has ~15 uncommitted files** representing a working automation system. This is likely the single most important thing in this document — see IN-FLIGHT #1.

Everything else in `/srv/homelab-config` on this fileserver is clean and pushed.

---

## 1. WORK COMPLETED (this session, on this fileserver)

Repo: `homelab-config`, branch `palette-docs-ux-8223692010619523150` (HEAD `4a63a41`, in sync with origin — pushed):

- Closed 67 stale daily `google-labs-jules[bot]` PRs on `network-inventory` (#11–#77) and 68 on `homelab-config` (#41–#108) — Jules was re-opening a near-identical PR every day for ~7 weeks without ever addressing reviewer feedback. Each close has an explanatory comment.
- `e39ff7f` — Enabled `navigation.path` (MkDocs Material breadcrumbs) by hand — the exact change Jules kept failing to land.
- `6c1f6db` — Recovered the "Signal Archaeology" network inventory report + VLAN topology SVG from an untracked `docs/files.zip` and stray version files in the working tree (never committed); published as `docs/network-signal-archaeology.md` + `docs/img/`, wired into MkDocs nav.
- `4a63a41` — Added `CHANGELOG.md` (symlinked into `docs/CHANGELOG.md` for MkDocs) and made changelog entries mandatory in `.github/copilot-instructions.md`, because the existing evidence-artifact rule alone wasn't producing a readable history — see `CHANGELOG.md` itself for full incident detail, don't duplicate it here.
- Generated a reusable ed25519 keypair (`~/.ssh/homelab_ci_ed25519` on this fileserver), added the public half to `root@alpha`'s `authorized_keys`. Confirmed it also works on `charlie` and `bravo` for free — Proxmox propagates root SSH trust across all cluster members automatically, no per-node setup needed.
- Set repo secrets on `homelab-config` to unblock the existing (unmerged) `reporting-remote.yml` workflow: `SSH_PRIVATE_KEY` (the key above), `SSH_NODES=192.168.4.10`, `SSH_USER=root`.
- Fixed a broken GitHub Pages link in `network-inventory`'s `README.md` (`jcasnellie.github.io` → `jcasnellie69.github.io`, missing the `69`) — **written but not committed**, see IN-FLIGHT.
- Live-verified and corrected stale infrastructure assumptions found in old docs/transcripts (see ENVIRONMENT NOTES for current truth): Docker VM's real IP, bravo's cluster status, netbox's real CT ID.

No changes were made to `main` on either repo. Nothing was pushed to `main`.

---

## 2. IN-FLIGHT / INCOMPLETE

1. **The ansible-CT repo-curator system (highest priority to pick up).** On CT 409 (where you're starting), `/mnt/repos/homelab-config` is on `main` (HEAD `a6b15daf...`, in sync with origin/main) but has uncommitted, unpushed, dated **2026-05-28**:
   - Modified: `.github/AGENTS.md`, `docs/DOCS_INDEX.md`, `mkdocs.yml`
   - Untracked: `.github/workflows/repo-health-curator.yml`, `scripts/reporting/curate_repositories.py`, `scripts/reporting/scan_repositories.py`, `skills/repo-health-curator/`, `ops/systemd/repository-curator-agent.{service,timer}`, `ops/systemd/repository-scan-agent.{service,timer}`, `deploy/ansible/`, `docs/opnsense-staged-deployment.md`, `docs/opnsense-vlan-port-map.md`, `docs/proxmox-api-token-bootstrap.md`, `docs/runbooks/`, `docs/session-logs/20260528-062237-BUILD-HC-AUTOMATION.md`, `artifacts/remediation_log.md`, `artifacts/hc/2026-05-28-opnsense-readiness.md`
   - This is **not a draft** — `artifacts/remediation_log.md` shows it actively ran and successfully resolved disk-space pressure on the `homepage` and `watchyourlan` CTs on **2026-07-02** (4 days before this handoff). It is live production automation with zero git history. If CT 409's disk is ever lost, this all disappears with no trace on GitHub.
   - The user's explicit ask (verbatim intent): "they should have been committed... the key is if any of that changes version etc that the commit doesn't get left behind, that pipeline parity is enforced." Read all of these files, understand what they do, and get them committed/pushed (to a reviewable branch, not straight to main) as the first real task.
   - `configs/repository-curator.json` on this same checkout defines the intended design: a "checkpoint-push" mode that auto-commits `/mnt/repos/homelab-config` and `/mnt/repos/network-inventory` under a `repo-health/*` branch prefix. Whether this should run as designed or be reconsidered is an open question — user has not confirmed the branch-prefix auto-push design, only that things should be committed somehow.

2. **`palette-docs-ux-8223692010619523150` → `main` merge, on the *fileserver's* clone.** Three commits (breadcrumbs, Signal Archaeology, CHANGELOG) plus the original unmerged `687d345` (2026-06-07, "Add homelab reporting pipeline and CI/workflows" — six GitHub Actions workflow files) are all sitting on this one branch, never merged. No PR opened yet. Before merging, a decision is needed on:
   - `auto-stage-lint.yml` — hourly, GitHub-hosted, runs `git add -A` + auto-commit + auto-push across the whole repo with zero scoping. Strongly suspected root cause of a repo-wide 90,430-file CRLF-flip state that predates this session (see KNOWN ISSUES). Recommend NOT merging as-is.
   - `reporting.yml` — daily, GitHub-hosted stub that can't reach the homelab LAN (captures the ephemeral Actions runner's own environment instead), then auto-commits that noise into `docs/`. `docs/REPORTING_HISTORY.md` (already in the repo) explicitly calls this out as drift, not the intended design. Recommend removing before merge.
   - `homelab-inventory-health.yml` — the real, intended pipeline per `REPORTING_HISTORY.md`. Needs a self-hosted GitHub Actions runner labeled `homelab` registered somewhere (none exists yet — `gh api repos/jcasnellie69/homelab-config/actions/runners` returns 0). CT 409 is the obvious candidate to host this runner, given you're now working from there.
   - `mkdocs-deploy.yml` and `lint.yml` are safe to merge as-is.
   - `push-wiki.yml` — `WIKI_PAT` secret exists; unverified whether a `WIKI/*.md` source directory has real content for it to sync.

3. **GitHub Pages is not configured at all** for `homelab-config` (404 on the Pages API). `mkdocs-deploy.yml` (unmerged, see above) would set this up via `peaceiris/actions-gh-pages` on first push to `main` once merged — but Pages may still need to be manually pointed at the `gh-pages` branch afterward; verify, don't assume.

4. **`network-inventory/README.md` fix is uncommitted** (see top of doc). Trivial — just commit and push it. Git identity for that repo is `Jcasnellie <148508183+jcasnellie69@users.noreply.github.com>` (matches existing commit history there; configured locally via `git config user.name/user.email`, not global).

5. **`.gitbook.yaml` decision.** Root-level GitBook config (`root: ./docs`) from an abandoned mid-May direction change, before the user settled back on MkDocs Material (confirmed explicitly this session — do not re-litigate that choice). Asked the user whether to drop `.gitbook.yaml` or keep both; no answer given yet.

6. **Docker VM (109, "docker") has no DHCP reservation** and its IP has drifted at least 3 times (`.149` in an April cut-sheet snapshot → `.224` per a mid-session Codex transcript → **`.76`, confirmed live via `qm agent 109 network-get-interfaces` on 2026-07-06/07 — trust this over anything else**). User's explicit direction: **do not** just add a Pi-hole DHCP reservation as a patch. The real fix is bringing `opnsense-alpha` (VM 401, currently **stopped**) back up so OPNsense is actually providing DHCP as designed (ties into the CARP HA alpha+charlie design intent seen in `docs/network-signal-archaeology.md`'s topology SVG). **There is supposedly an existing OPNsense plan doc somewhere — user said "we will look for it later"; it was not located this session. Worth a targeted search before redesigning anything OPNsense-related.**

7. **`bravo` (`192.168.4.249`, hostname `pve.node.local`) status is resolved, not open**: user confirmed explicitly to keep it in the Proxmox cluster for 3-node quorum. Do not `pvecm delnode` it. Noting here only so a future session doesn't reopen this as if undecided.

8. **The two files in `homelab-config/staged/`** (`i ran a fresh scrtipt run earlier t.txt`, `Identified multiple startup failure.txt`) are pasted Codex session transcripts the user provided as context this session (one about an earlier dhcp-discovery publish-path fix and HC script path fix, both already merged to `main` via `709621b` and `a6b15df`; the other about Docker-context/Ansible/Semaphore orchestration planning for moving Docker off the user's laptop). They're read and their content is reflected in this document and in memory. Ask the user whether to delete them, keep them as reference docs somewhere proper, or leave as-is.

---

## 3. KNOWN ISSUES (observed, out of scope to fix this session)

- **~90,430 files show as modified in `homelab-config`'s working tree, but every single one is a pure CRLF↔LF line-ending flip with zero real content change** (verified via `git diff --ignore-all-space` showing 0 insertions/deletions). This predates this session. Prime suspect: `auto-stage-lint.yml`'s unscoped `git add -A` + auto-commit hourly job (see IN-FLIGHT #2) — this pattern, if merged and run, would explain exactly this kind of repo-wide churn.
- **Massive multi-AI-tool skill-package sprawl** at repo root: `.adal/`, `.agents/`, `.claude/`, `.codebuddy/`, `.commandcode/`, `.continue/`, `.crush/`, `.factory/`, `.goose/`, `.iflow/`, `.junie/`, `.kilocode/`, `.kiro/`, `.kode/`, `.mcpjam/`, `.mux/`, `.neovate/`, `.openhands/`, `.pi/`, `.pochi/`, `.qoder/`, `.qwen/`, `.roo/`, `.trae/`, `.vibe/`, `.windsurf/`, `.zencoder/`, plus a root-level `skills/` — each appears to be a per-tool copy of the same skill library, likely from some sync tool. Not investigated further; contributes heavily to repo size and to the CRLF-churn blast radius.
- **`.recycle/` directory contains nested, separate git repositories** (`.recycle/.git`, `.recycle/_pr8_clean/.git`, `.recycle/_wt_pr8/.git`) inside the main repo's working tree. It also holds what looks like a genuinely useful, more-accurate Ansible inventory (`.recycle/deploy/ansible/inventory/lab/hosts.yml`) that is *not* live anywhere — it's just sitting deleted-but-retained. Worth rescuing that file specifically; the vmids/IPs in it are still closer to correct than the tracked `docs/inventory/cut sheet.xlsx`, though both are now stale relative to live cluster state (see ENVIRONMENT NOTES).
- **The "Signal Archaeology" report and `docs/inventory/cut sheet.xlsx` have real data-quality issues** — e.g. a device MAC-address cross-reference in the cut sheet pointed at a stale IP that turned out to be three IPs out of date when checked against live state. Treat that report as a stylized snapshot from 2026-04-06, not current ground truth.
- **`docs/network-inventory/index.md`** (a *different* page from the standalone `network-inventory` repo's dashboard — easy to confuse) is still a placeholder on `main`. The publish script (`scripts/dhcp/dhcp-discovery-publish.sh`) exists and works, but the full collect→publish→commit→push cycle has apparently never been run end-to-end since the script was merged (`709621b`). This is the original "network page not current" complaint that kicked off this whole session — it is **still unresolved** on `main`.
- Two other Codex sessions (found on CT 409, dated 2026-06-09 and later) reference a "Linux MCP Runtime" install requirement on the Docker VM and gitkraken MCP setup — not investigated for completion status.

---

## 4. REPO STATE (as of handoff)

**`homelab-config`** (`/srv/homelab-config` on this fileserver):
- Branch: `palette-docs-ux-8223692010619523150`
- HEAD: `4a63a41cdb6417ae2a2b22069a8db450492dfda7` ("Add CHANGELOG.md and make changelog entries mandatory")
- Fully pushed, 0 ahead/behind `origin/palette-docs-ux-8223692010619523150`
- Working tree: clean except the harmless CRLF noise (see Known Issues) and the untracked `staged/` folder (see In-Flight #8)

**`homelab-config`** (`/mnt/repos/homelab-config` on CT 409 — where you're starting):
- Branch: `main`
- HEAD: `a6b15dfaf1eb4f9edb38cbdad9c659afbab29f51` ("fix: make hc scripts checkout-relative")
- In sync with `origin/main`
- Working tree: **not clean** — see In-Flight #1, the repo-curator files

**`network-inventory`** (`/srv/network-inventory` on this fileserver):
- Branch: `main`
- HEAD: `bc88c26fb04f64fc3f748faf85dcaeba80ed4761`
- In sync with `origin/main`
- Working tree: **not clean** — one-line uncommitted `README.md` fix, see top of doc

---

## 5. ENVIRONMENT NOTES for the successor

**Topology (live-verified 2026-07-06/07, trust this over any doc/transcript):**
- This fileserver = `192.168.4.60`, hostname `fileserver`, = Proxmox VM 101 on alpha.
- `alpha` = `192.168.4.10`, hostname `pve-plex-oasis-alpha`, PVE 9.2.3. This is where `pct`/`qm` commands run.
- `charlie` = `192.168.4.30`, hostname `pve-plex-oasis-charlie`. Runs `pihole` (CT 115, not the vmid in old docs).
- `bravo` = `192.168.4.249`, hostname `pve.node.local`. Alive, no guests, kept in cluster deliberately for quorum (3 nodes, cluster name `pve-plex`) — do not delnode.
- Cluster is quorate with all 3 nodes.
- Ansible CT = **CT 409** on alpha, name `pve-ansible` — this is you, if you're reading this from there.
- Docker VM = **VM 109** on alpha, name `docker`, current real IP **`192.168.4.76`** (verified via `qm agent 109 network-get-interfaces`; ignore any doc/transcript saying `.149` or `.224` — both were once true, neither is now). No DHCP reservation; expect drift.
- `opnsense-alpha` = VM 401 on alpha, currently **stopped**.
- `netbox` = CT 200 on alpha (old docs say vmid 100 — that's now `proxmox-datacenter-manager`; don't trust old vmid mappings without a live `pvesh get /cluster/resources` check).
- Full current container/VM list is one `ssh root@192.168.4.10 "pct list; qm list"` away — cheaper and more trustworthy than any doc, including this one after enough time passes.

**SSH:**
- Proxmox propagates root SSH trust automatically across all cluster members (alpha/charlie/bravo) — a key authorized on one works on all three. No per-node key management needed within the cluster.
- The key generated this session (`~/.ssh/homelab_ci_ed25519` on the fileserver, public half in `alpha:~/.ssh/authorized_keys`) is also stored as the `SSH_PRIVATE_KEY` GitHub secret on `homelab-config`. If you need it and aren't on the fileserver, it's in that secret (write-only from GitHub's side — can't be read back out via `gh`) or can be regenerated and re-authorized in under a minute.
- CT 409 already has its own separate Codex history and was presumably already reachable from wherever it's normally administered from — check its own `~/.ssh/` before assuming you need the fileserver's key.

**Git:**
- `gh` CLI is authenticated as `jcasnellie69`.
- Git identity is set **locally per-repo** (not globally), matching each repo's existing commit-author convention: `homelab-config` → `jcasnellie69 <jcasnellie@gmail.com>`; `network-inventory` → `Jcasnellie <148508183+jcasnellie69@users.noreply.github.com>`. If CT 409's checkout doesn't have this set, `git commit` will fail with "Author identity unknown" — check `git config user.name/user.email` there before committing.
- `mkdocs` is not installed on the fileserver — never test-built locally; relied on reading source only. Check whether it's available on CT 409.

**Quirks specific to this environment (may or may not apply on CT 409):**
- File permission bits spuriously flip 644→755 on edited files in this working tree (observed on `mkdocs.yml`, `.github/copilot-instructions.md`) — `chmod 644` back before committing, or you'll ship spurious mode-only diffs.
- `git diff`/`git status` on `homelab-config` throw a CRLF warning on nearly every file — this is expected noise from the pre-existing repo-wide line-ending state (see Known Issues), not a new problem you caused.
- The user prefers reusable/durable setups over one-off fixes (e.g. asked for a real SSH keypair wired into repo secrets rather than an ad-hoc key just for this session) and wants changes logged rather than silently made — see `CHANGELOG.md`'s own mandate. Update it when you make nontrivial changes.
