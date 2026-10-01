#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# DATE       | CHGID   | REASON
# 2025-12-10 | CR-0021 | LXC systemd health-check; write artifacts to shared
#                      | /srv/artifacts repository for evidence.
# 2026-07-12 | CR-0410 | Fix failed-unit detection: systemctl prefixes a bullet
#                      | column on units needing attention, which silently
#                      | shifted the old $3-based awk filter off the ACTIVE
#                      | column so it never matched a real failure. Now asks
#                      | systemctl to filter by state directly instead of
#                      | parsing column position. Wired into hc-master.sh.
# 2026-07-12 | CR-0417 | bash -lc -> bash -c: -lc invoked a login shell,
#                      | which triggers these containers' MOTD banners
#                      | (community-scripts ANSI-art greeting) ahead of the
#                      | real systemctl output in every captured artifact.
# USER: JC  | TARGET: PVE host (LXC systemd survey)
#-------------------------------------------------------------------------------

set -euo pipefail

ARTIFACT_ROOT="/srv/artifacts"          # default shared repository
SUBDIR="hc-lxc-systemd"
TS="$(date +%Y-%m-%d-%H%M%S)"

OUTDIR="${ARTIFACT_ROOT}/${SUBDIR}/${TS}"
SUMMARY="${OUTDIR}/summary-ct-systemd-${TS}.txt"

START_ID="${1:-100}"
END_ID="${2:-410}"

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
  pct exec "${CTID}" -- bash -c 'LC_ALL=C systemctl list-units --all --type=service --no-pager' \
    > "${CT_OUTFILE}" 2>&1 || true

  # Ask systemctl to filter by state directly rather than parsing column
  # position from the full listing above (see CR-0410 header note).
  FAILED="$(pct exec "${CTID}" -- bash -c \
    'LC_ALL=C systemctl list-units --all --type=service --state=failed,activating --no-legend --no-pager 2>/dev/null' \
    || true)"

  if [ -n "${FAILED}" ]; then
    echo "  failed/activating units:" | tee -a "${SUMMARY}"
    echo "${FAILED}" | sed 's/^/    /' | tee -a "${SUMMARY}"
  else
    echo "  no failed/activating units found." | tee -a "${SUMMARY}"
  fi

  echo >> "${SUMMARY}"
done

echo "Artifacts written to: ${OUTDIR}"
