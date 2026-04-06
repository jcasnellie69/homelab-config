#!/usr/bin/env bash
set -euo pipefail
DIR="${1:?usage: telemetry-map-render.sh /path/to/telemetry-map/D*}"
OUT_MD="$DIR/telemetry-map.md"
OUT_DOT="$DIR/telemetry-map.dot"
OUT_PNG="$DIR/telemetry-map.png"

# Markdown report
{
  echo "# Telemetry Map"
  echo
  echo "Source: \`$DIR\`"
  echo
  echo "## Containers"
  echo '```'
  cat "$DIR/ct-index.csv" 2>/dev/null || true
  echo '```'
  echo
  echo "## Catchers (listeners: who is receiving)"
  echo
  for f in "$DIR"/listeners-*.txt; do
    [[ -f "$f" ]] || continue
    echo "### $(basename "$f")"
    echo '```'
    awk 'NR==1 || /LISTEN/ {print}' "$f" | sed -e 's/ users:.*$//'
    echo '```'
    echo
  done

  echo "## Pitchers (edges: who is pushing/scraping where)"
  echo
  for f in "$DIR"/edges-*.txt; do
    [[ -f "$f" ]] || continue
    echo "### $(basename "$f")"
    echo '```'
    sed -n '1,220p' "$f"
    echo '```'
    echo
  done
} > "$OUT_MD"

# Graphviz diagram (best-effort)
{
  echo "digraph telemetry {"
  echo "  rankdir=LR;"
  echo "  node [shape=box];"

  # nodes
  tail -n +2 "$DIR/ct-index.csv" 2>/dev/null | while IFS=, read -r CT NAME IP rest; do
    CT="${CT//[[:space:]]/}"
    NAME="${NAME//[[:space:]]/}"
    IP="${IP//[[:space:]]/}"
    [[ -n "$CT" ]] || continue
    echo "  \"CT$CT\" [label=\"CT $CT\\n$NAME\\n$IP\"];"
  done

  # edges: promtail->loki from edges files
  for f in "$DIR"/edges-*.txt; do
    [[ -f "$f" ]] || continue
    SRC_CT="$(basename "$f" | sed -E 's/^edges-([0-9]+)\.txt$/\1/')"
    while read -r line; do
      # extract host:port from url line
      DEST="$(echo "$line" | sed -E 's/.*http:\/\/([^\/]+)\/loki\/api\/v1\/push.*/\1/' )"
      [[ "$DEST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:3100$ ]] || continue
      echo "  \"CT$SRC_CT\" -> \"$DEST\" [label=\"promtail push\"];"
    done < <(grep -Eo 'http://[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:3100/loki/api/v1/push' "$f" 2>/dev/null | sort -u)
  done

  echo "}"
} > "$OUT_DOT"

if command -v dot >/dev/null 2>&1; then
  dot -Tpng "$OUT_DOT" -o "$OUT_PNG"
  echo "Wrote: $OUT_MD"
  echo "Wrote: $OUT_DOT"
  echo "Wrote: $OUT_PNG"
else
  echo "Wrote: $OUT_MD"
  echo "Wrote: $OUT_DOT"
  echo "NOTE: 'dot' not installed; no PNG generated."
fi
