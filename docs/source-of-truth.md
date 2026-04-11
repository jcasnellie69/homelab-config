# Source of Truth Reconciliation

## Authoritative sources by domain

| Domain | Current authoritative source | Confidence | Notes |
| --- | --- | --- | --- |
| Network inventory | `artifacts/network-inventory.json` | High | User confirmed this is the network artifact repo. |
| Repo automation layout | `deploy/ansible/**`, `scripts/session/**`, `docs/orchestration.md` | High | These define the current workspace automation contract. |
| Live host reachability | `artifacts/hc/*-lab-reachability.txt` | High | Fresh evidence from 2026-04-11. |
| Generated inventory | `deploy/ansible/inventory/generated.yml` | Medium | Derived from artifacts and should be regenerated after new discovery. |
| NetBox state | `docs/netbox mcp instructions.md` + live checks | Medium | Integration is scaffolded, but CT 100 service is not currently reachable on 80/443. |
| Historical PVE networking | `artifacts/dhcp-discovery/D122225T0153/*` | Medium | Useful for bridge and gateway facts, but some addresses appear stale. |

## Confirmed current state

- `alpha` is reachable at `192.168.4.10` on `22/tcp` and `8006/tcp`.
- `homepage` (`192.168.4.139`) is reachable on `22/tcp` and `80/tcp`.
- `pihole` (`192.168.4.208`) is reachable on `22/tcp`, `53/tcp`, and `80/tcp`.
- `vmbr0` is configured as VLAN-aware in historical PVE interface evidence.
- The management subnet in current repo artifacts remains `192.168.4.0/24`.

## Stale or conflicting items

| Item | Current evidence | Historical evidence | Decision |
| --- | --- | --- | --- |
| `alpha` management IP | `192.168.4.10` reachable on SSH and PVE UI | `192.168.4.249/24` in `pve_interfaces.txt` | Treat `.10` as active and `.249` as historical until a live SSH session confirms otherwise. |
| NetBox availability | ICMP only at `192.168.4.140` | Repo docs hint at `http://192.168.4.140/` | Keep NetBox as supplemental until CT 100 web service is restored. |
| Ansible control node | CT `111` listed as stopped | Older handoff implied an Ansible LXC | Mark control plane as scaffolded but not live. |

## Unknowns

- Current live `pct list` output from `alpha` is unavailable from this host due
  SSH authentication failure.
- No current NetBox API token was available for authenticated sync testing.
- No Proxmox API or OPNsense API credentials were present in the controller
  environment during validation.

## Operating decision

1. Use the repo plus `network-inventory` as the primary source of truth.
2. Use live reachability checks to override stale historical network values.
3. Treat NetBox as a supplemental source until CT 100 is reachable again.
4. Re-run generated inventory and discovery artifacts after each live discovery
   session or controller credential update.
