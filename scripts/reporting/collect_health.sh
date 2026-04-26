#!/usr/bin/env bash
set -euo pipefail

# Collect health metrics: produce raw log, JSON metadata, and a markdown fragment.
# Run from repository root: ./scripts/reporting/collect_health.sh

ROOT=$(pwd)
TS=$(date -u +"%Y-%m-%dT%H%M%SZ")
ARTIFACT_DIR=/srv/artifacts/hc
FRAG_DIR="$ARTIFACT_DIR/fragments"

mkdir -p "$FRAG_DIR"
mkdir -p "$ARTIFACT_DIR"

RAW_LOG="$ARTIFACT_DIR/${TS}-health.log"
META_JSON="$ARTIFACT_DIR/${TS}-health.json"
FRAG_MD="$FRAG_DIR/${TS}-health.md"

echo "Health collection started at $TS" | tee "$RAW_LOG"

echo "disk usage:" >> "$RAW_LOG"
df -h >> "$RAW_LOG" 2>&1 || true

echo "memory usage:" >> "$RAW_LOG"
if command -v free >/dev/null 2>&1; then
  free -h >> "$RAW_LOG" 2>&1 || true
fi

echo "docker ps (if present):" >> "$RAW_LOG"
if command -v docker >/dev/null 2>&1; then
  docker ps --no-trunc >> "$RAW_LOG" 2>&1 || true
fi

cat > "$META_JSON" <<EOF
{
  "collected_at": "$TS",
  "collector": "scripts/reporting/collect_health.sh",
  "host": "$(hostname 2>/dev/null || echo unknown)",
  "artifact_log": "${RAW_LOG}",
  "fragment": "${FRAG_MD}"
}
EOF

cat > "$FRAG_MD" <<EOF
### Health snapshot — $TS

- Host: $(hostname 2>/dev/null || echo unknown)
- Collected: $TS (UTC)

Key pointers:

- Raw evidence: ${RAW_LOG}

EOF

echo "Wrote: $RAW_LOG" >&2
echo "Wrote: $META_JSON" >&2
echo "Wrote: $FRAG_MD" >&2

exit 0
