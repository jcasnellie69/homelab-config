# Changelog

Human-readable, chronological log of significant changes, decisions, and incidents in this repo. This is the "what happened and why" index — for per-run raw evidence (command output, snapshots), see the timestamped artifacts under `/srv/artifacts/hc/` per `.github/copilot-instructions.md`.

Every agent or contributor making a nontrivial change should add an entry here (short, dated, links to the PR/commit) in the same change. This exists because that rule wasn't being followed — see the 2026-07-06 entry below.

## 2026-07-06

- **Established this CHANGELOG.** Root cause: `.github/copilot-instructions.md` has required an evidence artifact per change since inception, but automated agents (see Jules entry below) never produced one, and there was no single chronological index — so tracing "where did this diagram/config/decision come from" required manually excavating git history, `.recycle/`, and untracked working-tree files across two repos. Going forward, agents must update this file for any nontrivial change, not just drop an artifact in `/srv/artifacts/hc/`.
- **Closed 68 stale `google-labs-jules[bot]` PRs** (#41–#108, opened daily 2026-05-18 → 2026-07-06). Jules was re-attempting the same one-line `navigation.path` breadcrumb config change every day without ever landing it — `gemini-code-assist`/Copilot reviewers flagged the same issue each time (a duplicated `.Jules/palette.md` log entry), Jules never addressed it, and the loop restarted from scratch the next day instead of iterating. The companion repo `network-inventory` had the identical pattern (67 PRs, daily search-shortcut attempts with an unfixed modifier-key/contenteditable bug) — also closed.
- **Enabled `navigation.path` (breadcrumbs) by hand** in `mkdocs.yml` — the exact change Jules kept failing to land (`e39ff7f`).
- **Recovered and published the "Signal Archaeology" network inventory report** (`6c1f6db`): a MOKERLINK 12-port switch + Pi-hole DNS correlation report and companion VLAN topology SVG. These existed only as an untracked `docs/files.zip` plus stray `docs/network_signal_archaeology_v2.png` / `_v3.png` / `homelab_vlan_topology.svg` in the working tree — never committed. Promoted the best version (v3) to `docs/img/`, added `docs/network-signal-archaeology.md`, wired into the MkDocs nav.
- **Discovered `687d345` ("Add homelab reporting pipeline and CI/workflows", 2026-06-07, jcasnellie69) was never merged to `main`.** This commit — and the six workflow files that came with it — is the actual reporting pipeline described in `docs/REPORTING_HISTORY.md`. Because it sat unmerged, `main` has had **zero GitHub Actions workflows** this whole time, meaning the pipeline never ran on schedule regardless of whether the on-host scripts worked.
- **Found two competing reporting pipelines** in the unmerged work:
  - `homelab-inventory-health.yml` (`scripts/hc/`, `scripts/inventory/`, `scripts/publish/`) — the intended one per `REPORTING_HISTORY.md`, requires a self-hosted runner labeled `homelab` (none registered yet).
  - `reporting.yml` (`scripts/reporting/`) — an earlier/experimental stub that runs on GitHub-hosted runners, which can't reach the homelab LAN; it would capture the ephemeral Actions runner's own environment instead of real homelab state, then auto-commit that noise into `docs/`. `REPORTING_HISTORY.md` explicitly calls this drift out. Not yet removed — flagged for a decision.
- **Found `auto-stage-lint.yml`**: hourly, GitHub-hosted, runs `git add -A` + auto-commit + auto-push across the entire repo with no review. Very likely the origin of the earlier 90,432-file CRLF-flip working-tree state and the repo's multi-tool `skills/` sprawl (`.adal/`, `.agents/`, `.claude/`, `.codebuddy/`, ... one copy per AI tool). Not yet merged to `main`; needs a decision before it's turned loose on a schedule.
- Fixed a broken GitHub Pages link in the sibling `network-inventory` README (pointed at `jcasnellie.github.io`, missing the `69` — real host is `jcasnellie69.github.io`).

## 2026-06-07

- `687d345` — Added the reporting pipeline: inventory/health collectors, publish script, SSH-based remote orchestrator, two GitHub Actions workflows, devcontainer, dependabot config, `REPORTING.md`/`REPORTING_HISTORY.md`. Committed to a feature branch, never merged (see 2026-07-06 above).

## 2026-04-25 – 2026-04-26

- `scripts/reporting/*.sh` and `scripts/hc/`, `scripts/inventory/`, `scripts/publish/` scripts written (two parallel implementations — see 2026-07-06 finding).
- `docs/REPORTING_HISTORY.md` written as "the authoritative history from this point forward" after the repo had already been through "several direction changes and edits (some accidental)" — i.e., this same drift problem existed before today.

## 2026-05-18 → 2026-07-06 (ongoing until closed)

- `google-labs-jules[bot]` opened one PR per day (68 total, #41–#108) attempting the same MkDocs breadcrumb change. See 2026-07-06 closure entry above.

## 2026-02-15

- Copilot instructions set up for this repo (issue #2, closed).
