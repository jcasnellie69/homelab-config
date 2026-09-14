# OPNsense VLAN and Port Map

## Scope

This document refactors the OPNsense rollout around the current MokerLink 1
MAC table and the live Proxmox alpha interface state.

This is a planning document only. It does not authorize switch, bridge, gateway,
DHCP, DNS, WAN, or firewall cutover changes.

## Gate 2 Topology (D080926, reconciled and confirmed live)

Resolves the D072826 "New Physical Fact" note below: OPNsense doesn't have
its own physical SFPs — it's a VM on `alpha`, and what's isolated is alpha's
own `nic2`/`nic3` ports. Physical cabling is now connected and confirmed:

| Alpha NIC | MAC | Switch port | Link | Physical path | Role |
| --- | --- | --- | --- | --- | --- |
| `nic1` | `38:05:25:33:ED:65` | — | — | (recorded for completeness, not in use for this plan) | — |
| `nic0` | `38:05:25:33:ED:66` | `TE10` | up, 2500Mb/s | Management/VM/LXC path | `vmbr0`, unchanged, rollback path |
| `nic2` | `38:05:25:33:ED:67` | `TE7` | up, 10000Mb/s, confirmed AT&T negotiating 10G full-duplex | AT&T 10G circuit | `vmbr1` — real WAN uplink |
| `nic3` | `38:05:25:33:ED:68` | `TE12` | up, 10000Mb/s | MokerLink switch | `vmbr2` — LAN-side, VLAN 80 first |

Deviation from the original single-`vmbr1`-trunk plan further down this doc:
OPNsense VM `401` gets **three** NICs instead of two, splitting WAN and
LAN-test onto separate bridges instead of trunking both through one:

| OPNsense NIC | Proxmox bridge | Physical path | Purpose |
| --- | --- | --- | --- |
| `net0` | `vmbr0` | alpha `nic0` | Temporary management/staging access only |
| `net1` | `vmbr1` | alpha `nic2` ← AT&T 10G | Real WAN uplink |
| `net2` | `vmbr2` | alpha `nic3` ← MokerLink `TE12` | LAN-side, VLAN `80` test first, later segments after proven |

Intent: stage OPNsense with a real WAN uplink so it's fully provable and
ready to take over as the live gateway once validated — not just an
isolated lab test. This does **not** change the safety boundary in Rollback
Principles below: the live default gateway stays `192.168.4.1`, and no
client traffic moves until management, DNS/DHCP, and rollback checks are
explicitly satisfied. Attaching a real WAN here is provisioning, not
cutover.

The original `vmbr1`-only proposal (`bridge-vids 2-4094` trunk carrying all
future VLANs over a single `nic2` link) below is now superseded by the
two-bridge split above; kept in place for historical context on the
reasoning, not as the current plan.

### Original note (D072826, superseded by the above)

Operator reports OPNsense's own SFP ports are physically isolated from each
other: one goes to the AT&T 5G port (likely WAN uplink candidate), the other
connects to a separate air-gapped switch. This is distinct from the
`vmbr1`/alpha-`nic2`/`nic3` trunk plan below, which is about Proxmox host
NICs, not OPNsense's own interfaces — the two may need to be reconciled
before Gate 2 planning proceeds. Flagging here so it isn't lost; does not
change anything in Gates 0-4 below yet, and needs a live topology recheck
(which OPNsense NIC/SFP maps to which physical link) before any trunk/WAN
decisions are finalized.

## Current Facts

Current flat LAN:

| Item | Current value |
| --- | --- |
| LAN subnet | `192.168.4.0/24` |
| Current gateway | `192.168.4.1` |
| Current DNS/DHCP dependency | Pi-hole at `192.168.4.208` |
| Alpha management | `192.168.4.10` on `vmbr0` / `nic0` |
| Alpha SFP test address | `nic2` = `192.168.4.13/32` |
| Alpha SFP test address | `nic3` = `192.168.4.14/32` |
| OPNsense VM | VMID `401`, stopped, `onboot` disabled, currently staged on `vmbr0` only |
| Future Proxmox trunk bridge | `vmbr1`, not created yet |

Current MokerLink 1 learned-port evidence from 2026-06-07:

| Port | Learned count | Current interpretation |
| --- | ---: | --- |
| `TE1` | 20 | Dense downstream/access path; reconfirm before VLAN changes |
| `TE4` | 3 | Small access/downstream path; reconfirm before VLAN changes |
| `TE5` | 70 | Main dense Wi-Fi/downstream path; current gateway MAC is here |
| `TE7` | 1 | Alpha `nic2`, candidate first OPNsense trunk |
| `TE9` | 22 | Dense downstream/access path; reconfirm before VLAN changes |
| `TE10` | 12 | Alpha `vmbr0`/VM/LXC path plus `pve` node MACs; preserve as rollback path |
| `TE11` | 2 | Charlie host and Pi-hole LXC |
| `TE12` | 1 | Alpha `nic3`, spare or second-stage trunk |

No current dynamic entries were provided for `TE2`, `TE3`, `TE6`, or `TE8`.

Important current mappings:

| MAC | Port | Meaning |
| --- | --- | --- |
| `38:05:25:33:ED:66` | `TE10` | alpha `nic0` / `vmbr0` |
| `38:05:25:33:ED:67` | `TE7` | alpha `nic2` |
| `38:05:25:33:ED:68` | `TE12` | alpha `nic3` |
| `02:09:57:24:3E:E5` | `TE10` | Docker VM `109`, current reservation `192.168.4.76` |
| `BC:24:11:E6:D8:FA` | `TE10` | OPNsense VM `401` current stage NIC |
| `84:47:09:71:62:50` | `TE11` | Charlie host `vmbr0` |
| `BC:24:11:A4:42:81` | `TE11` | Pi-hole LXC `115` at `192.168.4.208` |

LLDP neighbor evidence from the MokerLink UI on 2026-06-07:

| Local port | Chassis ID | Port ID | System name | Current interpretation |
| --- | --- | --- | --- | --- |
| `TE1` | `30:29:2B:1A:92:E0` | `1` | `eero` | Eero/downstream path |
| `TE5` | `24:2D:6C:F7:3C:C0` | `4` | `eero` | Eero/downstream path; high blast radius |
| `TE7` | `38:05:25:33:ED:67` | `38:05:25:33:ED:67` | none | Alpha `nic2` direct LLDP advertisement |
| `TE9` | `40:47:5E:F0:68:60` | `1` | `eero` | Eero/downstream path |
| `TE12` | `38:05:25:33:ED:68` | `38:05:25:33:ED:68` | none | Alpha `nic3` direct LLDP advertisement |

SNMP status from 2026-06-07:

| Probe source | Target | Result |
| --- | --- | --- |
| Ansible/control LXC `192.168.4.137` | `192.168.4.2/udp/161` | initially closed, then open after enabling SNMP management service |
| Alpha `192.168.4.10` | `192.168.4.2/udp/161` | initially closed, then open after enabling SNMP management service |

The switch management interface is reachable at `192.168.4.2` over HTTP, but
SNMP required the global management-service enable toggle before it listened.
Read-only SNMPv2c polling now works from the control LXC using the switch's
current community configuration. Replace any default community with a
non-default read-only community after discovery and restrict manager access if
the switch supports it.

SNMP system identity:

| Field | Value |
| --- | --- |
| `sysDescr` | `10G04810GSM` |
| `sysObjectID` | `.1.3.6.1.4.1.27282.1.3` |
| `sysName` | `Switch` |
| SNMP enterprise reported by nmap | `net-snmp` |

SNMP interface state:

| Port | Oper state | Reported speed |
| --- | --- | ---: |
| `TE1` | up | 2500 Mb/s |
| `TE2` | down | 10000 Mb/s |
| `TE3` | down | 10000 Mb/s |
| `TE4` | up | 2500 Mb/s |
| `TE5` | up | 10000 Mb/s |
| `TE6` | down | 10000 Mb/s |
| `TE7` | up | 10000 Mb/s |
| `TE8` | down | 10000 Mb/s |
| `TE9` | up | 10000 Mb/s |
| `TE10` | up | 10000 Mb/s |
| `TE11` | up | 10000 Mb/s |
| `TE12` | up | 10000 Mb/s |

SNMP VLAN and forwarding observations:

| Item | Current value |
| --- | --- |
| Static VLANs visible through Q-BRIDGE-MIB | VLAN `1`, name `default` |
| PVIDs | physical ports and LAG interfaces all report PVID `1` |
| VLAN-aware FDB counts | `TE1=25`, `TE4=3`, `TE5=66`, `TE7=1`, `TE9=20`, `TE10=12`, `TE11=2`, `TE12=1` |
| LLDP-MIB | not exposed over SNMP, despite LLDP being visible in the switch UI |

## Proposed VLAN Model

These IDs and subnets are proposed for planning. Do not apply them until a
collision check and switch config export are complete.

| VLAN | Name | Candidate subnet | Initial owner | Cutover timing |
| ---: | --- | --- | --- | --- |
| `1` | Legacy LAN | `192.168.4.0/24` | Existing gateway/Pi-hole | Keep during all early stages |
| `10` | Management | `192.168.10.0/24` | OPNsense later | Late cutover; do not strand Proxmox |
| `20` | Core infra | `192.168.20.0/24` | OPNsense later | After DHCP/DNS import is proven |
| `30` | Services | `192.168.30.0/24` | OPNsense later | After core infra path is proven |
| `40` | IoT | `192.168.40.0/24` | OPNsense later | After device discovery rules are defined |
| `50` | Cameras/security | `192.168.50.0/24` | OPNsense later | After recorder/hub dependencies are mapped |
| `60` | Clients | `192.168.60.0/24` | OPNsense later | After Wi-Fi VLAN capability is confirmed |
| `70` | Guest | `192.168.70.0/24` | OPNsense later | Low-risk first client-style segment if supported |
| `80` | Lab/test | `192.168.80.0/24` | OPNsense first | First DHCP/firewall test VLAN |
| `90` | Transit/spare | `192.168.90.0/24` | Reserved | Only if a routed/firewall transit is needed |

The current `192.168.4.0/24` network remains the rollback and management
network until a separate management VLAN is tested from more than one path.

## Proposed Switch-Port Intent

Initial intent, before any cutover:

| Port | Current role | Proposed role | Notes |
| --- | --- | --- | --- |
| `TE10` | Alpha `vmbr0`, alpha VMs/LXCs, `pve` node MACs | Preserve legacy LAN / rollback path | Do not change until `TE10` topology is physically confirmed |
| `TE7` | Alpha `nic2` only | First OPNsense test trunk candidate | Best first trunk because it has one known MAC and no dense client load |
| `TE12` | Alpha `nic3` only | Spare or second-stage trunk | Keep as rollback/alternate until `TE7` path is proven |
| `TE11` | Charlie and Pi-hole | Keep legacy LAN initially | Do not move Pi-hole before DHCP/DNS migration plan is proven |
| `TE5` | Dense Wi-Fi/downstream, current gateway MAC | Keep legacy LAN initially | High blast radius; defer until gateway and Wi-Fi VLAN support are ready |
| `TE9` | Dense downstream/access; LLDP system name `eero` | Keep legacy LAN initially | Reconfirm attached device/switch/AP before assigning VLANs |
| `TE1` | Dense downstream/access; LLDP system name `eero` | Keep legacy LAN initially | Reconfirm attached device/switch/AP before assigning VLANs |
| `TE4` | Small downstream/access | Keep legacy LAN initially | Candidate for low-risk test only after physical use is confirmed |
| `TE2`, `TE3`, `TE6`, `TE8` | No current dynamic entries provided | Available only after physical confirmation | Do not assume unused without checking link/state and switch UI |

First switch mutation candidate, once approved:

| Port | Native/untagged | Tagged VLANs | Purpose |
| --- | --- | --- | --- |
| `TE7` | none or legacy VLAN `1` only if needed for temporary host testing | `80` first, later `10,20,30,40,50,60,70` | OPNsense lab/test trunk via alpha `nic2` |

Keep `TE10` unchanged during `TE7` testing. This preserves alpha management,
current VM/LXC connectivity, and the existing gateway path.

## Proposed Proxmox Intent (superseded — see Gate 2 Topology above)

Historical single-trunk proposal, kept for context. Do not create this;
the current plan is the two-bridge split in "Gate 2 Topology" above.

```text
auto vmbr1
iface vmbr1 inet manual
    bridge-ports nic2
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 2-4094
```

Current target shape (per Gate 2 Topology above): `vmbr1` over `nic2` as a
plain (non-VLAN-trunk) WAN bridge, `vmbr2` over `nic3` as the VLAN-aware
LAN-test bridge (`bridge_vids` starting at `80`). Neither bridge is
IP-bearing on the Proxmox host. Alpha host management must remain on
`vmbr0` until a separate management migration is fully tested.

## Rollout Gates

Gate 0, documentation and discovery:

- Export or screenshot current MokerLink VLAN and port configuration.
- Confirm whether `TE10` is direct alpha, a downstream path, or shared topology.
- Confirm physical attachments for `TE1`, `TE4`, `TE5`, `TE9`, `TE11`, `TE12`.
- Check candidate subnets for collision with VPN, Docker, Proxmox, or existing routes.

Gate 1, safe OPNsense staging:

- Stop VM `401` or set `onboot: 0` before further network work.
- Make the OPNsense Ansible playbook resume-safe for existing VM `401`.
- Confirm OPNsense still has only the expected stage NICs before attaching a trunk.

Gate 2, WAN attach + isolated LAN trunk test (updated D080926, two-bridge split):

- Configure `TE7` (alpha `nic2`) for the AT&T WAN uplink.
- Configure `TE12` (alpha `nic3`) as the first LAN-test trunk, tagged VLAN `80`.
- Create `vmbr1` over `nic2` (WAN, no IP address) and `vmbr2` over `nic3`
  (VLAN-aware, no IP address) via `community.proxmox.proxmox_node_network`.
- Attach OPNsense `net1` to `vmbr1` (WAN) and `net2` to `vmbr2` (LAN-test).
- Enable only VLAN `80` on the `vmbr2`/`TE12` side first.
- Test OPNsense DHCP/firewall behavior only on VLAN `80`. Do not move the
  live default gateway or any client traffic — see Rollback Principles.

Gate 3, service migration preparation:

- Export Pi-hole DHCP/static reservations from Pi-hole v6 `pihole.toml`.
- Build OPNsense static mappings from the corrected inventory.
- Keep Pi-hole DNS active until OPNsense DHCP behavior is proven.
- Do not move Charlie/Pi-hole from `TE11` during early trunk tests.

Gate 4, client segment trials:

- Move one low-risk client segment only after VLAN `80` succeeds.
- Avoid `TE5` until the gateway and Wi-Fi VLAN behavior are fully understood.
- Keep `TE10` as rollback until Proxmox management is reachable from the new
  management VLAN through more than one path.

## Rollback Principles

- If `TE7` trunk testing fails, restore `TE7` to legacy VLAN `1` or disconnect
  it; `TE10` remains the live management path.
- If `vmbr1` testing fails, remove OPNsense `net1` and remove `vmbr1`; `vmbr0`
  remains unchanged.
- If OPNsense DHCP testing fails, disable DHCP on the test VLAN and keep Pi-hole
  and the current gateway online.
- Never move the default gateway from `192.168.4.1` until all management,
  DNS/DHCP, and rollback checks are explicitly satisfied.
