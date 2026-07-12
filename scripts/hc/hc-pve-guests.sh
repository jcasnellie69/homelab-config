#!/usr/bin/env bash
#===================================================================
# DATE       CHGID    REASON                               USER  SYSTEM
# 2025-12-11 CR-0106  Add TYPE=LXC/VM, clean DESC/TAGS     JOE   PVE
# 2026-07-12 CR-0411  Harden guest inventory parsing: awk-based field
#                      lookup instead of grep|cut|sed chains, and
#                      redact any password= strings surfaced in guest
#                      DESC text (helper-script installers frequently
#                      echo generated credentials into the container
#                      description). Ported from an uncommitted local
#                      hardening found on alpha; canonical source of
#                      truth is now this repo, not the alpha checkout.
#                                                            JC    PVE
#===================================================================

set -euo pipefail

get_pct_field() {
  local ctid="$1" field="$2"
  pct config "$ctid" 2>/dev/null | awk -F': ' -v want="$field" '
    tolower($1)==tolower(want) {print $2; found=1}
    END {if (!found) print ""}
  '
}

get_qm_field() {
  local vmid="$1" field="$2"
  qm config "$vmid" 2>/dev/null | awk -F': ' -v want="$field" '
    tolower($1)==tolower(want) {print $2; found=1}
    END {if (!found) print ""}
  '
}

sanitize_desc() {
  local s="${1:-}"
  s="$(printf '%s' "$s" | sed 's/%0A$//')"
  s="$(printf '%s' "$s" | sed -E 's/(password%3A )[^\"]+/\1[REDACTED]/Ig')"
  s="$(printf '%s' "$s" | sed -E 's/(password: )[^"]+/\1[REDACTED]/Ig')"
  s="${s//\"/\\\"}"
  printf '%s' "$s"
}

sanitize_tags() {
  local s="${1:-}"
  s="$(printf '%s' "$s" | sed 's/%0A$//')"
  s="${s//;/,}"
  printf '%s' "$s"
}

echo "PVE Guest Inventory"
echo "Timestamp: $(date -Iseconds)"
echo

echo "=== LXC Containers ==="
pct list | awk 'NR>1 {print $1}' | while read -r ctid; do
  status="$(pct status "$ctid" 2>/dev/null | awk '{print $2}' || true)"
  hostname="$(pct exec "$ctid" -- hostname 2>/dev/null || echo unknown)"
  desc="$(get_pct_field "$ctid" description)"
  tags="$(get_pct_field "$ctid" tags)"

  status="${status:-unknown}"
  hostname="${hostname:-unknown}"
  desc="$(sanitize_desc "$desc")"
  tags="$(sanitize_tags "$tags")"

  echo "VMID=$ctid TYPE=LXC HOSTNAME=$hostname STATUS=$status DESC=\"$desc\" TAGS=\"$tags\""
done

echo
echo "=== QEMU Virtual Machines ==="
qm list | awk 'NR>1 {print $1}' | while read -r vmid; do
  status="$(qm status "$vmid" 2>/dev/null | awk '{print $2}' || true)"
  name="$(get_qm_field "$vmid" name)"
  desc="$(get_qm_field "$vmid" description)"
  tags="$(get_qm_field "$vmid" tags)"

  status="${status:-unknown}"
  name="${name:-unknown}"
  desc="$(sanitize_desc "$desc")"
  tags="$(sanitize_tags "$tags")"

  echo "VMID=$vmid TYPE=VM NAME=\"$name\" STATUS=$status DESC=\"$desc\" TAGS=\"$tags\""
done

echo
echo "Guest inventory complete."
