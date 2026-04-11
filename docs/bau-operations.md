# BAU Operations Model

## Current state summary

- The repo and `network-inventory` artifact repo are the primary working inputs.
- `alpha` is reachable for management, but authenticated SSH discovery is still
  blocked from this workstation.
- The Ansible control plane is now scaffolded in-repo, but the LXC control node
  remains stopped.
- NetBox integration exists at the MCP layer, but the CT 100 web service is not
  currently reachable.

## Validation checklist

Run these before calling the platform usable:

1. `workspace: health`
2. `workspace: infra artifacts`
3. `ansible-inventory -i deploy/ansible/inventory/generated.yml --list`
4. `ansible-playbook .../lab-connectivity.yml`
5. `ansible-playbook .../proxmox-readonly-discovery.yml --check`
6. Re-test `alpha`, `NetBox`, `homepage`, and `pihole` reachability

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

- Recover or verify NetBox CT 100 service health
- Start or replace the Ansible control-node CT 111
- Add authenticated Proxmox read-only discovery evidence from `pct list`
- Decide the final change-control path for future VLAN segmentation
- Add a NetBox sync loop once API access is available
