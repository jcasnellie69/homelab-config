#!/usr/bin/env bash
set -euo pipefail

# Collect inventory data: produce raw log, JSON metadata, and a markdown fragment.
# Run from repository root: ./scripts/reporting/collect_inventory.sh

ROOT=$(pwd)
TS=$(date -u +"%Y-%m-%dT%H%M%SZ")
ARTIFACT_DIR=/srv/artifacts/hc
FRAG_DIR="$ARTIFACT_DIR/fragments"

mkdir -p "$FRAG_DIR"
mkdir -p "$ARTIFACT_DIR"

RAW_LOG="$ARTIFACT_DIR/${TS}-inventory.log"
META_JSON="$ARTIFACT_DIR/${TS}-inventory.json"
FRAG_MD="$FRAG_DIR/${TS}-inventory.md"

echo "Inventory collection started at $TS" | tee "$RAW_LOG"

echo "host: $(hostname 2>/dev/null || echo unknown)" | tee -a "$RAW_LOG"
echo "cwd: $ROOT" | tee -a "$RAW_LOG"

echo "# Commands output" >> "$RAW_LOG"

if command -v zpool >/dev/null 2>&1; then
  echo "--- zpool status ---" >> "$RAW_LOG"
  zpool status >> "$RAW_LOG" 2>&1 || true
fi

if command -v docker >/dev/null 2>&1; then
  echo "--- docker ps ---" >> "$RAW_LOG"
  docker ps --no-trunc >> "$RAW_LOG" 2>&1 || true
fi

echo "--- uname -a ---" >> "$RAW_LOG"
uname -a >> "$RAW_LOG" 2>&1 || true

echo "--- lsblk -a ---" >> "$RAW_LOG"
lsblk -a >> "$RAW_LOG" 2>&1 || true

# Minimal metadata JSON
cat > "$META_JSON" <<EOF
{
  "collected_at": "$TS",
  "collector": "scripts/reporting/collect_inventory.sh",
  "host": "$(hostname 2>/dev/null || echo unknown)",
  "artifact_log": "${RAW_LOG}",
  "fragment": "${FRAG_MD}"
}
EOF

# Small markdown summary fragment for publishing
cat > "$FRAG_MD" <<EOF
### Inventory snapshot — $TS

- Host: $(hostname 2>/dev/null || echo unknown)
- Collected: $TS (UTC)

Summary of collected items:

```
See raw log: ${RAW_LOG}
```

EOF

echo "Wrote: $RAW_LOG" >&2
echo "Wrote: $META_JSON" >&2
echo "Wrote: $FRAG_MD" >&2

exit 0
