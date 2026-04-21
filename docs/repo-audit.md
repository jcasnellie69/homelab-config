# Repo Audit

## Scope

This audit summarizes the current homelab automation workspace using the repo,
`network-inventory` artifact data, generated reports, and live reachability
checks from 2026-04-11.

## Existing automation structure

### Ansible

- `deploy/ansible/inventory/generated.yml` contains the generated lab inventory.
- `deploy/ansible/group_vars/future_opnsense.yml` stages the OPNsense rollout.
- `deploy/ansible/playbooks/opnsense-alpha-onboard.yml` is the existing
  Proxmox-to-OPNsense bootstrap path.
- `deploy/ansible/collections/requirements.yml` pins:
  `community.proxmox`, `netbox.netbox`, `ansibleguy.opnsense`,
  `community.general`, and `ansible.posix`.
- `deploy/ansible/bootstrap-control-node.sh` bootstraps an Ansible control node.

### Docs and runbooks

- `docs/orchestration.md` is the repo-level onboarding and evidence standard.
- `docs/observability-service-map.md` maps the LXC roles.
- `docs/netbox mcp instructions.md` documents the NetBox MCP integration.
- `docs/telemetry-pipeline.md` documents telemetry flows and service placement.

### Network and discovery artifacts

- `artifacts/network-inventory.json` is the network artifact repo and the main
  network discovery input.
- `artifacts/dhcp-discovery/*` contains historical PVE interface and bridge
  evidence, including VLAN-aware bridge data.
- `reports/automation/*.json` contains generated inventory, NetBox sync seeds,
  OPNsense host seeds, and Terraform seed data.

### CI and workspace automation

- `.github/workflows/lint.yml` already validates docs, scripts, metadata,
  generated artifacts, and the devcontainer build.
- No `.gitlab-ci.yml` existed before this phase.
- MCP servers are defined in `mcp.json` and `.vscode/mcp.json` with the repo
  naming standard `HOMELAB_*` and `homelab-*`.

## Live-state summary

- `alpha` at `192.168.4.10` is reachable on ports `22` and `8006`, and the live
  HTTPS landing page identifies the node as `pve-plex-oasis-alpha`.
- Historical NetBox assumptions are stale: no live NetBox service was confirmed,
  and the old `192.168.4.140` reference is no longer a safe server endpoint.
- `homepage` (`192.168.4.139`) and `pihole` (`192.168.4.208`) remain the most
  reachable confirmed service endpoints from the controller.
- SSH authentication to `root@192.168.4.10` is blocked without valid
  credentials, and authenticated Proxmox API calls return `401 (No ticket)`, so
  live `pct` and `ip -br link` inspection is still blocked from this host.

## Gaps

1. No normalized `ansible.cfg`, curated `inventory/lab`, or reusable read-only
   roles existed.
2. No GitLab pipeline existed for lint/validate/dry-run/manual execute flow.
3. No dedicated repo docs existed for source-of-truth reconciliation,
   VLAN baseline, Jules handoff, or BAU operations.
4. The NetBox integration path exists, but live service health is blocked.

## Duplication and drift risks

- `artifacts/network-inventory.json`, `deploy/ansible/inventory/generated.yml`,
  and future NetBox DCIM data can drift if not reconciled regularly.
- Historical PVE network artifacts still show `192.168.4.249` for `vmbr0`, while
  current live reachability confirms `192.168.4.10` for `alpha`.
- The Ansible control node is listed as CT `111`, but it is currently stopped,
  so local workstation validation and future CT-based validation may diverge.
