#!/usr/bin/env bash
set -euo pipefail

# Validate environment for homelab collection/publish
ARTIFACT_BASE=${ARTIFACT_BASE:-/srv/artifacts/hc}

echo "[hc-validate] Checking artifact base: ${ARTIFACT_BASE}"
if [ ! -d "${ARTIFACT_BASE}" ]; then
  echo "[hc-validate] Creating artifact base: ${ARTIFACT_BASE}"
  mkdir -p "${ARTIFACT_BASE}"
fi

if [ ! -w "${ARTIFACT_BASE}" ]; then
  echo "ERROR: ${ARTIFACT_BASE} is not writable by $(id -u -n)" >&2
  exit 2
fi

echo "[hc-validate] Checking git status"
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Not inside a git repo" >&2
  exit 3
fi

echo "[hc-validate] Checking required utilities"
for cmd in hostname date uname ss df lsblk ssh awk sed; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[hc-validate] Warning: $cmd not found in PATH" >&2
  fi
done

echo "[hc-validate] Validation complete"
exit 0
