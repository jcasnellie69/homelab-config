# Network Live State

## Status

- **NETWORK:** `BLOCKED`
- **Reason:** the management path is live, but authenticated Proxmox shell and API
  access are still required to confirm the dedicated 10G data port (`nic2` or
  `nic3`) and validate the `vmbr1` trunk bridge end-to-end.

## Live checks executed

```powershell
Test-NetConnection 192.168.4.10 -Port 22
Test-NetConnection 192.168.4.10 -Port 8006
Invoke-WebRequest -SkipCertificateCheck https://192.168.4.10:8006/
ssh -o PreferredAuthentications=publickey -o PasswordAuthentication=no root@192.168.4.10 "hostname"
arp -a 192.168.4.10
```

## Actual current layout

| Path | Live finding | Status | Evidence |
| --- | --- | --- | --- |
| `nic0 -> vmbr0 -> 192.168.4.10` | Current management plane is live and serving the Proxmox UI | Confirmed | TCP `22` and `8006` succeed; Proxmox login page title shows `pve-plex-oasis-alpha` |
| `nic2` / `nic3` | Dedicated 10G port for the future trunk bridge | Unconfirmed | Requires live `ip -br link` + cable-link test from the Proxmox shell |
| `vmbr1` | Dedicated VLAN trunk bridge | Not observed in live-accessible data | Only `vmbr0` is present in the accessible evidence; `vmbr1` is prepared but not created |

## Important corrections to stale assumptions

1. The old `192.168.4.249` management address is now stale.
2. Historical `enp*` names in the December artifacts are no longer reliable as
   the source of truth for the current management path.
3. The live ARP identity for `192.168.4.10` is currently `38:05:25:33:ED:66`,
   which differs from the older hardware artifact mappings.
4. The `network-inventory` artifact currently places `192.168.4.10` on switch
   port `TE10` with `portType: SFP/SFP+ (10G)`, which supports the case for a
   dedicated 10G path even though the exact host-side `nic2` or `nic3` mapping
   is still blocked.

## Hard blocker for full NIC confirmation

The controller can reach the Proxmox host, but it cannot execute the required
live commands yet:

- `ssh root@192.168.4.10` returns **Permission denied**
- authenticated API endpoints return **401 (No ticket)**

Because of that, the following still need a live shell or console session on
`alpha` before they can be called fully confirmed:

- `pct list`
- `ip -br link`
- `bridge link show`
- `bridge vlan show`
- `ethtool nic2` / `ethtool nic3`
