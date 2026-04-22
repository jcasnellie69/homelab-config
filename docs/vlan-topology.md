# VLAN Topology Draft

## Confirmed current state

The current network baseline is still a flat management and service domain on
`192.168.4.0/24` with default `VLAN 1` behavior.

Confirmed evidence:

- Historical PVE host configuration shows `vmbr0` as `bridge-vlan-aware yes`.
- The same artifact shows `bridge-vids 2-4094`, which means the bridge is ready
  for segmentation but does not confirm any active tagged VLANs.
- The default gateway confirmed in the PVE interface artifact is `192.168.4.1`.

## Current topology model

| Layer | Current state | Evidence |
| --- | --- | --- |
| Default VLAN | VLAN 1 baseline only | `artifacts/dhcp-discovery/D122225T0153/pve_interfaces.txt` |
| PVE bridge | `vmbr0`, VLAN-aware | `pve_interfaces.txt`, `pve_bridge_links.txt` |
| Management subnet | `192.168.4.0/24` | Repo inventory and generated automation metadata |
| Reachable services | `alpha`, `homepage`, `pihole` | 2026-04-11 reachability evidence |

## Candidate future segmentation

No new VLAN IDs are assigned in this draft.

Proposed logical segments only:

1. **Management** — Proxmox host access, automation entry points, controller use
2. **Core infra** — DNS, IPAM, telemetry, and monitoring services
3. **User-facing apps** — Homepage and other UI services
4. **IoT / discovery-heavy clients** — devices currently surfaced via the
   `network-inventory` artifact repo

## Dependencies before any VLAN change

- Confirm the active switch configuration from the MOKERLINK environment
- Confirm live `bridge vlan show` from `alpha` over authenticated SSH
- Confirm which LXCs or services require untagged access during migration
- Confirm Pi-hole, NetBox, and telemetry flows that must stay reachable

## Unknowns

- No live switch export or LLDP/cable map was available in this session.
- No live `pct`-based container NIC inventory could be collected without SSH
  access to `alpha`.
- Current tagged VLAN usage on switch ports remains unverified.

## Migration considerations

- Keep VLAN 1 as the documented fallback until the live switch and Proxmox
  configuration are both confirmed.
- Stage validation playbooks before any bridge, gateway, or switch change.
- Treat segmentation as a change-controlled activity, not a default automation
  action.
