#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# DATE       | CHGID   | REASON
# 2025-12-10 | CR-0022 | Generate Markdown index of /srv/artifacts for HC use.
# USER: JC   | TARGET: Homelab (PVE host)
#-------------------------------------------------------------------------------

set -euo pipefail

OUT_FILE="${HOME}/homelab-config/docs/artifacts-index.md"

{
  echo "# Artifacts Index (/srv/artifacts)"
  echo "#-------------------------------------------------------------------------------"
  echo "# Auto-generated view of key health-check and telemetry artifacts."
  echo
  date_str=$(date -Is)
  echo "_Last generated: ${date_str}_"
  echo
  echo "## Top-level layout"
  echo
  echo '```text'
  find /srv/artifacts -maxdepth 1 -mindepth 1 -type d -printf "%P/\n" 2>/dev/null | sort
  echo '```'
  echo

  for d in hc-lxc-systemd netify-config pve-guest-snapshots hc-netflow hc-pihole; do
    if [ -d "/srv/artifacts/${d}" ]; then
      echo "## ${d}"
      echo
      echo '```text'
      find "/srv/artifacts/${d}" -maxdepth 2 -type f -printf "%P\n" 2>/dev/null | sort | head -n 200
      echo '```'
      echo
    fi
  done
} > "${OUT_FILE}"
