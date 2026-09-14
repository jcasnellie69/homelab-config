# Docker VM Health Check

D082226 | CHG-DOCKER-SCRYPTED-SPACE-20260822 | document Docker VM health workflow | JC | ct409+docker-vm-109

## Purpose

Use this runbook to audit Docker VM `109` (`docker`, `192.168.4.76`). The Semaphore workflow uses alpha's Proxmox QEMU guest agent path so the check does not depend on guest SSH, while direct root SSH is available for hands-on Docker work.

## Current Access Path

- Proxmox host: `alpha` / `192.168.4.10`
- Docker VM: VMID `109`
- Docker VM IP: `192.168.4.76`
- Direct SSH to Docker VM: `ssh root@192.168.4.76`
- Semaphore health path: `ssh root@192.168.4.10` then `qm guest exec 109 -- ...`

## Health Playbook

Run from `/mnt/repos/homelab-config/deploy/ansible`:

```bash
ANSIBLE_LOCAL_TEMP=/tmp/ansible-local \
ANSIBLE_REMOTE_TEMP=/tmp/ansible-remote \
ansible-playbook playbooks/docker-vm-health-check.yml
```

The playbook writes a timestamped artifact under `/srv/artifacts/hc/` and fails only for critical conditions by default:

- Docker VM root filesystem at or above `90%`
- Required containers not running: `scrypted`, `portainer`, `otel-collector`
- Scrypted Tapo plugin process not running
- Scrypted Eufy plugin process not running
- Eufy plugin dependency directory missing

Restarting containers are recorded in the artifact and fail the check by default. Set `docker_health_fail_on_restarting_containers=false` only during a controlled maintenance window.

## Known State After 2026-08-22 Remediation

- Root filesystem was expanded from about `30G` to about `80G`.
- `/` dropped from `100%` used to about `39%`.
- Direct SSH was repaired by adding CT409 root key `pve-ansible-to-alpha` to `/root/.ssh/authorized_keys` on the Docker VM; the previous file was backed up as `/root/.ssh/authorized_keys.D082226T2102.bak`.
- Scrypted is mounted at `/root/.scrypted/volume -> /server/volume`.
- Scrypted endpoint is reachable at `https://192.168.4.76:10443/`.
- `@scrypted/tapo` is installed and running.
- `scrypted-eufy-security` is installed and running.
- Eufy dependency `eufy-security-client` is present after restarting Scrypted.
- `mcp-gateway-old` was stopped and set to `restart=no` because it lacked the Docker socket mount and was looping for five days; its inspect/log state was captured under `/root/artifacts/docker-scrypted-20260822/`.
- Docker MCP CLI/plugin remains installed on the VM (`docker mcp version` reported `v0.42.2`) with a default profile and `mcp/docker-mcp-catalog:latest` present.

## Future Improvement

The `community.docker` collection is installed on CT409 and can be used for a direct-SSH playbook against `192.168.4.76`. Keep the QGA playbook as the Semaphore baseline because it can still run when guest SSH breaks again.
