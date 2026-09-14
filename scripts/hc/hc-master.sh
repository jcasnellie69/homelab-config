#!/usr/bin/env bash
#===================================================================
# DATE       CHGID    REASON                               USER  SYSTEM
# 2025-12-11 CR-0101  HC master orchestrator               JOE   PVE
# 2026-07-12 CR-0413  Wire in pve-lxc-systemd-scan.sh (was  JC    PVE
#                      written but never called from here)
#                      and the new host+guest disk/failed-
#                      unit detail scan (hc-guest-disk-and-
#                      units.sh). Neither host disk/mem nor
#                      guest failed-unit state was checked
#                      by this orchestrator before.
#===================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ART_BASE="/srv/artifacts/hc"

STAMP="$(date +%Y%m%d-%H%M%S)"
HOSTNAME_SHORT="$(hostname)"
RUN_DIR="${ART_BASE}/${HOSTNAME_SHORT}-${STAMP}"

mkdir -p "${RUN_DIR}"

echo "=== HC MASTER ==="
echo "Host      : ${HOSTNAME_SHORT}"
echo "Run ID    : ${STAMP}"
echo "Artifacts : ${RUN_DIR}"
echo

run_step() {
  local name="$1"
  local script="$2"
  local outfile="$3"

  if [ ! -x "${script}" ]; then
    echo "[WARN] ${name}: script not found or not executable: ${script}"
    return 0
  fi

  echo "[HC] ${name} -> ${outfile}"
  {
    echo "=== ${name} ==="
    echo "Timestamp: $(date -Iseconds)"
    echo "Script   : ${script}"
    echo
    "${script}"
  } > "${outfile}" 2>&1 || echo "[WARN] ${name} exited non-zero (see ${outfile})"
}

run_step "PVE Guests"        "${BASE_DIR}/scripts/hc/hc-pve-guests.sh"           "${RUN_DIR}/pve-guests.txt"
run_step "Storage (ZFS)"     "${BASE_DIR}/scripts/hc/hc-storage-zfs.sh"          "${RUN_DIR}/storage-zfs.txt"
run_step "NetFlow Basic"     "${BASE_DIR}/scripts/hc/hc-netflow-basic.sh"        "${RUN_DIR}/netflow-basic.txt"
run_step "LXC Systemd Scan"  "${BASE_DIR}/scripts/hc/pve-lxc-systemd-scan.sh"    "${RUN_DIR}/lxc-systemd-scan.txt"
run_step "Guest Disk/Units"  "${BASE_DIR}/scripts/hc/hc-guest-disk-and-units.sh" "${RUN_DIR}/guest-disk-and-units.txt"

echo
echo "=== HC COMPLETE ==="
echo "Artifacts directory:"
echo "  ${RUN_DIR}"
