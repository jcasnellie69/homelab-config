#!/usr/bin/env bash
set -euo pipefail

# Publish the latest DHCP discovery artifact into the MkDocs source tree.
# Run from repository root after dhcp-discovery-collect.sh.

ART_BASE="${ART_BASE:-/srv/artifacts/dhcp-discovery}"
DOCS_OUT="${DOCS_OUT:-docs/network-inventory/index.md}"
MAX_LINES="${MAX_LINES:-160}"

usage() {
  cat <<'EOT'
Usage: dhcp-discovery-publish.sh [-a <artifact_dir>] [-b <artifact_base>] [-o <docs_output>]

  -a  Specific discovery artifact directory to publish
  -b  Artifact base directory (default: /srv/artifacts/dhcp-discovery)
  -o  Docs output file (default: docs/network-inventory/index.md)

Environment:
  MAX_LINES  Max lines included from each captured text file (default: 160)
EOT
}

ART_DIR=""

while getopts ":a:b:o:h" opt; do
  case "$opt" in
    a) ART_DIR="$OPTARG" ;;
    b) ART_BASE="$OPTARG" ;;
    o) DOCS_OUT="$OPTARG" ;;
    h) usage; exit 0 ;;
    *) usage; exit 2 ;;
  esac
done

if [[ -z "$ART_DIR" ]]; then
  if [[ ! -d "$ART_BASE" ]]; then
    echo "Artifact base not found: $ART_BASE" >&2
    exit 1
  fi

  ART_DIR="$(find "$ART_BASE" -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' 2>/dev/null | sort -nr | awk 'NR==1 { sub(/^[^ ]+ /, ""); print }')"
fi

if [[ -z "$ART_DIR" || ! -d "$ART_DIR" ]]; then
  echo "No DHCP discovery artifact directory found." >&2
  exit 1
fi

mkdir -p "$(dirname "$DOCS_OUT")"

published_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
artifact_name="$(basename "$ART_DIR")"

{
  echo "# Network Inventory"
  echo
  echo "Generated from DHCP discovery artifact \`${artifact_name}\`."
  echo
  echo "- Published: ${published_at} (UTC)"
  echo "- Artifact directory: \`${ART_DIR}\`"
  echo
  echo "## Captured Files"
  echo
  find "$ART_DIR" -maxdepth 1 -type f -printf '%f\n' 2>/dev/null | sort | while read -r file; do
    echo "- \`${file}\`"
  done
  echo
  echo "## Discovery Output"
  echo

  find "$ART_DIR" -maxdepth 1 -type f -name '*.txt' -printf '%f\n' 2>/dev/null | sort | while read -r file; do
    path="${ART_DIR}/${file}"
    echo "### ${file}"
    echo
    echo '```text'
    sed -n "1,${MAX_LINES}p" "$path" | sed 's/\r$//'
    total_lines="$(wc -l < "$path" | tr -d ' ')"
    if [[ "$total_lines" -gt "$MAX_LINES" ]]; then
      echo
      echo "... truncated after ${MAX_LINES} of ${total_lines} lines ..."
    fi
    echo '```'
    echo
  done
} > "$DOCS_OUT"

echo "Published DHCP discovery artifact: $ART_DIR" >&2
echo "Wrote: $DOCS_OUT" >&2
