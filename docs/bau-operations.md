# BAU Operations Model

## Current state summary

- The repo and `network-inventory` artifact repo are the primary working inputs.
- `alpha` is reachable for management, but authenticated SSH discovery is still
  blocked from this workstation.
- The Ansible control plane is now scaffolded in-repo, but the LXC control node remains stopped.
- NetBox is currently absent from live-state operations; only the MCP scaffolding and historical references remain in the repo.

## Validation checklist

Run these before calling the platform usable:

1. `workspace: health`
2. `workspace: infra artifacts`
3. `ansible-inventory -i deploy/ansible/inventory/generated.yml --list`
4. `ansible-playbook .../lab-connectivity.yml`
5. `ansible-playbook .../proxmox-readonly-discovery.yml --check`
6. Re-test `alpha`, `homepage`, and `pihole` reachability, and validate the new NetBox endpoint only after redeployment

## Agent onboarding guide

- Prefer MCP integrations that already follow the repo naming standard.
- Keep secrets in environment variables or prompt-backed inputs only.
- Add or update a timestamped artifact in `artifacts/hc/` for every meaningful
  change.
- Do not mark a component `READY` unless a fresh validation command proves it.

## CI usage guide

- Use GitHub Actions for lightweight repo validation and manual Ansible checks.
- Use GitLab as the primary lint/validate/dry-run/manual execute path.
- Keep execute stages manual and credential-gated.

## Next-step backlog

- Start or replace the Ansible control-node CT 111
- Capture authenticated Proxmox read-only discovery evidence from `pct list`, `ip -br link`, and `bridge vlan show`
- Build the dedicated `vmbr1` trunk bridge once the active 10G port is confirmed
- Deploy a fresh NetBox instance with a newly allocated static management IP
- Add a NetBox sync loop only after the replacement deployment is validated
