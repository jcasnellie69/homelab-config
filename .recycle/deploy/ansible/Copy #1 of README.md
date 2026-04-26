# Ansible Control Plane

This directory holds the non-destructive homelab control-plane scaffold.

## Current layout

- `ansible.cfg` — local defaults for inventory, roles, and safe controller behavior
- `inventory/generated.yml` — generated inventory from artifact data
- `inventory/lab/hosts.yml` — curated, confirmed management endpoints
- `group_vars/` — network model and platform defaults
- `host_vars/` — host-specific validated facts
- `playbooks/lab-connectivity.yml` — controller-side port validation
- `playbooks/proxmox-readonly-discovery.yml` — read-only Proxmox discovery
- `playbooks/opnsense-alpha-onboard.yml` — staged future OPNsense bootstrap
- `roles/` — reusable read-only roles

## Safe validation commands

```bash
ansible-inventory -i deploy/ansible/inventory/generated.yml --list
ansible-playbook -i deploy/ansible/inventory/lab/hosts.yml deploy/ansible/playbooks/lab-connectivity.yml
ansible-playbook -i deploy/ansible/inventory/lab/hosts.yml deploy/ansible/playbooks/proxmox-readonly-discovery.yml --check
```

> Do not run live mutation tasks until credentials and target host reachability are confirmed.
