#!/usr/bin/env bash
# pve_hc_script.sh v0.5 — Proxmox Node + Guests Health Check
# Output: $HOME/homelab-config/reports/pve_hc-YYYYmmdd-HHMMSS.txt

set -euo pipefail
PATH=/usr/sbin:/sbin:/usr/bin:/bin

TS="$(date +%Y%m%d-%H%M%S)"
OUTDIR="$HOME/homelab-config/reports"
OUT="$OUTDIR/pve_hc-$TS.txt"
mkdir -p "$OUTDIR"

crit=0
warn=0
hr() { printf '%*s\n' 80 | tr ' ' '-'; }
sect() { hr | tee -a "$OUT"; echo "# $1" | tee -a "$OUT"; hr | tee -a "$OUT"; }
toGi() { awk -v k="$1" 'BEGIN{printf "%.1fGi", k/1048576}'; }   # k = KiB

mem_kib() { awk "/^$1:/{print \$2}" /proc/meminfo; }  # e.g., mem_kib MemTotal
mem_summary() {
  local mt ma mu
  mt=$(mem_kib MemTotal)
  ma=$(mem_kib MemAvailable)
  mu=$((mt - ma))
  echo "$(toGi "$mt") total, $(toGi "$mu") used, $(toGi "$ma") free"
}
swap_summary() {
  local st sf su
  st=$(mem_kib SwapTotal)
  sf=$(mem_kib SwapFree)
  su=$((st - sf))
  echo "$(toGi "$st") total, $(toGi "$su") used, $(toGi "$sf") free"
}

# --- Node overview ---
sect "NODE OVERVIEW"
{
  echo "Timestamp: $(date -Is)"
  echo "Hostname: $(hostname)"
  echo "Uptime: $(uptime -p)"
  echo "Load avg: $(cut -d' ' -f1-3 /proc/loadavg)"
  echo "Memory: $(mem_summary)"
  echo "Swap: $(swap_summary)"
} | tee -a "$OUT"

# --- Top memory procs ---
sect "TOP MEMORY PROCESSES"
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -n 15 | tee -a "$OUT"

# --- PVE services ---
sect "PVE SERVICES"
for s in pvestatd pvedaemon pveproxy pve-cluster; do
  st="$(systemctl is-active "$s" || true)"
  [[ "$st" != "active" ]] && crit=1
  printf "%-14s : %s\n" "$s" "$st" | tee -a "$OUT"
done

# --- Storage ---
sect "STORAGE"
pvesm status | tee -a "$OUT"
df -h -x tmpfs -x devtmpfs | tee -a "$OUT"

# --- ZFS & ARC cap check ---
if command -v zpool >/dev/null 2>&1; then
  sect "ZFS STATUS"
  zpool status -x | tee -a "$OUT" || true
  if ! zpool status -x | grep -q "all pools are healthy"; then crit=1; fi
  zpool list -v | tee -a "$OUT"

  sect "ZFS ARC CONFIG"
  host_total_kib=$(mem_kib MemTotal)
  arc_runtime=""
  arc_persist=""
  if [[ -r /sys/module/zfs/parameters/zfs_arc_max ]]; then
    arc_runtime=$(cat /sys/module/zfs/parameters/zfs_arc_max 2>/dev/null || true)
  fi
  if [[ -f /etc/modprobe.d/zfs.conf ]]; then
    arc_persist=$(grep -Eo 'zfs_arc_max[=][0-9]+' /etc/modprobe.d/zfs.conf | head -n1 | cut -d= -f2 || true)
  fi
  # Defaults: if empty or "0", it's effectively unlimited (subject to ZFS heuristics)
  [[ -z "${arc_runtime:-}" || "$arc_runtime" = "0" ]] && { echo "WARN: ARC runtime cap not set (unbounded)."; warn=$((warn+1)); } | tee -a "$OUT"
  [[ -z "${arc_persist:-}" || "$arc_persist" = "0" ]] && { echo "WARN: ARC persistent cap not set in /etc/modprobe.d/zfs.conf."; warn=$((warn+1)); } | tee -a "$OUT"

  if [[ -n "${arc_runtime:-}" && "$arc_runtime" != "0" ]]; then
    # Compare runtime cap to 25% host RAM
    quarter=$(( host_total_kib * 1024 / 4 ))   # meminfo in KiB; arc_max is bytes
    if (( arc_runtime > quarter )); then
      echo "WARN: ARC runtime cap ($(awk -v b=$arc_runtime 'BEGIN{printf \"%.1fGi\", b/1073741824}')) > 25% of host RAM ($(toGi $((host_total_kib/4))) )." | tee -a "$OUT"
      warn=$((warn+1))
    else
      echo "ARC runtime cap within safe range." | tee -a "$OUT"
    fi
  fi
  if [[ -n "${arc_persist:-}" && "$arc_persist" != "0" ]]; then
    quarter=$(( host_total_kib * 1024 / 4 ))
    if (( arc_persist > quarter )); then
      echo "WARN: ARC persistent cap ($(awk -v b=$arc_persist 'BEGIN{printf \"%.1fGi\", b/1073741824}')) > 25% of host RAM ($(toGi $((host_total_kib/4))) )." | tee -a "$OUT"
      warn=$((warn+1))
    else
      echo "ARC persistent cap within safe range." | tee -a "$OUT"
    fi
  fi
fi

# --- SMART (physical only: NVMe & SATA) ---
sect "SMART OVERALL"
if command -v smartctl >/dev/null 2>&1; then
  for tgt in /dev/nvme*n1 /dev/sd[a-z]; do
    [ -e "$tgt" ] || continue
    echo "== $tgt ==" | tee -a "$OUT"
    smartctl -H "$tgt" 2>/dev/null | tee -a "$OUT" || true
  done
else
  echo "smartctl not installed" | tee -a "$OUT"
fi

# --- Kernel OOMs last 24h ---
sect "OOM EVENTS (last 24h)"
if command -v journalctl >/dev/null 2>&1; then
  journalctl -k --since "24 hours ago" | grep -iE "out of memory|oom-killer|Killed process" \
    | tee -a "$OUT" || true
else
  dmesg | grep -iE "out of memory|oom-killer|Killed process" | tee -a "$OUT" || true
fi

# --- Guests: configs & limits ---
sect "GUEST LIMITS (VMs)"
if command -v qm >/dev/null 2>&1; then
  printf "%-6s %-18s %-8s %-8s\n" "VMID" "NAME" "MEM(MB)" "BALLOON" | tee -a "$OUT"
  while read -r VMID NAME STATUS MEM BOOTDISK PID; do
    [[ "$VMID" == "VMID" || -z "$VMID" ]] && continue
    cname="$(qm config "$VMID" | awk -F': ' '/^name:/{print $2; exit}')"
    mem="$(qm config "$VMID" | awk -F': ' '/^memory:/{print $2; exit}')"
    bal="$(qm config "$VMID" | awk -F': ' '/^balloon:/{print $2; exit}')"
    printf "%-6s %-18s %-8s %-8s\n" "$VMID" "${cname:-$NAME}" "${mem:-0}" "${bal:-0}" | tee -a "$OUT"
    if [[ -z "${mem:-}" || "$mem" = "0" ]]; then
      echo "WARN: VM $VMID (${cname:-$NAME}) has no explicit memory limit." | tee -a "$OUT"
      warn=$((warn+1))
    fi
  done < <(qm list)
else
  echo "qm not found" | tee -a "$OUT"
fi

sect "GUEST LIMITS (LXCs)"
if command -v pct >/dev/null 2>&1; then
  printf "%-6s %-22s %-8s %-8s\n" "CTID" "NAME" "MEM(MB)" "SWAP(MB)" | tee -a "$OUT"
  while read -r CTID STATUS LOCK NAME REST; do
    [[ "$CTID" == "VMID" || -z "$CTID" ]] && continue
    mem="$(pct config "$CTID" | awk -F': ' '/^memory:/{print $2; exit}')"
    swap="$(pct config "$CTID" | awk -F': ' '/^swap:/{print $2; exit}')"
    printf "%-6s %-22s %-8s %-8s\n" "$CTID" "$NAME" "${mem:-0}" "${swap:-0}" | tee -a "$OUT"
    if [[ -z "${mem:-}" || "$mem" = "0" ]]; then
      echo "WARN: LXC $CTID ($NAME) has no explicit memory cap." | tee -a "$OUT"
      warn=$((warn+1))
    fi
  done < <(pct list)
else
  echo "pct not found" | tee -a "$OUT"
fi

# --- Summary ---
sect "SUMMARY"
if (( crit > 0 )); then
  echo "Overall: CRITICAL issues found" | tee -a "$OUT"
else
  echo "Overall: OK" | tee -a "$OUT"
fi
echo "Warnings: $warn" | tee -a "$OUT"
echo "Report: $OUT" | tee -a "$OUT"
