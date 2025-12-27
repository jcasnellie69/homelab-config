#!/usr/bin/env bash
#===================================================================
# DATE       CHGID    REASON                             USER  SYSTEM
# 2025-12-11 CR-0002  Create ChatGPT session helper      JOE   PVE
#===================================================================

set -euo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SESSION_DOCS="${BASE_DIR}/docs/session-logs"
SESSION_LOGS="${BASE_DIR}/logs/sessions"

mkdir -p "${SESSION_DOCS}" "${SESSION_LOGS}"

if [ $# -lt 1 ]; then
  echo "Usage: $(basename "$0") <session-name>"
  echo "Example: $(basename "$0") netify-dpi-hardening"
  exit 1
fi

SESSION_NAME="$*"
STAMP="$(date +%Y%m%d-%H%M%S)"
DATE_ONLY="$(date +%Y-%m-%d)"

SAFE_NAME="$(echo "${SESSION_NAME}" | tr ' /' '__')"
DOC_FILE="${SESSION_DOCS}/${STAMP}-${SAFE_NAME}.md"
LOG_FILE="${SESSION_LOGS}/${STAMP}-${SAFE_NAME}.log"

HOSTNAME_SHORT="$(hostname)"

cat > "${DOC_FILE}" <<EOF_DOC
# Session: ${SESSION_NAME}

- **Date:** ${DATE_ONLY}
- **Start Time (local):** $(date +%H:%M)
- **Host / Context:** ${HOSTNAME_SHORT}
- **Repo Base:** ${BASE_DIR}

## 1. Goals

- <fill in>

## 2. Notes / Decisions

- <fill in>

## 3. Commands / Evidence

- <paste key commands / outputs here>

## 4. End-of-session Summary

- <fill in before closing the session>
EOF_DOC

{
  echo "Session created: ${SESSION_NAME}"
  echo "Timestamp: ${STAMP}"
  echo "Host: ${HOSTNAME_SHORT}"
  echo "Doc file: ${DOC_FILE}"
} > "${LOG_FILE}"

echo "=== New session created ==="
echo "Markdown doc : ${DOC_FILE}"
echo "Session log  : ${LOG_FILE}"
echo
echo "Open this file in code-server or your editor and use it as the live notepad for this session."
