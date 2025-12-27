#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# DATE       | CHGID   | REASON
# 2025-12-10 | CR-0021 | LXC systemd health-check; write artifacts to shared
#                      | /srv/artifacts repository for evidence.
# USER: JC  | TARGET: PVE host (LXC systemd survey)
#-------------------------------------------------------------------------------

set -euo pipefail

ARTIFACT_ROOT="/srv/artifacts"          # default shared repository
SUBDIR="hc-lxc-systemd"
TS="$(date +%Y-%m-%d-%H%M%S)"

OUTDIR="${ARTIFACT_ROOT}/${SUBDIR}/${TS}"
SUMMARY="${OUTDIR}/summary-ct-systemd-${TS}.txt"

START_ID="${1:-100}"
END_ID="${2:-110}"

mkdir -p "${OUTDIR}"

{
  echo "CTID range: ${START_ID}..${END_ID}"
} > "${SUMMARY}"

for CTID in $(seq "${START_ID}" "${END_ID}"); do
  echo "=== CT ${CTID} ===" | tee -a "${SUMMARY}"

  # Check if container exists
  if ! pct status "${CTID}" &>/dev/null; then
    echo "  CT ${CTID} does not exist, skipping." | tee -a "${SUMMARY}"
    echo >> "${SUMMARY}"
    continue
  fi

  # Is it running?
  STATUS="$(pct status "${CTID}" | awk '{print $2}')"
  if [ "${STATUS}" != "running" ]; then
    echo "  CT ${CTID} is not running (status=${STATUS}), skipping." | tee -a "${SUMMARY}"
    echo >> "${SUMMARY}"
    continue
  fi

  echo "  collecting systemd service list..." | tee -a "${SUMMARY}"

  CT_OUTFILE="${OUTDIR}/ct-${CTID}-systemd-list.txt"
  pct exec "${CTID}" -- bash -lc 'systemctl list-units --all --type=service --no-pager' \
    > "${CT_OUTFILE}" 2>&1 || true

  # Extract failed/activating units
  FAILED="$(awk 'NR>1 && ($3 ~ /failed/ || $3 ~ /activating/){print}' "${CT_OUTFILE}")"

  if [ -n "${FAILED}" ]; then
    echo "  failed/activating units:" | tee -a "${SUMMARY}"
    echo "${FAILED}" | sed 's/^/    /' | tee -a "${SUMMARY}"
  else
    echo "  no failed/activating units found." | tee -a "${SUMMARY}"
  fi

  echo >> "${SUMMARY}"
done

echo "Artifacts written to: ${OUTDIR}"
