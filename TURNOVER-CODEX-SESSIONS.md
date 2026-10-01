# TURNOVER-CODEX-SESSIONS.md

D070726 | CHG-AGENT-MOVE-002 | turnover of 6 Codex CLI sessions on CT409,
cross-referenced against git log and live state | JC | ct409

This document inventories the Codex CLI session transcripts found at
`~/.codex/sessions/` on CT 409 (`pve-ansible`). Each section was drafted by
an independent research pass over one session's JSONL transcript, then
cross-referenced against `git log`/`git show` in `/mnt/repos/homelab-config`
and `/mnt/repos/network-inventory`, and against live Proxmox/VM state
reached read-only via `ssh root@192.168.4.10` (alpha) and, for the Docker VM,
`qm guest exec 109`. It complements `TURNOVER-CC-FILESERVER.md` (a separate
handoff document from a retired fileserver-hosted Claude Code install) by
covering work done in CT 409-side Codex sessions that the fileserver session
had no visibility into.

---

## Session: 2026-05-28T03:28:34Z (`019e6ca0-7097-7f92-b08d-2523e33c2792`)

**Topic:** Inventory of pve-ansible, Semaphore recovery, staged OPNsense automation buildout — ends mid-task on a blocked SSH passphrase.

**Work completed:**
- Reset Semaphore admin password; cloned both `homelab-config` and
  `network-inventory` into `/mnt/repos/`; restored an Ansible scaffold from
  `.recycle/`; wrote OPNsense preflight/onboard playbooks and the API-token
  bootstrap script (not executed — SSH blocked); seeded 4 Semaphore
  templates.

**Work in-flight or abandoned:**
- SSH passphrase prompt left hanging; NFS mount never resolved; Docker/
  Portainer LXC identification incomplete.

**Decisions made:**
- OPNsense VM creation stays check-mode only; `vmbr0` untouched; keep
  `netbox` hostname, rename only the inventory group to `ipam`; Proxmox API
  token lives in Semaphore's key store, never in git.

**Loose ends:**
- Nothing from this session was ever committed.

**Verification notes:**
All named files CORROBORATED present on disk today. **Contradicted:** the
session's closing tone implies delivery, but none of it was committed —
still untracked 40+ days later. The Proxmox-API credential bootstrap this
session left blocked was actually completed in a *later* session (05-30),
not this one — a misattribution risk if this session is read in isolation.

---

## Session: 2026-05-28T06:21:44Z, resumed 2026-05-30 (`019e6d3e-fc01-7470-8c62-6bf999222d39`)

**Topic:** OPNsense staged deployment continuation — discovery, ISO acquisition, Semaphore credential-injection fix, VM 401 shell creation.

**Work completed:**
- Downloaded/verified OPNsense 26.1.6 ISO; fixed Semaphore secret-injection
  via Key Store binding; corrected the Proxmox node name; installed
  `community.proxmox` for the Semaphore service account; after 4 sequential
  Semaphore/API failures (missing `proxmoxer`, version too old, disk-size
  string, missing `SDN.Use` ACL), created VM 401 directly via SSH
  `qm create`, bypassing the repaired pipeline.

**Work in-flight or abandoned:**
- Semaphore/API-driven creation never worked end-to-end; the `SDN.Use` gap
  on the Proxmox API token was left unfixed deliberately (to avoid an
  unapproved ACL change) — still blocks any future Semaphore-driven
  VM/network create.

**Decisions made:**
- Non-destructive posture maintained throughout; accepted bypassing
  Semaphore for the actual VM creation.

**Loose ends:**
- This is the direct source of `docs/session-logs/20260528-062237-BUILD-HC-AUTOMATION.md`.
- Session log file was reused/edited across the two-day gap rather than
  starting a new log for the 05-30 continuation.

**Verification notes:**
CORROBORATED as the direct source of the session-log doc — edits trace to
specific `apply_patch` calls in-session, and the final content matches the
transcript's closing summary. VM 401 config CORROBORATED live, byte-for-byte
against the doc. Network non-mutation CORROBORATED. One real discrepancy:
doc/transcript show `onboot: 1` at session close (05-30); live state showed
`onboot: 0` as of this triage — resolved by the 06-03 session's "Gate 1"
(see below), not a transcript inaccuracy.

---

## Session: 2026-06-03T07:23:19Z, resumed through 06-08 (`019e8c5d-82ac-7380-8087-e87d20b14916`)

**Topic:** Docker-mcp install/validation on VM 109, then a multi-day OPNsense/VLAN network-migration staging effort.

**Work completed:**
- Installed & validated `docker-mcp` v0.42.2 system-wide only on VM 109
  (matches `/root/docker-mcp-alpha-validation.md` verbatim — every claim in
  that doc is corroborated by tool-call evidence); brought two 10G SFP links
  online with iperf3 tests; fixed Docker VM DHCP/gateway; enabled SNMP on
  the MokerLink switch; produced the VLAN/port-map planning doc; "Gate 1" —
  set VM 401 `onboot: 0` and stopped it (explains the discrepancy flagged in
  the prior session).

**Work in-flight or abandoned:**
- Session's final action was `systemctl reboot` on **alpha itself** (for
  IOMMU/VFIO Wi-Fi passthrough to VM 401) — **no post-reboot confirmation
  exists in the transcript.** OPNsense web UI still unreachable; full
  5-step VLAN cutover not executed; Terraform provider deferred.

**Decisions made:**
- Treat live Proxmox/cluster state as source of truth over stale resume
  notes; install docker-mcp only to the system-wide plugin path; keep VM 401
  stopped/`onboot: 0` pending further validation.

**Loose ends:**
- Alpha reboot outcome unverified within this transcript. OPNsense VM 401
  web UI access still unresolved.

**Verification notes:**
Docker-mcp doc fully CORROBORATED, including the explicit check that only
the system-wide path was ever targeted — matches this triage's independent
live verification (§ docker-mcp status, below). Alpha reboot outcome is
UNVERIFIABLE from this transcript alone; worth a live check given it
involved GRUB/initramfs changes on the physical host (subsequent sessions
and current cluster-quorate state suggest it completed without incident,
but this was not independently re-verified as part of this document).

---

## Session: 2026-06-09T00:06:20Z (`019ea9b3-9a54-7ab2-8b35-48e8af6a2353`)

**Topic:** Single request to generate an `AGENTS.md` contributor guide for `/root` — abandoned before any work began (8-line transcript, no tool calls, no reply).

**Verification notes:**
CORROBORATED as abandoned — `/root/AGENTS.md` does not exist. **This is not**
the "Linux MCP Runtime" session referenced by `TURNOVER-CC-FILESERVER.md`.

---

## Session: 2026-06-14T02:18:40Z (`019ec3ec-8cfc-73d2-b1b6-ff57dc2da806`)

**Topic:** GitKraken MCP registration for Codex CLI on this host, then a broad live-infra cleanup pass (Telegraf/InfluxDB, monitoring-plugins, Netdata, PDM TLS, NetBox boot noise).

**Work completed:**
- Registered the `gitkraken` MCP server in `/root/.codex/config.toml`;
  disabled stale Telegraf on `prometheus` LXC 203 (dead InfluxDB target);
  installed `monitoring-plugins` on LXC 203 and VM 109; disabled unneeded
  `rpcbind` on both; fixed Proxmox Datacenter Manager TLS fingerprint
  mismatches and added bravo as a remote; cleaned NetBox boot noise
  (IPv6 SLAAC switch).

**Loose ends:**
- Inventory drift never fixed in `deploy/ansible/inventory/lab/hosts.yml`
  (`prometheus` still listed at the stale `.132`; live address is `.210`).
  Telegraf simply off, no replacement metrics sink.

**Verification notes:**
"Linux MCP Runtime" — **the literal phrase appears nowhere** in either the
06-09 or 06-14 transcripts, nor in `gk --help` output; it appears to be the
prior (fileserver) Claude session's own paraphrase, not a real named
component. GitKraken CLI setup happened **on this host**, not the Docker VM
as the prior turnover implied (partial contradiction). GitKraken CLI is
*separately* present on VM 109 too (`/root/.local/share/GitKrakenCLI/gk`),
unrelated to the Codex MCP wiring — provenance unclear. Notable oddity:
`/usr/bin/gk`'s mtime (2026-06-29) is 15 days *after* this session
registered it, suggesting an auto-update replaced the binary later; not
fully explained by either transcript. Telegraf/rpcbind disabled state:
CORROBORATED live.

---

## Session: 2026-07-01T23:45:16Z → 2026-07-02T07:23:32Z (`019f2012-94f2-7293-9895-c9c6cb8e7142`)

**Topic:** GitKraken MCP repair, then a live disk-remediation run on `homepage`/`watchyourlan`, then building the repo-health-curator system end to end.

**Work completed:**
- Fixed GitKraken auth; ran `disk-remediation.yml` live (tracking ID
  `disk-20260702T055850`, matches `artifacts/remediation_log.md` and
  `docs/runbooks/disk_triage_insights.md` verbatim — 0 failures); built and
  enabled the read-only scan agent; designed and installed the full curator
  system but **deliberately left its timer disabled**, ending on an explicit
  instruction to the human: install and authenticate `gh` before the
  curator can push its first checkpoint.

**Decisions made:**
- Checkpoint commits restricted to `repo-health/*` branches producing draft
  PRs, never direct `main` pushes, no force-push/auto-merge. Scheduling via
  systemd timer, not cron. Scan scope narrowed to `/home,/mnt/repos,/srv`
  (`/root` excluded).

**Loose ends:**
- `gh` still absent on CT 409 → curator timer stays disabled until a human
  installs/authenticates it (per operator instruction, this gate is not to
  be opened without explicit sign-off).

**Verification notes:**
This is definitively the session that built everything landed in this
change (`CHG-REPO-HEALTH-LAND-001`) — every named file traces to this
transcript. The enabled-scan/disabled-curator split is fully explained and
still holds as of this triage: `gh` is still not installed on this node,
`repository-scan-agent.timer` is enabled with 119+ recorded runs,
`repository-curator-agent.timer` is disabled with an empty journal (never
run). Nothing from this session was committed prior to this change,
consistent with the ~20 files found untracked.

---

## Docker-mcp status on VM 109 (192.168.4.76) — independently re-verified

Direct SSH to `.76` is closed (`Permission denied (publickey,password)`).
Verified read-only via Proxmox QEMU guest agent through alpha
(`qm guest exec 109`):

- `/root/.docker/cli-plugins/docker-mcp` → does not exist
- `/usr/local/lib/docker/cli-plugins/docker-mcp` → exists, `-rwxr-xr-x`,
  45,564,088 bytes, dated Jun 3 07:25
- `docker mcp version` → `v0.42.2`

Installed and functional, system-wide only — matches
`docker-mcp-alpha-validation.md` and the 06-03 session exactly.
