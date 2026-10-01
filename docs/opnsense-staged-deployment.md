# OPNsense Staged Deployment

## Status (D072826, CHG-OPNSENSE-SYNC-001)

- **Gate 1 (safe VM staging): complete.** VM `401` exists on alpha, stopped,
  `onboot: 0`, only `net0` on `vmbr0` — verified live, matches the expected
  stage-safe shape asserted by `playbooks/opnsense-alpha-onboard.yml`.
- **Gates 2-4 (trunk test, DHCP/DNS migration, client segment moves): not
  started.** `vmbr1` does not exist. No switch port has been retagged. No
  DHCP/DNS traffic has moved off Pi-hole. See `docs/opnsense-vlan-port-map.md`
  for the gate definitions.
- **OPNsense itself has never been installed** on VM 401 — it's a shell VM
  with the ISO attached, never booted through the installer.
- The Proxmox API token bootstrap (`docs/proxmox-api-token-bootstrap.md`) is
  done; the automation pipeline (`playbooks/opnsense-alpha-onboard.yml`) is
  fixed and validated as of this change (`SDN.Use` ACL added, module versions
  confirmed) — see that doc's Status section for detail.
- New physical-topology fact from the operator, not yet reconciled with the
  plan below: OPNsense's own SFP ports are isolated — one to the AT&T 5G
  port, one to a separate air-gapped switch. See
  `docs/opnsense-vlan-port-map.md`'s "New Physical Fact" note.
- This status section exists so the next session doesn't have to re-derive
  state from `TURNOVER-CODEX-SESSIONS.md` transcripts again.

## Current Baseline

- Proxmox node `alpha` is the live management endpoint at `192.168.4.10`.
- `vmbr0` is the active management bridge and must remain unchanged.
- Current network operation is flat `192.168.4.0/24` on default VLAN 1.
- Existing DNS dependency is Pi-hole at `192.168.4.208`.
- NetBox is an intentional LXC service at `192.168.4.114` and should remain a
  future source-of-truth candidate. The inventory group should avoid colliding
  with the `netbox` host name.
- Historical planning requires a future `vmbr1` VLAN trunk with no IP address,
  but the first trunk path is now scoped to alpha `nic2` on MokerLink `TE7`.
  Alpha `nic3` on `TE12` remains spare or second-stage trunk capacity.

## Stage 1 Scope

Maintain the staged OPNsense VM shell on Proxmox without changing routing, DHCP,
DNS, or the active management bridge.

Planned VM:

| Field | Value |
| --- | --- |
| Name | `opnsense-alpha` |
| VMID | `401` |
| Current status | `stopped` |
| On boot | disabled |
| CPU | `1` socket, `2` cores |
| RAM | `4096` MB |
| Disk | `local-lvm`, `32G` |
| ISO | `local:iso/OPNsense.iso` |
| Stage 1 NIC | `virtio,bridge=vmbr0` |
| Future trunk | `vmbr1` over alpha `nic2` / MokerLink `TE7`, not created or attached until approved |

## Semaphore Jobs

Semaphore project `1` is seeded to use `/mnt/repos/homelab-config/deploy/ansible`
as a local repository.

Configured templates:

| Template | Playbook | Purpose |
| --- | --- | --- |
| OPNsense preflight | `playbooks/opnsense-preflight.yml` | Non-destructive reachability and assumptions check |
| Lab connectivity | `playbooks/lab-connectivity.yml` | Validate known management and service endpoints |
| Proxmox discovery | `playbooks/proxmox-readonly-discovery.yml` | Read-only host/interface discovery |
| OPNsense VM stage | `playbooks/opnsense-alpha-onboard.yml` | Create/update VM shell, check-mode by default |

Environment variables needed for Proxmox mutation:

- `PVE_API_USER`
- `PVE_API_TOKEN_ID`
- `PVE_API_TOKEN_SECRET`

Do not disable `opnsense_check_mode` until the ISO exists and Proxmox API
credentials are available.

The `OPNsense - preflight` template has been run successfully from Semaphore.

The onboarding playbook is resume-safe for VMID `401`: if the VM already exists,
it validates that the VM is stopped, `onboot` is disabled, and only `net0` is
attached to `vmbr0`. It refuses mutation if unexpected NICs or bridges are
present.

## Required Validation Before Network Changes

Run on `alpha` before creating or attaching `vmbr1`:

```bash
pct list
ip -br link
bridge link show
bridge vlan show
for nic in nic2 nic3; do
  echo "=== $nic ==="
  ethtool "$nic" | egrep 'Speed|Duplex|Link detected'
done
```

Expected result:

- `nic0` remains the management path for `vmbr0`.
- `nic2` remains linked at 10G and maps to MokerLink `TE7`.
- `nic3` remains linked at 10G and maps to MokerLink `TE12`.
- `vmbr1` is created only after the `TE7` test trunk is approved.
- `vmbr1` has no IP address.

Current detailed VLAN and switch-port planning lives in
`docs/opnsense-vlan-port-map.md`.

## DHCP and DNS Transition

Stage 1 does not move DHCP or DNS. Keep the current gateway and Pi-hole online.

Later DHCP/DNS transition order:

1. Export current Pi-hole DHCP/static reservation data.
2. Capture `network-inventory` critical and high-priority clients.
3. Seed OPNsense static mappings from the authoritative inventory.
4. Enable OPNsense DHCP on a test VLAN or isolated interface first.
5. Move one low-risk client segment before moving management or core infra.
6. Keep Pi-hole as DNS until OPNsense DHCP behavior is proven.

## Candidate Segments

Candidate VLAN IDs are now assigned for planning in
`docs/opnsense-vlan-port-map.md`. They are not approved for live switch or
Proxmox application yet.

| VLAN | Segment | Candidate subnet | Timing |
| ---: | --- | --- | --- |
| `1` | Legacy LAN | `192.168.4.0/24` | Remains active during early stages |
| `10` | Management | `192.168.10.0/24` | Late cutover only |
| `20` | Core infra | `192.168.20.0/24` | After DHCP/DNS import is proven |
| `30` | Services | `192.168.30.0/24` | After core infra path is proven |
| `40` | IoT | `192.168.40.0/24` | After discovery/firewall rules are defined |
| `50` | Cameras/security | `192.168.50.0/24` | After recorder/hub dependencies are mapped |
| `60` | Clients | `192.168.60.0/24` | After Wi-Fi VLAN support is confirmed |
| `70` | Guest | `192.168.70.0/24` | Low-risk client-style segment if supported |
| `80` | Lab/test | `192.168.80.0/24` | First OPNsense DHCP/firewall test VLAN |

## Rollback Checks

Rollback is "do nothing to the live network" for stage 1. If VM work causes
unexpected issues, stop the VM and confirm:

- `192.168.4.10:8006` Proxmox UI is reachable.
- `192.168.4.10:22` SSH is reachable.
- `192.168.4.208:53` and `192.168.4.208:80` Pi-hole is reachable.
- Default gateway remains `192.168.4.1`.

## Known Blockers

- Proxmox API credentials are not present in this repo.
- OPNsense API credentials do not exist until after install and API enablement.
- `vmbr1` must not be built until the `TE7` test trunk is approved.
- Candidate VLAN subnets must be checked for collisions before use.
- MokerLink switch config should be exported or screenshotted before any port
  mode changes.
