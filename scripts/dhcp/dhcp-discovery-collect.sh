#!/usr/bin/env bash
#-----------------------------------------------------------------------------
# Change Registry
# Date      ChangeID  Reason                         Init  Target
# D121525T???? CHG-001  DHCP discovery data capture    JC    PVE / LAN
#-----------------------------------------------------------------------------
set -euo pipefail

# ===== Defaults (override via env or flags) =====
SUBNET_DEFAULT="192.168.4.0/24"
ART_BASE_DEFAULT="/srv/artifacts/dhcp-discovery"
PIHOLE_CTID_DEFAULT=""   # optional (e.g., 109)

usage(){
  cat <<'EOT'
Usage: dhcp-discovery-collect.sh [-s <subnetCIDR>] [-o <artifact_dir>] [-p <pihole_ctid>] [-y]

  -s  Subnet CIDR to scan (default: 192.168.4.0/24)
  -o  Artifact base directory (default: /srv/artifacts/dhcp-discovery)
  -p  Pi-hole container CTID (optional; enables pct exec collection)
  -y  Non-interactive (no prompts)

Examples:
  ./dhcp-discovery-collect.sh
  ./dhcp-discovery-collect.sh -s 192.168.4.0/24 -p 109
EOT
}

SUBNET="$SUBNET_DEFAULT"
ART_BASE="$ART_BASE_DEFAULT"
PIHOLE_CTID="$PIHOLE_CTID_DEFAULT"
NONINTERACTIVE=0

while getopts ":s:o:p:yh" opt; do
  case "$opt" in
    s) SUBNET="$OPTARG" ;;
    o) ART_BASE="$OPTARG" ;;
    p) PIHOLE_CTID="$OPTARG" ;;
    y) NONINTERACTIVE=1 ;;
    h) usage; exit 0 ;;
    *) usage; exit 2 ;;
  esac
done

# ===== Timestamp (Joe style) =====
TS="D$(date +%m%d%yT%H%M)"
OUTDIR="${ART_BASE}/${TS}"
mkdir -p "$OUTDIR"

log(){ echo "[INFO] $*"; }
run(){
  local name="$1"; shift
  log "Collecting: ${name}"
  {
    echo "### CMD: $*"
    echo "### WHEN: $(date -Is)"
    echo "### HOST: $(hostname -f 2>/dev/null || hostname)"
    echo
    "$@"
  } > "${OUTDIR}/${name}.txt" 2>&1 || {
    echo "[WARN] Command failed for ${name}: $*" | tee -a "${OUTDIR}/_WARNINGS.txt"
    return 0
  }
}

log "Artifacts: ${OUTDIR}"
log "Subnet: ${SUBNET}"

# ====== PVE / host-level inventory ======
run "host_uname" uname -a
run "host_date" date
run "host_ip_addr" ip -br addr
run "host_ip_route" ip route
run "host_resolv" cat /etc/resolv.conf
run "host_hosts" cat /etc/hosts
run "host_arp" arp -an
run "host_ip_neigh" ip neigh

# Network bridges (common on PVE)
run "pve_brctl" bash -lc 'command -v brctl >/dev/null 2>&1 && brctl show || echo "brctl not installed"'
run "pve_bridge_links" bash -lc 'ip -d link show | sed -n "1,220p"'

# Proxmox inventories
run "pve_version" pveversion -v
run "pct_list" pct list
run "qm_list" qm list

# Capture PVE network config
run "pve_interfaces" cat /etc/network/interfaces

# Capture LXC and VM configs (summary + full)
run "pct_configs_summary" bash -lc 'for id in $(pct list | awk "NR>1{print \$1}"); do echo "==== CT $id ===="; pct config "$id"; echo; done'
run "qm_configs_summary" bash -lc 'for id in $(qm list | awk "NR>1{print \$1}"); do echo "==== VM $id ===="; qm config "$id"; echo; done'

# ====== Gap detection scan ======
run "nmap_sn" nmap -sn "$SUBNET"

# ====== Optional: pull Pi-hole-side evidence via pct exec ======
if [[ -n "$PIHOLE_CTID" ]]; then
  log "Pi-hole CTID provided: ${PIHOLE_CTID} (will collect via pct exec)"

  run "pihole_os_release" pct exec "$PIHOLE_CTID" -- bash -lc 'cat /etc/os-release'
  run "pihole_ip_addr" pct exec "$PIHOLE_CTID" -- bash -lc 'ip -br addr'
  run "pihole_resolv" pct exec "$PIHOLE_CTID" -- bash -lc 'cat /etc/resolv.conf'
  run "pihole_setupVars" pct exec "$PIHOLE_CTID" -- bash -lc 'ls -l /etc/pihole/setupVars.conf && sed -n "1,220p" /etc/pihole/setupVars.conf'
  run "pihole_dnsmasq_d" pct exec "$PIHOLE_CTID" -- bash -lc 'ls -la /etc/dnsmasq.d || true'
  run "pihole_dhcp_conf" pct exec "$PIHOLE_CTID" -- bash -lc 'for f in /etc/dnsmasq.d/*dhcp* /etc/dnsmasq.d/02-pihole-dhcp.conf; do [ -f "$f" ] && { echo "==== $f ===="; sed -n "1,260p" "$f"; echo; }; done'
  run "pihole_versions" pct exec "$PIHOLE_CTID" -- bash -lc 'command -v pihole >/dev/null 2>&1 && pihole -v || echo "pihole CLI not found"'
  run "pihole_status" pct exec "$PIHOLE_CTID" -- bash -lc 'command -v pihole >/dev/null 2>&1 && pihole status || echo "pihole CLI not found"'
fi

# ====== Human-required captures (cannot be scripted easily) ======
cat > "${OUTDIR}/_MANUAL_CAPTURE.txt" <<'EOT'
Manual captures (do these in parallel and save as screenshots or notes):

1) eero app
   - Settings → Network settings → DHCP & NAT (mode + range)
   - Reservations & Port Forwarding (full list)
   - Device list: hubs (Apple TV, Aqara, Aeotec) + cameras

2) Pi-hole UI
   - Tools → Network (export/copy)
   - Settings → DHCP → Active leases (if DHCP enabled)

Paste/record key outputs into the Working Inventory table in dhcp-discovery.md.
EOT

log "Done. Review: ${OUTDIR}"
