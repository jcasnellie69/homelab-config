# Source of Truth Reconciliation

## Authoritative sources by domain

| Domain | Current authoritative source | Confidence | Notes |
| --- | --- | --- | --- |
| Network inventory | `artifacts/network-inventory.json` | High | User confirmed this is the network artifact repo. |
| Repo automation layout | `deploy/ansible/**`, `scripts/session/**`, `docs/orchestration.md` | High | These define the current workspace automation contract. |
| Live host reachability | `artifacts/hc/*-lab-reachability.txt` | High | Fresh evidence from 2026-04-11. |
| Generated inventory | `deploy/ansible/inventory/generated.yml` | Medium | Derived from artifacts and should be regenerated after new discovery. |
| NetBox state | user-confirmed absence + live network checks | High | No live NetBox deployment was confirmed; the historical CT 100 reference is stale. |
| Historical PVE networking | `artifacts/dhcp-discovery/D122225T0153/*` | Medium | Useful for bridge and gateway facts, but some addresses appear stale. |

## Confirmed current state

- `alpha` is reachable at `192.168.4.10` on `22/tcp` and `8006/tcp`.
- The live Proxmox HTTPS page at `192.168.4.10:8006` identifies the node as `pve-plex-oasis-alpha`.
- `homepage` (`192.168.4.139`) is reachable on `22/tcp` and `80/tcp`.
- `pihole` (`192.168.4.208`) is reachable on `22/tcp`, `53/tcp`, and `80/tcp`.
- `vmbr0` remains the historical management bridge, while the older `.249` address and `enp*` mappings are now stale.
- The management subnet in current repo artifacts remains `192.168.4.0/24`.

## Stale or conflicting items

| Item | Current evidence | Historical evidence | Decision |
| --- | --- | --- | --- |
| `alpha` management IP | `192.168.4.10` reachable on SSH and PVE UI | `192.168.4.249/24` in `pve_interfaces.txt` | Treat `.10` as the active management address and `.249` as stale history. |
| NetBox availability | No live NetBox app on `80/443/22`; user confirmed it is not deployed | Repo docs and generated inventory still referenced CT 100 and `192.168.4.140` | Mark NetBox as absent and do not reuse `192.168.4.140` automatically. |
| Ansible control node | CT `111` listed as stopped | Older handoff implied an Ansible LXC | Mark control plane as scaffolded but not live. |

## Unknowns

- Current live `pct list` and `ip -br link` output from `alpha` are unavailable from this host because SSH authentication is blocked.
- Authenticated Proxmox API inventory endpoints are also blocked from this host without a valid ticket.
- No Proxmox API or OPNsense API credentials were present in the controller environment during validation.

## Operating decision

1. Use live Proxmox reachability and HTTPS identity as the top priority source for the management plane.
2. Use `network-inventory` only as a secondary artifact source when live host access is blocked.
3. Treat NetBox as absent until a fresh deployment is built and validated.
4. Re-run generated inventory and discovery artifacts after each authenticated live discovery session or controller credential update.
