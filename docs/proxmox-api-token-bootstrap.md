# Proxmox API Token Bootstrap

## Purpose

Bootstrap a least-privilege Proxmox API token for OPNsense VM lifecycle
automation and store it in Semaphore Key Store as:

```text
pve-opnsense-api-token
```

This is required because Proxmox API credentials do not exist yet. The initial
bootstrap uses SSH to `alpha`, then switches future automation to API tokens.

## Generated Workflow

Script:

```bash
deploy/ansible/scripts/bootstrap-pve-opnsense-api-token.sh
```

Defaults:

| Setting | Value |
| --- | --- |
| SSH target | `root@192.168.4.10` |
| SSH key override | `PVE_SSH_KEY` |
| SSH jump host override | `PVE_SSH_PROXYJUMP` |
| Proxmox user | `ansible@pve` |
| Token | `ansible@pve!opnsense-automation` |
| Role | `HomelabOPNsenseAutomation` |
| VM ACL path | `/vms` |
| Storage ACL paths | `/storage/local`, `/storage/local-lvm` |
| Semaphore key | `pve-opnsense-api-token` |

Role privileges:

```text
Datastore.AllocateSpace
Datastore.Audit
Sys.Audit
VM.Allocate
VM.Audit
VM.Config.CDROM
VM.Config.CPU
VM.Config.Disk
VM.Config.HWType
VM.Config.Memory
VM.Config.Network
VM.Config.Options
VM.PowerMgmt
SDN.Use
```

`SDN.Use` was added D072826 (`CHG-OPNSENSE-SYNC-001`) after being deliberately
deferred in the original bootstrap — it's required for the Ansible pipeline
to manage VM networking end-to-end, not just VM shell CRUD.

## Run

Use an authenticated Semaphore API session or provide Semaphore login variables:

```bash
export SEMAPHORE_USER=admin
export SEMAPHORE_PASSWORD='<admin-password>'
deploy/ansible/scripts/bootstrap-pve-opnsense-api-token.sh
```

If the token already exists, the script stops without rotating it. To rotate:

```bash
ROTATE_TOKEN=1 deploy/ansible/scripts/bootstrap-pve-opnsense-api-token.sh
```

If a usable key exists on another reachable LXC, run the script from that LXC
or point to a mounted/key path without committing the key:

```bash
PVE_SSH_KEY=/path/to/id_rsa \
  deploy/ansible/scripts/bootstrap-pve-opnsense-api-token.sh
```

If alpha is reachable only through a jump host:

```bash
PVE_SSH_PROXYJUMP=root@192.168.4.76 \
  PVE_SSH_KEY=/path/to/id_rsa \
  deploy/ansible/scripts/bootstrap-pve-opnsense-api-token.sh
```

## Secret Handling

- The token secret is captured from `pveum user token add`.
- The token secret is sent directly to Semaphore Key Store.
- The token secret is not written to Git.
- The token secret is not written to committed artifacts.
- Script output redacts the token secret.

## Validation

The script validates authenticated API access with:

```bash
curl -sk \
  -H "Authorization: PVEAPIToken=ansible@pve!opnsense-automation=<secret>" \
  https://192.168.4.10:8006/api2/json/version
```

Manual non-secret validation:

```bash
pveum user list | grep 'ansible@pve'
pveum user token list ansible@pve
pveum acl list | grep -E 'ansible@pve|opnsense-automation|HomelabOPNsenseAutomation'
```

## Rollback

Run on `alpha`:

```bash
pveum user token remove ansible@pve opnsense-automation
pveum acl delete /vms --tokens ansible@pve!opnsense-automation
pveum acl delete /storage/local --tokens ansible@pve!opnsense-automation
pveum acl delete /storage/local-lvm --tokens ansible@pve!opnsense-automation
pveum acl delete /vms --users ansible@pve
pveum acl delete /storage/local --users ansible@pve
pveum acl delete /storage/local-lvm --users ansible@pve
pveum user delete ansible@pve
pveum role delete HomelabOPNsenseAutomation
```

Remove the Semaphore key through the UI or API after confirming its ID:

```bash
curl -b /tmp/semaphore-bootstrap-cookies.txt \
  http://127.0.0.1:3000/api/project/1/keys

curl -X DELETE -b /tmp/semaphore-bootstrap-cookies.txt \
  http://127.0.0.1:3000/api/project/1/keys/<key-id>
```

## Status (updated D072826, CHG-OPNSENSE-SYNC-001)

SSH from this control node (CT409) to `alpha` works and the bootstrap already
ran successfully in an earlier session (2026-05-30): the Proxmox user
`ansible@pve` and token `ansible@pve!opnsense-automation` both exist live
(`pveum user list` / `pveum user token list ansible@pve`). The SSH blocker
described below is historical — it applied to a different, now-superseded
orchestration LXC and no longer reflects current state. Do not re-run the
bootstrap script; it stops without rotating an existing token by default.

The `SDN.Use` privilege was deliberately left off the `HomelabOPNsenseAutomation`
role in that session to avoid an unapproved ACL change; it has since been
added (see role privileges table above) once explicitly approved.

### Historical blocker (resolved, kept for context)

SSH to `root@192.168.4.10` failed from an earlier orchestration LXC with:

```text
Permission denied (publickey,password).
```

Follow-up discovery found Portainer on `192.168.4.76:9443`, but SSH to
`root@192.168.4.76` was also blocked from that LXC at the time. If the
Proxmox SSH key is inside that Docker LXC, run this bootstrap from there or
provide a reachable jump/key path via `PVE_SSH_PROXYJUMP` and `PVE_SSH_KEY`.
