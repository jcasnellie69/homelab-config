# MokerLink Switch — Known-Good Baseline

    #---------------------------------------------------------------------------
    # DATE       | CHGID    | REASON
    # 2026-08-24 | CR-0022  | Capture verified switch baseline after factory
    #            |          | reset. Prior VLAN work required a reset, which
    #            |          | wiped SNMP and the RTC. This is the rollback
    #            |          | reference for future VLAN / OPNsense changes.
    # USER: JC   | TARGET: MokerLink 10G04810GSM (192.168.4.2)
    #---------------------------------------------------------------------------

All values below were read **live over SNMP v2c** on 2026-08-24, not transcribed
from the web UI. Reproduce any of them with the walk commands at the bottom.

## Device

| Attribute | Value |
|-----------|-------|
| Model | 10G04810GSM |
| Management IP | 192.168.4.2 |
| MAC | 1C:2A:A3:1E:B1:B7 |
| Serial | 208562410280025 |
| System OID | 1.3.6.1.4.1.27282.1.3 |
| Firmware | 1.1.1.23 (Jul 04 2024) |
| SNMP | v2c enabled, community `moker` (read-only) |

> **`public` has been removed.** Only `moker` answers polls. Netdata's SNMP
> service-discovery job (`go.d:sd:snmp:base`) still carries `community: public`
> in its credentials — update it to `moker` before enabling discovery, or it
> will find nothing.

## VLAN configuration — flat

| Setting | Value |
|---------|-------|
| VLANs defined | **VLAN 1 (`default`) only** |
| Egress ports, VLAN 1 | 1–12 and LAG 1–8 |
| Untagged ports, VLAN 1 | 1–12 and LAG 1–8 (**all**) |
| PVID | 1 on every port |

Because only VLAN 1 exists and every port is untagged, **port "trunk" mode is
functionally identical to access mode** on this switch today — there is nothing
to tag. Changing port mode without first defining a second VLAN accomplishes
nothing and risks black-holing management access.

## Port map — derived from the forwarding database

Ground truth from `dot1dTpFdbTable` joined against the ARP table on alpha.
**This supersedes the port labels in `network-inventory.json`, which are wrong.**

| Port | Link | Speed | MACs | What is actually attached |
|------|------|-------|------|---------------------------|
| TE1 | DOWN | — | 1 | switch's own management MAC |
| TE2 | up | 2500 Mb/s | 3 | **charlie** + pihole (.208) + Homeassistant (.206) |
| TE3 | up | 2500 Mb/s | 6 | **pve.node.local** (.249, dual NIC) + .252, .26, .63, .232 |
| TE4 | up | 2500 Mb/s | 10 | **alpha** + all nine Proxmox guest NICs |
| TE5 | up | — | 15 | **eero** (.1) |
| TE6 | DOWN | — | 0 | — |
| TE7 | up | — | **80** | downstream aggregation (IoT-heavy) |
| TE8–TE12 | DOWN | — | 0 | — |

Total: 115 MACs learned, 50 with a resolvable IP, 5 of 12 ports up.

Alpha is identified on TE4 by `38:05:25:33:ed:66`, which matches its `vmbr0`
link-local `fe80::3a05:25ff:fe33:ed66`.

## Health — all counters clean

| Port | inErr | outErr | inDisc | outDisc | in GB | out GB |
|------|-------|--------|--------|---------|-------|--------|
| TE2 | 0 | 0 | 0 | 0 | 3.30 | 2.03 |
| TE3 | 0 | 0 | 0 | 0 | 3.55 | 1.32 |
| TE4 | 0 | 0 | 0 | 0 | 1.19 | 0.42 |
| TE5 | 0 | 0 | 0 | 0 | 2.06 | 2.40 |
| TE7 | 0 | 0 | 0 | 0 | 2.12 | 2.76 |

Zero errors and zero discards across all 12 ports. Any device-level errors
observed elsewhere on the network do **not** originate at this switch.

## Known issues

| Issue | Detail |
|-------|--------|
| **FAN2** | Reads **82 RPM** vs FAN1 at 5601 RPM — stalled or failing. Temps currently OK (CPU 53.75 °C, chassis 45.50 °C). |
| **Clock** | Reported `2024-01-02 UTC+8` against a real date of 2026-08-24. No NTP configured; RTC resets on power loss. |
| **Startup config** | SNMP had been configured and working before the VLAN work; the factory reset that followed wiped it along with the RTC. Re-enabled 2026-08-24 and **written to startup-config** (applied, then saved). |

## SNMP trap configuration

The switch sends SNMPv2 traps/informs to the destinations below. Traps are
**push-only on UDP 162** and are unrelated to polling; a trap destination with
no listener silently discards.

| Destination | Type | Status |
|-------------|------|--------|
| 192.168.4.10 (alpha) | Trap | **keep** — netdata `snmp_traps` job will listen here |
| 192.168.4.114 (netbox) | Trap + Inform | remove — nothing listens on udp/162 |
| 192.168.4.210 (prometheus) | Trap + Inform | remove — nothing listens on udp/162 |

Trap events enabled: Authentication Failure, Link Up/Down, Cold Start, Warm Start.

## Reproducing this baseline

Scripts are pure-Python SNMP (no `net-snmp` needed; none is installed on alpha):

    python3 snmpwalk.py 192.168.4.2 moker    # ifTable: descr, status, speed
    python3 vlan.py     192.168.4.2 moker    # VLAN table, untagged sets, PVID
    python3 fdb.py      192.168.4.2 moker    # forwarding DB joined to ARP
    python3 errors.py   192.168.4.2 moker    # per-port error/discard counters

Re-run after any switch change and diff against this page.
