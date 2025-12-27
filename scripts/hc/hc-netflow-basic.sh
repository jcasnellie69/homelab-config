#!/usr/bin/env bash
#===================================================================
# DATE       CHGID    REASON                               USER  SYSTEM
# 2025-12-11 CR-0104  NetFlow basic freshness check        JOE   PVE
# 2025-12-11 CR-0105  Auto-scan LXCs for NetFlow cache     JOE   PVE
#===================================================================

set -euo pipefail

CHECK_DIR="/var/cache/nfdump"
FRESH_THRESHOLD_SEC=600  # 10 minutes

echo "NetFlow Basic Health Check"
echo "Timestamp: $(date -Iseconds)"
echo "Check dir: ${CHECK_DIR}"
echo "Freshness threshold: ${FRESH_THRESHOLD_SEC}s"
echo

check_local() {
  echo "--- Local host (${HOSTNAME}) ---"
  if [ ! -d "${CHECK_DIR}" ]; then
    echo "[INFO] Local NetFlow cache directory not found: ${CHECK_DIR}"
    echo
    return 1
  fi

  echo "=== Recent NetFlow files (tail) ==="
  find "${CHECK_DIR}" -type f -name "nfcapd.*" -printf '%TY-%Tm-%Td %TH:%TM:%TS %p\n' \
    2>/dev/null | sort | tail -n 10
  echo

  local latest_line
  latest_line="$(find "${CHECK_DIR}" -type f -name 'nfcapd.*' -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -n 1 || true)"

  if [ -z "${latest_line}" ]; then
    echo "[WARN] No nfcapd.* files found under ${CHECK_DIR} on host."
    echo
    return 0
  fi

  local latest_ts_float latest_file now_ts age_sec
  latest_ts_float="${latest_line%% *}"
  latest_file="${latest_line#* }"
  now_ts="$(date +%s)"
  age_sec="$(awk -v now="${now_ts}" -v ts="${latest_ts_float}" 'BEGIN { printf "%.0f", now-ts }')"

  echo "Latest file  : ${latest_file}"
  echo "Age (seconds): ${age_sec}"
  echo

  if [ "${age_sec}" -le "${FRESH_THRESHOLD_SEC}" ]; then
    echo "[OK] NetFlow collector (HOST) appears FRESH (<= ${FRESH_THRESHOLD_SEC}s)."
  else
    echo "[WARN] NetFlow collector (HOST) appears STALE (> ${FRESH_THRESHOLD_SEC}s)."
    echo "       Verify exporter/collector config if this persists."
  fi

  echo
}

check_container() {
  local ctid="$1"
  echo "--- Container CTID=${ctid} ---"

  # Does the dir exist inside the container?
  if ! pct exec "${ctid}" -- test -d "${CHECK_DIR}" 2>/dev/null; then
    echo "[INFO] CTID=${ctid}: ${CHECK_DIR} not found."
    echo
    return 1
  fi

  # Inline script executed inside the container
  pct exec "${ctid}" -- bash -lc '
CHECK_DIR="'"${CHECK_DIR}"'"
FRESH_THRESHOLD_SEC="'"${FRESH_THRESHOLD_SEC}"'"

echo "NetFlow cache directory found in container."
echo "Container timestamp: $(date -Iseconds)"
echo "Check dir: ${CHECK_DIR}"
echo "Freshness threshold: ${FRESH_THRESHOLD_SEC}s"
echo

echo "=== Recent NetFlow files (tail) ==="
find "${CHECK_DIR}" -type f -name "nfcapd.*" -printf "%TY-%Tm-%Td %TH:%TM:%TS %p\n" \
  2>/dev/null | sort | tail -n 10
echo

latest_line="$(find "${CHECK_DIR}" -type f -name "nfcapd.*" -printf "%T@ %p\n" 2>/dev/null | sort -n | tail -n 1 || true)"

if [ -z "${latest_line}" ]; then
  echo "[WARN] No nfcapd.* files found under ${CHECK_DIR}."
  echo
  exit 0
fi

latest_ts_float="${latest_line%% *}"
latest_file="${latest_line#* }"

now_ts="$(date +%s)"
age_sec="$(awk -v now="${now_ts}" -v ts="${latest_ts_float}" "BEGIN { printf \"%.0f\", now-ts }")"

echo "Latest file  : ${latest_file}"
echo "Age (seconds): ${age_sec}"
echo

if [ "${age_sec}" -le "${FRESH_THRESHOLD_SEC}" ]; then
  echo "[OK] NetFlow collector (CONTAINER) appears FRESH (<= ${FRESH_THRESHOLD_SEC}s)."
else
  echo "[WARN] NetFlow collector (CONTAINER) appears STALE (> ${FRESH_THRESHOLD_SEC}s)."
  echo "       Verify exporter/collector config if this persists."
fi
'
  echo
}

# 1) Try local host first
HOSTNAME="$(hostname)"
check_local || true

# 2) Scan containers if available
if command -v pct >/dev/null 2>&1; then
  echo "Scanning containers for ${CHECK_DIR}..."
  echo

  while read -r ctid status rest; do
    [ "${ctid}" = "VMID" ] && continue
    [ -z "${ctid}" ] && continue
    check_container "${ctid}" || true
  done < <(pct list)
else
  echo "[INFO] pct command not found; skipping container scan."
fi

echo "NetFlow basic HC complete."
