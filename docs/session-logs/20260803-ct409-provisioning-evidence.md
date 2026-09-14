D080326 | CHG-CT409-PROVISION-CAPTURE-001 | capture CT409 original
provisioning log out of the Proxmox UI notes box before it's lost | JC | ct409

## Why this exists

This content only existed in the "Notes" field of CT 409's config in the
Proxmox web UI — it was not recorded anywhere in this repo. Captured verbatim
so it survives independent of that UI field (which nothing backs up) and so
the original SSH host key fingerprints are available for future drift/MITM
checking if CT409 is ever rebuilt or its host keys ever need re-verification.

## Source

Proxmox UI, CT 409 (`pve-ansible`) → Notes box. Recorded by the operator
2026-08-03; describes the container's original creation, not a new event.

## Verbatim provisioning log

```text
Logical volume "vm-409-disk-0" created.
Creating filesystem with 2097152 4k blocks and 524288 inodes
Filesystem UUID: 92bbb1f7-abcd-422b-9ba7-084af06895eb
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632
extracting archive '/var/lib/vz/template/cache/debian-12-turnkey-ansible_18.0-1_amd64.tar.gz'
Total bytes read: 1282744320 (1.2GiB, 145MiB/s)
Detected container architecture: amd64
Setting up 'proxmox-regenerate-snakeoil.service' to regenerate snakeoil certificate..
Creating SSH host key 'ssh_host_rsa_key' - this may take some time ...
done: SHA256:A2lIA72XM9pM+1FbAj2a+IxKa4RfVElHl0Bp8tw9zn8 root@pve-ansible
Creating SSH host key 'ssh_host_ed25519_key' - this may take some time ...
done: SHA256:pnZ88rbZKplcyx/ggEqlyaapjqdZqZGTHdZ5xdamBF0 root@pve-ansible
Creating SSH host key 'ssh_host_ecdsa_key' - this may take some time ...
done: SHA256:3dIX17gqd3aEpzDWDKNHmO9IE/NPMEztQaD4+SHLxFg root@pve-ansible
TASK OK
```

## Key facts extracted

| Field | Value |
| --- | --- |
| Container | CT `409` (`pve-ansible`) |
| Base template | `debian-12-turnkey-ansible_18.0-1_amd64` |
| Root disk | `vm-409-disk-0`, filesystem UUID `92bbb1f7-abcd-422b-9ba7-084af06895eb` |
| SSH host key (RSA) | `SHA256:A2lIA72XM9pM+1FbAj2a+IxKa4RfVElHl0Bp8tw9zn8` |
| SSH host key (ED25519) | `SHA256:pnZ88rbZKplcyx/ggEqlyaapjqdZqZGTHdZ5xdamBF0` |
| SSH host key (ECDSA) | `SHA256:3dIX17gqd3aEpzDWDKNHmO9IE/NPMEztQaD4+SHLxFg` |

Not yet cross-checked against the currently live host keys on CT409 as of
this capture — if a future session needs to verify CT409 hasn't been
silently rebuilt or MITM'd, compare these fingerprints against live
`ssh-keyscan` / `/etc/ssh/ssh_host_*_key.pub` output.
