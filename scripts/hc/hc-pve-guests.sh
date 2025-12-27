#!/usr/bin/env bash
#===================================================================
# DATE       CHGID    REASON                               USER  SYSTEM
# 2025-12-11 CR-0106  Add TYPE=LXC/VM, clean DESC/TAGS     JOE   PVE
#===================================================================

set -euo pipefail

echo "PVE Guest Inventory"
echo "Timestamp: $(date -Iseconds)"
echo

# ===============================================================
# LXC Containers
# ===============================================================
echo "=== LXC Containers ==="

pct list | awk 'NR>1 {print $1}' | while read -r ctid; do

  status=$(pct status "$ctid" | awk '{print $2}')
  hostname=$(pct exec "$ctid" -- hostname 2>/dev/null || echo "unknown")

  # Clean description: trim + strip %0A
  desc=$(
    pct config "$ctid" 2>/dev/null |
      grep -i ^description |
      cut -d: -f2- |
      sed 's/^ *//' |
      sed 's/%0A$//'
  )

  # Clean tags: trim + remove %0A + convert ; → ,
  tags=$(
    pct config "$ctid" 2>/dev/null |
      grep -i ^tags |
      cut -d: -f2- |
      sed 's/^ *//' |
      sed 's/%0A$//' |
      tr ';' ','
  )

  echo "VMID=$ctid TYPE=LXC HOSTNAME=$hostname STATUS=$status DESC=\"$desc\" TAGS=\"$tags\""
done

echo

# ===============================================================
# QEMU Virtual Machines
# ===============================================================
echo "=== QEMU Virtual Machines ==="

qm list | awk 'NR>1 {print $1}' | while read -r vmid; do

  status=$(qm status "$vmid" 2>/dev/null | awk '{print $2}')

  name=$(
    qm config "$vmid" 2>/dev/null |
      grep -i ^name |
      cut -d: -f2- |
      sed 's/^ *//'
  )

  desc=$(
    qm config "$vmid" 2>/dev/null |
      grep -i ^description |
      cut -d: -f2- |
      sed 's/^ *//'
  )

  tags=$(
    qm config "$vmid" 2>/dev/null |
      grep -i ^tags |
      cut -d: -f2- |
      sed 's/^ *//' |
      tr ';' ','
  )

  echo "VMID=$vmid TYPE=VM NAME=\"$name\" STATUS=$status DESC=\"$desc\" TAGS=\"$tags\""
done

echo
echo "Guest inventory complete."
