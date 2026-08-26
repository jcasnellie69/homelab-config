# Docker Scrypted Space Remediation Session

D082226 | CHG-DOCKER-SCRYPTED-SPACE-20260822 | session log for Docker VM Scrypted disk remediation | JC | ct409+docker-vm-109

## Request

Investigate Docker VM space pressure after Scrypted plugin activation failed,
bring up Eufy and Tapo plugins, check other Docker containers including MCP,
logging, disk, and network state, repair access through alpha if needed, and
add a reusable Docker health workflow with repo evidence.

## Timeline

- Confirmed Docker VM `109` is `docker` at `192.168.4.76` on alpha
  `192.168.4.10`.
- Direct SSH to `192.168.4.76` initially failed; access proceeded through
  alpha QEMU guest agent.
- Found `/dev/sda` was `80G` but `/dev/sda3` root filesystem was about `30G`
  and full.
- Captured VM config, partition table, and disk state under
  `/root/artifacts/docker-scrypted-20260822/`.
- Ran `growpart /dev/sda 3` and `resize2fs /dev/sda3`; root now reports
  `79G` total and `47G` available.
- Restarted `scrypted`; Tapo and Eufy plugin child processes loaded, and
  `eufy-security-client` dependency completed installation.
- Repaired direct Docker VM root SSH by appending CT409 root key
  `pve-ansible-to-alpha` after backing up the existing `authorized_keys`.
- Checked Portainer and OTel collector; both are running and reachable.
- Captured `mcp-gateway-old` inspect/log state, then stopped it and changed
  restart policy to `no` because it lacked Docker socket access and looped for
  five days.
- Added `deploy/ansible/playbooks/docker-vm-health-check.yml`.
- Added runbook `docs/runbooks/docker-vm-health-check.md` and indexed it in
  `docs/DOCS_INDEX.md`.
- Registered Semaphore template ID `5`, `Docker - VM health check`, pointing
  to `playbooks/docker-vm-health-check.yml`.

## Verification

- `ansible-playbook playbooks/docker-vm-health-check.yml --syntax-check`
  passed.
- `ansible-playbook playbooks/docker-vm-health-check.yml` passed with
  `ok=10`, `failed=0`.
- Final health artifact:
  `/srv/artifacts/hc/2026-08-22T210442Z-docker-vm-health-docker.txt`.
- Health artifact reported root usage `39%`, restarting containers `0`, and:
  `HC_SCRYPTED_TAPO_PLUGIN=running`,
  `HC_SCRYPTED_EUFY_PLUGIN=running`,
  `HC_SCRYPTED_EUFY_DEPENDENCY=present`.
- Scrypted endpoint returned HTTP `200`.
- Portainer endpoint returned HTTP `200`.
- OTel ports `4317` and `4318` were open on localhost.
- Focused camera scan found MAC `8C:90:2D:41:4D:C1` at `192.168.4.162` with
  ports `443` and `8800` open.

## Notes

- `community.docker` collection `3.4.2` is installed and available for a
  direct-SSH health workflow now that guest SSH is repaired. The committed
  baseline remains QGA-based so Semaphore can still run the check if guest SSH
  trust drifts again.
- Docker image cleanup beyond dangling layers was not performed. `docker
  system df` still shows about `17G` reclaimable from tagged images; removing
  those should be a deliberate maintenance action.
- The only Ansible warning observed was the existing non-fatal
  `/usr/share/ansible/plugins/connection/lxc_ssh.py` compatibility warning.
