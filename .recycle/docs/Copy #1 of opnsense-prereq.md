# OPNsense Prerequisites

## Status

- **NETWORK:** `BLOCKED`
- **Why:** the management plane is healthy, but the dedicated 10G port for the
  data-plane trunk has not yet been confirmed live from the Proxmox shell.

## Confirmed safe baseline

- `vmbr0` is the active management bridge and must remain untouched.
- `192.168.4.10` is the live management endpoint for `alpha`.
- The new VLAN trunk bridge must be built as **`vmbr1`** with **no IP assigned**.

## Required live discovery on `alpha`

Run these directly on the Proxmox node or through an authenticated shell:

```bash
pct list
ip -br link
bridge link show
bridge vlan show
for nic in nic2 nic3; do
  echo "=== $nic ==="
  ethtool "$nic" | egrep 'Speed|Duplex|Link detected'
done
```

## What to confirm

1. `nic0` is still the management path behind `vmbr0`
2. `nic2` and `nic3` are the Intel X710-facing 10G candidates
3. whichever port changes from `DOWN` to `UP` when the 10G cable is connected is
   the correct uplink for `vmbr1`

## Proposed `vmbr1` snippet

Use the port that proves live (`nic2` **or** `nic3`):

```ini
# dedicated 10G uplink, no IP
iface nic2 inet manual

auto vmbr1
iface vmbr1 inet manual
    bridge-ports nic2
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 2-4094
```

If `nic3` is the port that comes up, substitute `nic3` for `nic2`.

## Validation after creation

```bash
ip -br link show vmbr1
bridge link show
bridge vlan show dev vmbr1
```

Expected result:

- `vmbr1` exists
- the attached 10G port is `UP` when linked
- `vmbr1` is VLAN-aware and has **no** IP address

## Safety rules

- Do **not** change `vmbr0`
- Do **not** assign an IP to `vmbr1`
- Do **not** apply the bridge until the active 10G uplink is positively identified
