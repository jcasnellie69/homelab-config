# Docker Scrypted Space Remediation

D082226 | CHG-DOCKER-SCRYPTED-SPACE-20260822 | document Docker VM Scrypted disk remediation | JC | ct409+docker-vm-109

- Timestamp: 2026-08-22T21:06:00Z
- Change ID: `CHG-DOCKER-SCRYPTED-SPACE-20260822`
- Target: Docker VM `109`, hostname `docker`, IP `192.168.4.76`
- Access path used: alpha `192.168.4.10` QEMU guest agent, then direct SSH
- Status: `COMPLETED`

## Root Cause

The Docker VM virtual disk was `80G`, but the root partition `/dev/sda3`
was still about `30G` and had reached `100%` usage. Docker could not create
runtime files, so Scrypted plugin activation failed with `no space left on
device`.

## Remediation

- Cleaned apt cache with `apt-get clean`.
- Confirmed default `docker image prune -f` reclaimed `0B`; reclaimable image
  space was tagged image data, not dangling layers.
- Backed up VM config, partition table, and disk state before resizing.
- Ran `growpart /dev/sda 3` and `resize2fs /dev/sda3` through QGA.
- Restarted `scrypted` after disk recovery so plugin dependency install could
  complete.
- Repaired direct root SSH to `192.168.4.76` by adding CT409 root public key
  `pve-ansible-to-alpha`; the previous Docker VM `authorized_keys` file was
  backed up as `/root/.ssh/authorized_keys.D082226T2102.bak`.
- Captured and stopped legacy `mcp-gateway-old`; set its restart policy to
  `no` without deleting the container or volumes.
- Added Docker VM health automation and registered Semaphore template ID `5`,
  `Docker - VM health check`.

## Result

- `/dev/sda3` now spans the `80G` VM disk.
- `/` is `79G`, `29G` used, `47G` available, `39%` used.
- Restarting container count is `0`.
- `scrypted`, `portainer`, and `otel-collector` are running.
- Scrypted HTTPS endpoint returns HTTP `200` at
  `https://192.168.4.76:10443/endpoint/@scrypted/core/public/`.
- Scrypted Tapo plugin process is running: `@scrypted/tapo`.
- Scrypted Eufy plugin process is running: `scrypted-eufy-security`.
- Eufy dependency directory is present:
  `/server/volume/plugins/scrypted-eufy-security/n-node-v127-linux-x64-20250101/node_modules/eufy-security-client`.
- Portainer UI returns HTTP `200` at `https://192.168.4.76:9443/`.
- OTel collector ports `4317` and `4318` are open on localhost.

## Camera Discovery Note

A focused scan found a likely TP-Link/Tapo camera-class device at
`192.168.4.162` with MAC `8C:90:2D:41:4D:C1`; ports `443` and `8800` were
open while `80`, `554`, and `2020` were filtered. Earlier inventory appears
stale for this MAC, indicating DHCP/IP drift.

## Evidence Artifacts

- Start marker: `/srv/artifacts/hc/2026-08-22T204732Z-artifact.txt`
- Final health check:
  `/srv/artifacts/hc/2026-08-22T210442Z-docker-vm-health-docker.txt`
- VM config backup:
  `/root/artifacts/docker-scrypted-20260822/qm-109-config-before-root-grow.txt`
- Partition backup:
  `/root/artifacts/docker-scrypted-20260822/qm-109-sfdisk-before-root-grow.json`
- Disk-state backup:
  `/root/artifacts/docker-scrypted-20260822/qm-109-disk-before-root-grow.json`
- MCP gateway capture:
  `/root/artifacts/docker-scrypted-20260822/mcp-gateway-old-before-stop-20260822T210344Z.txt`
- Semaphore template DB backup:
  `/root/artifacts/docker-scrypted-20260822/semaphore-project-template-before-docker-health-20260822T2100.sql`

## Known Follow-Ups

- Docker still reports about `17G` of reclaimable tagged image data. It was
  left in place because free disk space is now healthy and `docker image
  prune -a` would remove non-dangling images.
- Docker MCP CLI/plugin remains installed and usable (`v0.42.2`), but no MCP
  gateway service was recreated because the stopped legacy container had no
  socket mount, port binding, labels, or working runtime definition.
