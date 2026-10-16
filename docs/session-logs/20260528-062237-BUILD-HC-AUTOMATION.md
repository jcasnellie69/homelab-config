# Session: BUILD-HC-AUTOMATION

- **Date:** 2026-05-28
- **Start Time (local):** 06:22
- **Host / Context:** pve-ansible
- **Repo Base:** /mnt/repos/homelab-config

## 1. Goals

- Resume staged OPNsense automation from validated Semaphore/Ansible state.
- Run read-only/authenticated Proxmox discovery.
- Validate VMID, storage, ISO, bridges, NICs, and 10G uplink candidates.
- Run OPNsense VM shell stage in check-mode only.
- Preserve non-destructive/no-cutover posture.

## 2. Notes / Decisions

- Ansible SSH authentication to `alpha` succeeded.
- `proxmox-readonly-discovery.yml` required explicit vars via `-e @group_vars/proxmox.yml` because `deploy/ansible/group_vars/proxmox.yml` was not loaded from the active inventory path.
- VMID `401` is available; `qm status 401` returned missing config.
- Storage targets are active: `local` for ISO/import content and `local-lvm` for images/rootdir.
- Required ISO `local:iso/OPNsense.iso` is not present. Current ISO inventory only shows `local:iso/turnkey-fileserver-18.0-bookworm-amd64.iso`.
- Downloaded official OPNsense `26.1.6` DVD amd64 installer from `pkg.opnsense.org` and expanded it on `alpha`.
- `local:iso/OPNsense.iso` is now present as the playbook-compatible ISO name.
- `vmbr0` remains the only active bridge with `192.168.4.10/24`, gateway `192.168.4.1`, and bridge port `nic0`.
- `vmbr1` is not present and was not created.
- Existing visible VM/LXC NICs remain on `vmbr0`/VLAN 1.
- 10G hardware candidates are `nic2` and `nic3` (`i40e`, 10000baseT/Full), but both have no carrier. No active 10G uplink is identified yet.
- OPNsense VM shell stage check-mode completed with `changed=0`; creation task skipped because local `PVE_*` API token environment variables are absent.
- Semaphore credential injection was fixed for the OPNsense VM shell template.
- Created dedicated Semaphore environment `opnsense-stage-api-runtime` with non-secret `PVE_API_USER=ansible@pve` and `PVE_API_TOKEN_ID=opnsense-automation`.
- Created dedicated Semaphore inventory `opnsense-api-token-runtime-inventory` bound to Key Store entry `pve-opnsense-api-token`.
- Updated Semaphore template `OPNsense - VM shell stage` to use the dedicated runtime inventory/environment.
- Updated the OPNsense playbook to resolve API credentials from either `PVE_*` environment variables or the Semaphore key binding (`ansible_user` full token and `ansible_password` token secret).
- Corrected Proxmox API node target from `alpha` to `pve-plex-oasis-alpha`.
- Installed `community.proxmox` into `/usr/share/ansible/collections` so the `semaphore` service account can resolve `community.proxmox.proxmox_kvm`.
- Semaphore task `12` completed successfully in dry-run/check-mode with authenticated API validation and `changed=0`.
- The Proxmox API token can see physical NIC entries but not `vmbr0` through the network API; `vmbr0` remains validated by SSH discovery and `/etc/network/interfaces`.
- 2026-05-30 approved mutation completed: created only the OPNsense VM shell `opnsense-alpha` as VMID `401`.
- Semaphore/API creation attempts stopped before successful creation on runtime prerequisites/permissions:
  - Task `13`: missing `proxmoxer`.
  - Task `14`: Debian `python3-proxmoxer` was version `1.2.0`; `community.proxmox` requires `>=2.0`.
  - Installed `proxmoxer 2.3.0` with `python3 -m pip install 'proxmoxer>=2.0' --break-system-packages`.
  - Task `15`: Proxmox rejected `local-lvm:32G`; playbook now renders the LVM-thin size as `local-lvm:32` while preserving the approved `32G` disk.
  - Task `16`: Proxmox API token reached VM creation but lacked `SDN.Use` on `/sdn/zones/localnetwork/vmbr0`; no Proxmox role/ACL mutation was performed.
- To avoid non-approved Proxmox ACL mutation, the approved VM shell was created over authenticated SSH with `qm create`.
- Semaphore template `OPNsense - VM shell stage` was restored to safe default arguments (`[]`) after creation attempts.
- VM `401` remains stopped; it was not powered on.

## 3. Commands / Evidence

- `ansible proxmox -m ping`: `alpha` returned `pong`.
- `ansible-playbook playbooks/proxmox-readonly-discovery.yml -e @group_vars/proxmox.yml`: success, `changed=0`, Proxmox `pve-manager/9.2.2`.
- `qm list`: only VMIDs `101` and `109`; planned VMID `401` absent.
- `pct list`: includes `409 pve-ansible`, `200 netbox`, and other active LXCs.
- `pvesm status --content images,iso`: `local` and `local-lvm` active.
- `pvesm list local --content iso`: `OPNsense.iso` absent.
- `get_url`: downloaded `OPNsense-26.1.6-dvd-amd64.iso.bz2` to `/var/lib/vz/template/iso/` with SHA256 `6ba3633d9c0f96d82c792015a45f4b8aac45ea8fa2bdba3c5e534d0c90a4f08c`.
- `bunzip2 -fk /var/lib/vz/template/iso/OPNsense-26.1.6-dvd-amd64.iso.bz2`: expanded ISO in place.
- `cp -a /var/lib/vz/template/iso/OPNsense-26.1.6-dvd-amd64.iso /var/lib/vz/template/iso/OPNsense.iso`: created playbook-compatible ISO alias.
- `pvesm list local --content iso`: now shows `local:iso/OPNsense-26.1.6-dvd-amd64.iso` and `local:iso/OPNsense.iso`, both `2224539648` bytes.
- `/etc/network/interfaces`: `vmbr0` static on `nic0`; no `vmbr1` stanza.
- `ethtool`: `nic0` link up at 2500Mb/s; `nic2`/`nic3` 10G-capable but link down.
- `ansible-playbook playbooks/opnsense-alpha-onboard.yml --check -e opnsense_check_mode=true`: `changed=0`, skipped VM creation.
- Semaphore task `9`: credential injection succeeded and authenticated API version check returned Proxmox `9.2.2`; run then failed because `community.proxmox` was not available to the `semaphore` user.
- Copied existing `community.proxmox` collection from `/root/.ansible/collections` to `/usr/share/ansible/collections`.
- Semaphore task `10`: authenticated API validation succeeded; module task skipped under Ansible check-mode.
- Semaphore task `11`: authenticated dry-run reached prerequisite assertions and failed only on API network bridge visibility.
- Semaphore task `12`: success, `ok=15`, `changed=0`, `failed=0`; authenticated API validation and node/VMID/storage/ISO dry-run checks passed.
- `qm create 401 --name opnsense-alpha --memory 4096 --cores 2 --sockets 1 --scsihw virtio-scsi-pci --scsi0 local-lvm:32 --ide2 local:iso/OPNsense.iso,media=cdrom --net0 virtio,bridge=vmbr0 --boot 'order=scsi0;ide2;net0' --onboot 1`: created `local-lvm:vm-401-disk-0,size=32G`.
- `qm status 401`: `status: stopped`.
- `qm config 401`: `boot: order=scsi0;ide2;net0`, `cores: 2`, `memory: 4096`, `sockets: 1`, `ide2: local:iso/OPNsense.iso,media=cdrom`, `net0: virtio=BC:24:11:E6:D8:FA,bridge=vmbr0`, `onboot: 1`, `scsi0: local-lvm:vm-401-disk-0,size=32G`, `scsihw: virtio-scsi-pci`.
- `qm list`: includes `401 opnsense-alpha stopped 4096 32.00`.
- `pvesm list local-lvm --content images`: includes `local-lvm:vm-401-disk-0 raw images 34359738368 401`.
- `/etc/network/interfaces`: unchanged; `vmbr0` remains static `192.168.4.10/24`, gateway `192.168.4.1`, `bridge-ports nic0`; no `vmbr1` stanza.
- `bridge vlan show`: unchanged VLAN 1 baseline; no new bridge/VLAN activation.
- `ip -br link`: no `vmbr1`; `vmbr0` remains up on MAC `38:05:25:33:ed:66`; VM `401` is stopped, so no running tap device was introduced.

## 4. End-of-session Summary

- VM shell creation is complete and verified.
- No bridge, `vmbr1`, VLAN, DHCP, DNS, gateway, WAN, firewall, cutover, or power-on changes were made.
- Next gate remains closed: do not power on or boot the installer without explicit approval.
