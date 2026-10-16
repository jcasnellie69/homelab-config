#!/usr/bin/env bash
#===================================================================
# DATE       CHGID    REASON                               USER  SYSTEM
# 2026-10-16 CHG-137  HC for codex CLI presence and startup  JC    PVE
#                     update-check setting (issue #137: silent
#                     npm self-update left no /usr/local/bin/codex)
#===================================================================

set -uo pipefail

echo "Codex CLI Health Check"
echo "Timestamp: $(date -Iseconds)"
echo

rc=0

if ! command -v codex >/dev/null 2>&1; then
  echo "[FAIL] codex not found in PATH (possible broken self-update)"
  ls -la /usr/local/bin/.codex-* /usr/local/lib/node_modules/@openai/.codex-* 2>/dev/null \
    | sed 's/^/[INFO] leftover retired path: /'
  exit 1
fi

echo "codex path: $(command -v codex)"
if ver="$(codex --version 2>&1)"; then
  echo "[OK] codex --version: ${ver}"
else
  echo "[FAIL] codex --version failed: ${ver}"
  rc=1
fi

cfg="${CODEX_HOME:-${HOME}/.codex}/config.toml"
if [ -r "${cfg}" ] && grep -Eq '^[[:space:]]*check_for_update_on_startup[[:space:]]*=[[:space:]]*false' "${cfg}"; then
  echo "[OK] startup update check disabled in ${cfg}"
else
  echo "[WARN] startup update check not disabled in ${cfg}; codex may self-update silently (set check_for_update_on_startup = false)"
fi

exit "${rc}"
