# Docker VM Health Check

D082226 | CHG-DOCKER-SCRYPTED-SPACE-20260822 | document Docker VM health workflow | JC | ct409+docker-vm-109
D091426 | CHG-DOCKER-HC-REVIEW-FIX-20260914 | drop /tmp temp-dir overrides, document check-failure vs health-failure | JC | ct409+docker-vm-109

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
ansible-playbook playbooks/docker-vm-health-check.yml
```

Temp directories come from `deploy/ansible/ansible.cfg` (`local_tmp` / `remote_tmp`); do not override them to fixed paths under `/tmp` on the command line. A fixed, predictable path in a world-writable directory can be pre-created by another local user, which lets them tamper with module payloads on a multi-user host. If a per-run override is ever needed, point it inside the invoking user's home (Ansible's default is `~/.ansible/tmp`).

The playbook writes a timestamped artifact under `/srv/artifacts/hc/` **before** evaluating any assertion, so the evidence file exists even when the check fails. It then asserts in two stages:

1. **Check integrity** — the guest script exited `0`, emitted its `HC_METRICS_END` sentinel, and `HC_ROOT_USE_PCT` / `HC_RESTARTING_CONTAINER_COUNT` are numeric. A failure here means the check itself could not run (for example `df`/`awk`/`docker` erroring inside the VM) and is **not** a health verdict; read `# STDERR` in the artifact.
2. **Health verdict** — only the `HC_*` lines above the sentinel are parsed (as exact key/value pairs, never substring matches against the free-form diagnostics below it). The check fails for critical conditions by default:

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
