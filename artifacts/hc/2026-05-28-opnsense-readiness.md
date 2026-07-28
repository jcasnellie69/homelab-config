# OPNsense Readiness Snapshot

## Context

- Date: 2026-05-28
- Controller: `pve-ansible` LXC
- Repos cloned to `/mnt/repos`
- Active worktree: `/mnt/repos/homelab-config`

## Repository Validation

- `homelab-config` cloned from `https://github.com/jcasnellie69/homelab-config.git`
- `network-inventory` cloned from `https://github.com/jcasnellie69/network-inventory.git`
- No prior Git worktrees were found under `/root` or `/mnt`.
- `/srv/homelab-config` exists as an empty local mount.
- Requested NFS mount `/mnt/homelab-config` failed from the LXC.

NFS diagnostic:

```text
mount.nfs: not installed setuid - "user" NFS mounts not supported.
showmount -e 192.168.4.10: clnt_create: RPC: Program not registered
nfs-common: 1:2.6.2-4+deb12u1
```

Likely corrective action: mount the export on the Proxmox host and bind-mount it
into the LXC, or enable the NFS export/mountd path on `192.168.4.10`.

## Restored Automation

The existing recycled Ansible scaffold was restored to active path:

```text
deploy/ansible/
```

New or updated OPNsense files:

```text
deploy/ansible/group_vars/future_opnsense.yml
deploy/ansible/inventory/lab/hosts.yml
deploy/ansible/playbooks/opnsense-alpha-onboard.yml
deploy/ansible/playbooks/opnsense-preflight.yml
docs/opnsense-staged-deployment.md
```

## Preflight Result

Command:

```bash
cd /mnt/repos/homelab-config/deploy/ansible
ansible-playbook playbooks/opnsense-preflight.yml
```

Result:

```text
localhost : ok=4 changed=0 unreachable=0 failed=0 skipped=0 rescued=0 ignored=0
```

Reachability:

| Target | Port | Result |
| --- | ---: | --- |
| `alpha` `192.168.4.10` | 22 | reachable |
| `alpha` `192.168.4.10` | 8006 | reachable |
| `pihole` `192.168.4.208` | 22 | reachable |
| `pihole` `192.168.4.208` | 53 | reachable |
| `pihole` `192.168.4.208` | 80 | reachable |
| `homepage` `192.168.4.139` | 22 | reachable |
| `homepage` `192.168.4.139` | 80 | reachable |

NetBox follow-up validation after user clarification:

| Target | Port | Result |
| --- | ---: | --- |
| `netbox` `192.168.4.140` | 22 | reachable |
| `netbox` `192.168.4.140` | 80 | reachable |
| `netbox` `192.168.4.140` | 443 | reachable |
| `netbox` `192.168.4.140` | 8080 | reachable |
| `netbox` `192.168.4.140` | 8000 | closed |

Inventory note: preserve the `netbox` host name. The former colliding
inventory group is represented as `ipam` in the active Ansible inventory.

## Network Inventory Correlation

Source: `/mnt/repos/network-inventory/network-inventory.json`

- Total devices: 124
- Category counts:
  - Unknown: 20
  - Smart Hub: 17
  - Lighting/Smart: 17
  - Smart Plug/IoT: 17
  - Mobile/Apple: 12
  - Network/Router: 9
  - Security/Camera: 7
  - Amazon Device: 6
  - Appliance: 5
  - Infrastructure: 5
  - Wearable: 4
  - Entertainment: 3
  - Computer: 1
  - Energy Monitor: 1
- Switch concentration:
  - `TE5`: 74 devices
  - `Not on Switch`: 31 devices
  - `TE2`: 12 devices
  - `TE10`: 3 devices
  - `TE3`: 2 devices
  - `TE1`: 1 device
  - `TE4`: 1 device

High-risk migration observations:

- Multiple critical/high clients are on current flat `192.168.4.0/24`.
- `192.168.4.1` is current default gateway and must not be displaced in stage 1.
- Apple/HomeKit-like devices include `apple-tv-hub.lan`, iPhones, iPad, watches,
  and Apple TV endpoints; discovery-heavy traffic should remain flat until mDNS
  relay/firewall policy is deliberately staged.
- IoT and camera categories are significant and should move after management and
  core infra validation, not during initial OPNsense VM creation.

## Safe Next Actions

Credential bootstrap workflow generated:

```text
deploy/ansible/scripts/bootstrap-pve-opnsense-api-token.sh
deploy/ansible/playbooks/proxmox-api-token-validate.yml
docs/proxmox-api-token-bootstrap.md
```

Execution status:

```text
ssh root@192.168.4.10: Permission denied (publickey,password)
```

No Proxmox token was created during this run because SSH authentication to
`alpha` is not available from the orchestration LXC.

Docker/Portainer key-source follow-up:

```text
192.168.4.76:9443 is Portainer
ssh root@192.168.4.76: Permission denied (publickey,password)
192.168.4.155:9000 responded as a possible service, but SSH on 22 is refused
```

The bootstrap script now supports `PVE_SSH_KEY` and `PVE_SSH_PROXYJUMP` so a key
stored in the Docker LXC can be used without writing it into Git.

Semaphore project `1` was seeded with:

| Resource | Name |
| --- | --- |
| Key | `none-local` |
| Repository | `homelab-config-local-ansible` |
| Inventory | `lab-file-inventory` |
| Environment | `opnsense-stage-safe-defaults` |
| Template | `OPNsense - preflight` |
| Template | `Lab - connectivity` |
| Template | `Proxmox - read-only discovery` |
| Template | `OPNsense - VM shell stage` |

Semaphore validation:

```text
Task 4, template "OPNsense - preflight": success
Task 5, template "Lab - connectivity": success
Task 8, template "OPNsense - VM shell stage": success
```

The VM shell stage remained non-mutating because Proxmox API credentials are not
present and `opnsense_check_mode` is still `true`.

Follow-up order:

1. Run `OPNsense - preflight` and `Lab - connectivity` from Semaphore first.
2. Add Proxmox API credentials only when ready to create the VM shell.
3. Keep `opnsense_check_mode: true` until ISO presence and VM parameters are
   confirmed.
4. Do not create or attach `vmbr1` until `nic2` or `nic3` is proven as the live
   10G uplink.
