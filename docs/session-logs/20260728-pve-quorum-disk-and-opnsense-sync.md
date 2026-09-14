D072826 | CHG-OPNSENSE-SYNC-001 | OPNsense backlog landed + automation pipeline
fixed; pve-node cluster quorum loss and disk-full incident (unrelated,
surfaced mid-task) diagnosed and remediated | JC | ct409+alpha+pve+charlie

## 1. OPNsense backlog: repo sync + automation pipeline fix

Followed the plan at the time (see conversation) to pick the OPNsense staged-
deployment effort back up after ~2 months untracked. Full findings and
rationale are captured in the commit message and in the docs themselves
(`docs/opnsense-staged-deployment.md` Status section,
`docs/proxmox-api-token-bootstrap.md` Status section). Summary:

- Discovered `main` has no `deploy/ansible/` tree at all — the shared Ansible
  control-node scaffold (`ansible.cfg`, `inventory/`, `group_vars/`,
  `host_vars/`, `roles/`) only exists on `feat/repo-health-curator`
  (committed there, unpushed). Re-based `feat/opnsense-staged-deployment` onto
  that branch instead of `main` for this reason — flagged to the user as a
  deviation from the original plan (branching off `main`), not silently done.
- Committed the ~2-month-old untracked OPNsense docs/Ansible backlog
  (commit `c00a755` on `feat/opnsense-staged-deployment`), correcting stale
  claims (resolved SSH blocker, missing `SDN.Use`) and fixing
  `deploy/ansible/inventory/lab/hosts.yml` prometheus drift (`.132`/vmid `103`
  → live `.210`/vmid `203`, verified via `pct exec 203 -- hostname -I` before
  changing). Commit locally only, not pushed (per operator's explicit choice).
- Added `SDN.Use` to the `HomelabOPNsenseAutomation` Proxmox role (operator
  approved) — see §2 below for why this took two attempts.
- Confirmed `community.proxmox` 1.5.0 and `proxmoxer` 2.3.0 are already
  installed and current on CT409 — no action needed.
- Still open: re-running `opnsense-alpha-onboard.yml` with real Proxmox API
  credentials to prove the pipeline works end-to-end against the existing VM
  401 without mutating it. Deliberately did not extract the token secret from
  Semaphore's database myself (hit this boundary twice already this session)
  — needs the operator to either run it via Semaphore directly or hand me
  `PVE_API_TOKEN_SECRET` out-of-band.
- Confirmed by operator: OPNsense's own SFP ports are physically isolated —
  one to the AT&T 5G port, one to an air-gapped switch. Captured as a flagged,
  not-yet-integrated note in `docs/opnsense-vlan-port-map.md` since it doesn't
  fit the existing `vmbr1`/alpha-NIC trunk plan as written.
- No network/VM mutation happened as part of this: VM 401 remains stopped,
  `onboot: 0`; `vmbr1` was not created. Gates 2-4 (trunk test, DHCP/DNS
  migration, client segment moves) untouched, per operator's explicit scope
  answer earlier in the session.

## 2. Unrelated, surfaced mid-task: cluster quorum loss + pve-node disk-full

While attempting the `SDN.Use` role change, `pveum role modify` failed with
`no quorum!`. Investigation (all read-only until remediation was explicitly
approved):

- `pvecm status` on alpha showed only 1/3 nodes (itself); Charlie (`.30`) and
  the third node `pve` (`.249`) were both ARP-unreachable from alpha and from
  CT409. Switch management (`192.168.4.2`) stayed reachable throughout,
  ruling out a whole-switch failure.
- Operator confirmed this was expected/in-progress: physically working on
  OPNsense SFP cabling (plugging into the AT&T port), and had intentionally
  taken Charlie/Pi-hole down. Not an unplanned incident on that count.
- Per operator request, disabled Pi-hole DHCP (`pihole-FTL --config
  dhcp.active false`; backed up `pihole.toml.D072826T1926` first on LXC 115)
  and cleared its DHCP lease file (116 leases backed up to
  `dhcp.leases.D072826T1928`, then truncated) — done while Charlie/Pi-hole
  were reachable again, ahead of a DHCP handoff to OPNsense.
- Operator brought Charlie back up; cluster briefly showed 2/3 quorate, then
  the operator brought the third node (`pve`, `192.168.4.249`) up too — but
  quorum kept flapping (3/3 momentarily, then back to 1/3) even after all
  three nodes were pingable. `pve-cluster` (pmxcfs) journal on alpha showed
  repeated `[dcdb]`/`[status] members: 1/1428` drops right after briefly
  recovering.
- Operator flagged the `pve` node specifically as having "a space issue."
  Confirmed: `pve`'s root filesystem (`/dev/mapper/pve-root`, 110G) was at
  **100% used, 0 bytes available**. This is the actual root cause of the
  quorum flapping — pmxcfs cannot reliably sync cluster state with no disk
  space to write to (RRDC update errors visible in its journal throughout).
- Root cause of the full disk: `/var/lib/vz/dump/` held 80G across 50 real
  vzdump backup archives, oldest 2026-01-17, newest 2026-03-23 — **no backup
  has actually succeeded in over 4 months**. 145 of 195 total backup log
  entries were 185-byte stubs (fast failures), consistent with the backup job
  having been silently failing since the disk first filled, with old backups
  never rotating out because new ones never completed.
- Asked the operator explicitly before deleting anything (these are backup
  archives, not disposable logs). Operator chose: keep the newest 1-2 backups
  per VMID (109, 100, 102, 103, 104, 106, 107, 108, 110, 409), delete the
  rest. Removed 96 files (32 archives + matching `.log`/`.notes`), freeing
  59.6 GB. `df -h /` went from 100% (0 avail) to 48% (56G avail). Nothing
  backed up or archived before deletion — operator was informed of exactly
  what would be removed (per-VMID counts) before it happened and explicitly
  chose full deletion over a backup-first option.
- Cluster quorum confirmed stable (3/3, `Quorate: Yes`) twice, 5 seconds
  apart, after the disk fix. `SDN.Use` role modification then succeeded
  immediately.

**Follow-up not done, flagged for the operator:** the vzdump backup job on
`pve` is still broken (whatever schedules/runs it needs investigation — it's
been failing silently for 4+ months without alerting anyone). Freeing space
today does not fix that job; it will refill on the same trajectory unless the
underlying failure is found and fixed, and/or Netdata/alerting is extended to
cover that node's disk (it clearly wasn't, or this would have paged much
earlier the way the CT409 swap alert did).
