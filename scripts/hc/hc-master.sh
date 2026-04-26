#!/usr/bin/env bash
#===================================================================
# DATE       CHGID    REASON                               USER  SYSTEM
# 2025-12-11 CR-0101  HC master orchestrator               JOE   PVE
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

run_step "PVE Guests"     "${BASE_DIR}/scripts/hc/hc-pve-guests.sh"     "${RUN_DIR}/pve-guests.txt"
run_step "Storage (ZFS)"  "${BASE_DIR}/scripts/hc/hc-storage-zfs.sh"    "${RUN_DIR}/storage-zfs.txt"
run_step "NetFlow Basic"  "${BASE_DIR}/scripts/hc/hc-netflow-basic.sh"  "${RUN_DIR}/netflow-basic.txt"

echo
echo "=== HC COMPLETE ==="
echo "Artifacts directory:"
echo "  ${RUN_DIR}"
