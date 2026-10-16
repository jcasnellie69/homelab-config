D080926 | CHG-OPNSENSE-GATE2-001 | Gate 2 IaC written (not yet executed);
VLAN-10 origin investigation closed as unresolved-but-benign; two fleet
reliability issues filed (.recycle corruption, codex silent self-update) | JC
| ct409+alpha

## Status for the next session

**Branch:** `feat/opnsense-staged-deployment`, uncommitted changes present —
see "Uncommitted state" below. Nothing has been pushed since PR #128.

**VM 401** (`opnsense-alpha`) is still `stopped`, `onboot: 0`, only `net0` on
`vmbr0` — unchanged all session. **Nothing live has been mutated.** `vmbr1`/
`vmbr2` do not exist yet on alpha. The Gate 2 playbook is written,
syntax-checked, and dry-run-verified (safe no-op without credentials), but
has never been run with real Proxmox API credentials — that's the very next
action, gated on the operator supplying `PVE_API_TOKEN_SECRET` themselves
(deliberately not extracted from Semaphore's Key Store by the assistant this
session, consistent with the credential-handling boundary from the PR #128
work).

## 1. VLAN-10 origin investigation — closed, unresolved-but-benign

Long forensic thread chasing why alpha's `vmbr0`/`nic0`/`TE10` had
undocumented `bridge-vlan-aware yes` + `bridge-vids 10` live, contradicting
the docs' old "flat VLAN 1" baseline.

**Findings:**
- `/etc/network/interfaces` and the (empty) `/etc/network/interfaces.d/sdn`
  drop-in were both written at the identical second — `2026-06-14
  06:49:08 UTC` — the signature of a Proxmox SDN apply (GUI or internal
  mechanism), not a manual text edit.
- Checked every Codex session transcript on both `pve-ansible` (CT409) and
  `alpha` itself (`/root/.codex/sessions/`) for activity bracketing that
  timestamp. **No session, on either host, has any logged activity at that
  exact moment.** The nearest session on `alpha` (`019ec4f4`, starting
  03:07:15 EDT / 18 min later) is entirely Netdata/netflow monitoring work,
  unrelated.
- VLAN `10` is not arbitrary — it exactly matches the "Management" VLAN ID
  already reserved in `docs/opnsense-staged-deployment.md`'s candidate
  segment table, so whatever applied it was consistent with the documented
  plan, not a rogue/hostile change.
- Operator confirmed (2026-08-01) the timing lines up with intentional
  ansible/collection scaffolding work from that period (initial OPNsense
  collection installs, Semaphore workflow seeding) — not an accident.
- Could not check `docker` (`192.168.4.76`) or `fileserver` (`192.168.4.60`)
  local `.codex` session histories — no working SSH credential to either
  host from `alpha` or CT409 (`Permission denied`, `Too many authentication
  failures`). This remains the one unchecked lead if anyone wants to pick it
  back up; operator has direct access to both.
- Evidence preserved: `/root/codex-sessions-opnsense-D080126T062434.tgz` on
  CT409 (full local `.codex` session history backup, includes the two npm
  debug logs referenced in §3 below).

**Conclusion accepted by operator:** treat as resolved-enough. Not a
showstopper for Gate 2.

## 2. `.recycle/` merge-conflict corruption — Issue #134 filed

While checking `.recycle/docs/vlan-topology.md` as a possible (but ultimately
unreliable) source for the VLAN-10 investigation, found it cites an artifact
(`D122225T0153/pve_interfaces.txt`) that has **unresolved git merge-conflict
markers committed directly into its content**, and that the artifact is
actually scoped to the `pve` node, not `alpha` (mis-attribution). A repo-wide
check found this isn't isolated: **525 files under `.recycle/` contain
literal `<<<<<<< HEAD` conflict markers** (318 in `artifacts/`, 207 in
`.agents/`), present on both `main` and this branch — baseline repo state,
not introduced here.

Filed as [Issue #134](https://github.com/jcasnellie69/homelab-config/issues/134).
Not actioned — per standing orders nothing in `.recycle` gets deleted
(counts as logs/backups); needs a resolve-in-place-vs-flag decision later,
and ties into the operator's separately-stated intent to eventually move
artifact-related content out of `.recycle`.

## 3. `codex` CLI silent self-update — Issue #137 filed

Root-caused why `codex` returned "command not found" on `alpha`, the
`docker` VM, and `fileserver` (operator-confirmed on all three).

**Root cause:** `codex` performs an unpinned `npm install --global
@openai/codex` on launch when a newer version exists on the registry. npm's
own upgrade mechanism retires the prior install to hidden temp paths
(`codex` → `.codex-<random>`, `@openai/codex` → `@openai/.codex-<random>`)
before placing the new version — and reports `exit 0` / "info ok" even when
the canonical `/usr/local/bin/codex` symlink never gets recreated. Confirmed
via `/root/.npm/_logs/` on alpha: two separate occurrences (2026-06-14 and
2026-07-30), same retire-without-cleanup pattern both times. No cron/systemd
timer is involved — purely triggered by someone running `codex` while a
newer version exists.

Filed as [Issue #137](https://github.com/jcasnellie69/homelab-config/issues/137).
Operator wants to think about a bigger-picture direction before deciding the
fix — not actioned yet, "being diligent" (manually re-checking `command -v
codex`) in the meantime.

## 4. CT409 provisioning evidence captured

The container's original creation log (template, disk UUID, all three SSH
host key fingerprints) only existed in the Proxmox UI's Notes field for CT
409 — nowhere in the repo. Captured verbatim plus a key-facts table in
`docs/session-logs/20260803-ct409-provisioning-evidence.md`, specifically so
the SSH host key fingerprints are available for future drift/MITM checking.

## 5. OPNsense Gate 2: topology confirmed, deviated from the original plan, IaC written

**Physical work done by the operator:** SFP cabling connected for alpha
`nic2` and `nic3`. Link confirmed up on both (10000Mb/s). MAC addresses
cross-checked against the existing port-map doc and matched exactly:
`nic2` = `38:05:25:33:ED:67` (`TE7`), `nic3` = `38:05:25:33:ED:68` (`TE12`).
`nic1`'s MAC (`38:05:25:33:ED:65`) recorded for the first time — not
previously documented, not in use for this plan. AT&T circuit confirmed
negotiating 10G full-duplex on the `nic2` path.

**Plan deviation (operator-directed):** the original single-`vmbr1`-trunk
Gate 2 plan (one bridge carrying all future VLANs) is superseded by a
two-bridge split:

| NIC | Bridge | Physical path | Role |
| --- | --- | --- | --- |
| `net0` | `vmbr0` | alpha `nic0` | Temporary management/staging access only |
| `net1` | `vmbr1` | alpha `nic2` ← AT&T 10G | Real WAN uplink |
| `net2` | `vmbr2` | alpha `nic3` ← MokerLink `TE12` | LAN-side, VLAN `80` test first |

This also resolves the previously-unreconciled "OPNsense SFPs are isolated"
note from 2026-07-28 — there's no separate physical OPNsense hardware; it's
alpha's own `nic2`/`nic3` that are isolated from each other and from
`vmbr0`. Intent stated by the operator: stage OPNsense with a **real** WAN
uplink so it's fully provable and ready to actually take over as the live
gateway once validated (operator is now ~95% inclined to put the household
eero mesh into bridge mode) — this is provisioning, not cutover. The live
default gateway (`192.168.4.1`) is not moving as part of this; that stays
gated behind the existing Rollback Principles in
`docs/opnsense-vlan-port-map.md`.

`docs/opnsense-vlan-port-map.md` updated in place: new "Gate 2 Topology"
section with the MAC-verified table, old single-trunk proposal marked
superseded (kept for history), Gate 2 rollout checklist rewritten for the
two-bridge shape.

**IaC written** (new files, following the existing `opnsense-alpha-onboard.yml`
credential-resolution and check-mode-gated pattern):

- `deploy/ansible/group_vars/future_opnsense.yml` — added
  `opnsense_gate2_check_mode` (defaults `true`), `opnsense_wan_bridge`/`_nic`,
  `opnsense_lan_test_bridge`/`_nic`/`_vlan`, `opnsense_gate2_vm_net`.
- `deploy/ansible/playbooks/tasks/create-opnsense-gate2-bridges.yml` — stages
  `vmbr1` (plain, no VLAN awareness, WAN) and `vmbr2` (VLAN-aware,
  `bridge_vids: 80`) via `community.proxmox.proxmox_node_network`, then
  `state: apply` to activate (only when check mode is off).
- `deploy/ansible/playbooks/tasks/attach-opnsense-gate2-nics.yml` — attaches
  `net1`/`net2` to VM 401 via `community.proxmox.proxmox_kvm`
  (`update: true`, `update_unsafe: true` — required because the module
  blocks `net` updates by default).
- `deploy/ansible/playbooks/opnsense-gate2-network.yml` — main playbook;
  same credential-resolution pre_tasks pattern as `opnsense-alpha-onboard.yml`;
  asserts VM 401 is still stopped and stage-safe on `vmbr0` before allowing
  any Gate 2 mutation; includes the two task files above; reports next
  steps (boot via console, configure OPNsense LAN/DHCP only on `net2`, never
  `net0`).

**Verified this session:** `--syntax-check` clean; `--check` dry run without
credentials correctly no-ops past the plan-report task (confirms the
credential-presence gate holds, nothing mutates when creds are absent).
**Not yet verified:** a real run against live Proxmox API credentials — this
is the actual next step, intentionally left for the operator to trigger
(see "Immediate next actions" below) rather than the assistant extracting
the token secret from Semaphore's Key Store.

**Not done / explicitly flagged, not forgotten:**
- MokerLink switch-side config (`TE7` WAN passthrough, `TE12` tagged VLAN 80
  only) — manual, out-of-band, not verified or executed by any playbook.
  Confirm this is done before running Gate 2 with mutation enabled.
- Task #6 from the earlier plan ("validate onboard pipeline end-to-end
  against VM 401 via Semaphore") is effectively superseded/absorbed by this
  Gate 2 work rather than done as originally scoped — the Gate 2 playbook
  reuses and extends the same credential/assert pattern, but hasn't been
  wired into Semaphore yet (still a plain `ansible-playbook` CLI run for
  now; operator can request Semaphore wiring separately).
- Booting VM 401 / running the OPNsense installer — not started.

## Uncommitted state as of this session (`feat/opnsense-staged-deployment`)

```text
 M deploy/ansible/group_vars/future_opnsense.yml
 M docs/opnsense-vlan-port-map.md
?? artifacts/decommissioned-checkouts/          (pre-existing, unrelated clutter — not part of this change)
?? deploy/ansible/playbooks/opnsense-gate2-network.yml
?? deploy/ansible/playbooks/tasks/attach-opnsense-gate2-nics.yml
?? deploy/ansible/playbooks/tasks/create-opnsense-gate2-bridges.yml
?? docs/session-logs/20260726-ct409-fail2ban-pihole-swap.md
?? docs/session-logs/20260728-pve-quorum-disk-and-opnsense-sync.md
?? docs/session-logs/20260803-ct409-provisioning-evidence.md
?? docs/session-logs/20260809-opnsense-gate2-prep-and-fleet-issues.md   (this file)
```

None of this has been committed yet — operator has not asked for a commit
this session. `artifacts/decommissioned-checkouts/` predates this session's
work and is unrelated; don't bundle it into an OPNsense commit.

## Immediate next actions (in order)

1. Confirm MokerLink `TE7`/`TE12` switch config matches the Gate 2 Topology
   table (manual, operator).
2. Run the Gate 2 playbook for real:
   ```bash
   cd /mnt/repos/homelab-config/deploy/ansible
   export PVE_API_USER='ansible@pve'
   export PVE_API_TOKEN_ID='opnsense-automation'
   read -rs PVE_API_TOKEN_SECRET && export PVE_API_TOKEN_SECRET
   ansible-playbook playbooks/opnsense-gate2-network.yml --check -e opnsense_gate2_check_mode=true
   ansible-playbook playbooks/opnsense-gate2-network.yml -e opnsense_gate2_check_mode=false
   ```
3. Boot VM 401 via the Proxmox console, run the OPNsense installer.
4. Configure OPNsense's LAN-side DHCP only on the VLAN 80 interface
   (`net2`) — never on `net0` — to avoid repeating the earlier DHCP-leak
   incident that forced an emergency shutdown of VM 401 the last time it was
   booted.
5. Test DHCP/firewall behavior confined to VLAN 80 only, per the existing
   Gate 2 checklist in `docs/opnsense-vlan-port-map.md`.
6. Once the above is stable, commit this session's changes (docs + new
   Ansible files) as a follow-up commit on `feat/opnsense-staged-deployment`.
