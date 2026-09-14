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
# 2026-09-14 | CR-0420 | Code-review follow-up: enumerate CTs from `pct list`
#                      | instead of probing a fixed 100..410 seq. A CT
#                      | created above the cap was silently skipped, and
#                      | ~300 non-existent IDs were probed and logged on
#                      | every run. The optional START/END args are kept
#                      | but now filter the real list rather than define it.
#                      | Signed: p.p. claude-opus-5 for JC
# USER: JC  | TARGET: PVE host (LXC systemd survey)
#-------------------------------------------------------------------------------

set -euo pipefail

ARTIFACT_ROOT="/srv/artifacts"          # default shared repository
SUBDIR="hc-lxc-systemd"
TS="$(date +%Y-%m-%d-%H%M%S)"

OUTDIR="${ARTIFACT_ROOT}/${SUBDIR}/${TS}"
SUMMARY="${OUTDIR}/summary-ct-systemd-${TS}.txt"

# Optional CTID bounds. Empty means unbounded; the set of CTs scanned is
# whatever `pct list` reports, not this range (see CR-0420 header note).
START_ID="${1:-}"
END_ID="${2:-}"

mkdir -p "${OUTDIR}"

{
  if [ -n "${START_ID}" ] || [ -n "${END_ID}" ]; then
    echo "CTID filter: ${START_ID:-min}..${END_ID:-max} (applied to pct list)"
  else
    echo "CTIDs: every container reported by pct list"
  fi
} > "${SUMMARY}"

pct list 2>/dev/null | awk 'NR>1 {print $1}' | while read -r CTID; do
  if [ -n "${START_ID}" ] && [ "${CTID}" -lt "${START_ID}" ]; then continue; fi
  if [ -n "${END_ID}" ]   && [ "${CTID}" -gt "${END_ID}" ];   then continue; fi

  echo "=== CT ${CTID} ===" | tee -a "${SUMMARY}"

  # Is it running? (|| true: a CT removed between pct list and here must not
  # abort the whole survey under set -e / pipefail.)
  STATUS="$(pct status "${CTID}" 2>/dev/null | awk '{print $2}' || true)"
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
