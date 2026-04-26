#!/usr/bin/env bash
set -euo pipefail

MSG="${1:-Repository artifact created by script}"
TS=$(date -u +"%Y-%m-%dT%H%M%SZ")
ART_DIR=/srv/artifacts/hc
mkdir -p "$ART_DIR"
FN="$ART_DIR/${TS}-artifact.txt"
echo "Timestamp: $TS" > "$FN"
echo "Message: $MSG" >> "$FN"
echo "Created artifact: $FN" >&2

exit 0
