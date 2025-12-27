#!/usr/bin/env bash
#===================================================================
# DATE       CHGID    REASON                               USER  SYSTEM
# 2025-12-11 CR-0103  HC for ZFS pools                     JOE   PVE
#===================================================================

set -euo pipefail

echo "ZFS Storage Health Check"
echo "Timestamp: $(date -Iseconds)"
echo

if ! command -v zpool >/dev/null 2>&1; then
  echo "[WARN] zpool command not found; skipping ZFS checks."
  exit 0
fi

echo "=== zpool list ==="
zpool list || echo "[WARN] zpool list failed"
echo

echo "=== zpool status ==="
zpool status || echo "[WARN] zpool status failed"
echo

echo "Notes:"
echo " - Later we can parse health, errors, and thresholds."
echo " - For now, this dumps baseline info into HC artifacts."
