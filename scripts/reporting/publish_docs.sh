#!/usr/bin/env bash
set -euo pipefail

# Publish docs from fragments under /srv/artifacts/hc/fragments
# Writes generated pages into docs/inventory/index.md and docs/health/index.md
# Run from repository root: ./scripts/reporting/publish_docs.sh

ARTIFACT_DIR=/srv/artifacts/hc
FRAG_DIR="$ARTIFACT_DIR/fragments"

DOCS_INV_DIR=docs/inventory
DOCS_HEALTH_DIR=docs/health

mkdir -p "$FRAG_DIR"
mkdir -p "$DOCS_INV_DIR"
mkdir -p "$DOCS_HEALTH_DIR"

# Build inventory page from fragments that contain 'inventory' in filename
INV_INDEX="$DOCS_INV_DIR/index.md"
echo "# Inventory" > "$INV_INDEX"
echo "Generated from fragments under $FRAG_DIR" >> "$INV_INDEX"
echo >> "$INV_INDEX"

for f in $(ls -1 "$FRAG_DIR"/*-inventory.md 2>/dev/null | sort -r); do
  echo "<!-- fragment: $f -->" >> "$INV_INDEX"
  cat "$f" >> "$INV_INDEX"
  echo >> "$INV_INDEX"
done

# Build health page
HEALTH_INDEX="$DOCS_HEALTH_DIR/index.md"
echo "# Health" > "$HEALTH_INDEX"
echo "Generated from fragments under $FRAG_DIR" >> "$HEALTH_INDEX"
echo >> "$HEALTH_INDEX"

for f in $(ls -1 "$FRAG_DIR"/*-health.md 2>/dev/null | sort -r); do
  echo "<!-- fragment: $f -->" >> "$HEALTH_INDEX"
  cat "$f" >> "$HEALTH_INDEX"
  echo >> "$HEALTH_INDEX"
done

echo "Wrote: $INV_INDEX" >&2
echo "Wrote: $HEALTH_INDEX" >&2

exit 0
