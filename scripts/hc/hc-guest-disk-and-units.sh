#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# DATE       | CHGID   | REASON
# 2026-07-12 | CR-0412 | New: host + guest disk/memory/failed-unit detail scan.
#                      | Formalizes the read-only check sequence Codex ran ad
#                      | hoc on 2026-07-12 (session
#                      | rollout-2026-07-12T12-31-14-019f572b-2b2d-7232-a2b7-
#                      | ec939f529b47.jsonl) after a manual Netdata alert
#                      | triage found VM 109 at 100% disk and several LXCs
#                      | with failed units that nothing in the hc pipeline was
#                      | checking for (host-level checks and guest disk/unit
#                      | detail were both missing). Read-only; auto-drills
#                      | into `du -xhd1 /` for any guest at/above the disk
#                      | warn threshold instead of requiring a manual
#                      | follow-up run.
# 2026-07-12 | CR-0417 | bash -lc -> bash -c: -lc invoked a login shell,
#                      | which triggers these containers' MOTD banners ahead
#                      | of the real command output in every captured
#                      | artifact (see matching fix in
#                      | pve-lxc-systemd-scan.sh).
# 2026-09-14 | CR-0419 | Code-review follow-up. df -P on every root-fs probe
#                      | so a long device name can't wrap the row we awk;
#                      | an empty/non-numeric df result is now reported as
#                      | "could not determine" instead of being silently
#                      | treated as 0% (the LXC probe's `|| echo 0%` masked
#                      | pct-exec failures the same way). guest_exec_out
#                      | takes exactly one script-string argument - it is
#                      | meant to be parsed by the guest's bash, which is
#                      | why every caller passes a single-quoted literal.
#                      | Signed: p.p. claude-opus-5 for JC
# USER: JC  | TARGET: PVE host + running guests
#-------------------------------------------------------------------------------

set -uo pipefail

DISK_WARN_PCT="${DISK_WARN_PCT:-85}"

hr() { printf '%*s\n' 80 | tr ' ' '-'; }

# 0 = at/over DISK_WARN_PCT, 1 = under, 2 = not a percentage (empty or
# garbage - the df probe failed or returned something we can't read).
disk_pct_over_threshold() {
  local pct="${1%\%}"
  [[ "$pct" =~ ^[0-9]+$ ]] || return 2
  [ "$pct" -ge "${DISK_WARN_PCT}" ]
}

# Prints the verdict for one guest; returns 0 only when a drill-in is due.
# An unreadable probe is called out rather than skipped silently - a health
# check that quietly says nothing about a full disk is the failure mode
# this script exists to remove.
disk_check_report() {
  local dpct="$1"
  disk_pct_over_threshold "${dpct}"
  case $? in
    0) echo "  [disk ${dpct} >= ${DISK_WARN_PCT}% warn threshold, drilling in]"; return 0 ;;
    2) echo "  [disk usage could not be determined (df returned '${dpct}'), threshold check skipped]"; return 1 ;;
    *) return 1 ;;
  esac
}

# qm guest exec replies are JSON ({"out-data": "...", ...}); this unwraps it.
# Decodes stdin as UTF-8 explicitly (2026-07-12 CR-0418, JC) - relying on
# Python's default text-mode stdin decode mangled multi-byte output (e.g. the
# "*" bullet systemctl prints on failed units) because the ssh/pct-exec
# session isn't guaranteed to advertise a UTF-8 locale.
# NOTE: qm guest exec has been observed to occasionally return a short,
# non-truncated (out-truncated:0) but incomplete result for longer-running
# commands under heavy guest I/O load (seen on a 100%-full disk running
# `du -xhd1 /`); a same-command manual retry returned the full result. This
# is a known flakiness of the qemu-guest-agent exec channel, not a bug in
# this wrapper - treat single-run drill-in output here as best-effort.
# Usage: guest_exec_out <vmid> <script>. The second argument is one shell
# script string handed to bash -c inside the guest; it is meant to be parsed
# there, so never build it from data you don't control.
guest_exec_out() {
  local vmid="$1" script="$2"
  qm guest exec "${vmid}" -- bash -c "${script}" 2>/dev/null | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.buffer.read().decode("utf-8", errors="replace"))
    sys.stdout.write(d.get("out-data") or d.get("err-data") or "")
except Exception:
    pass
'
}

echo "Host + Guest Disk / Memory / Failed-Unit Detail"
echo "Timestamp: $(date -Iseconds)"
echo

hr
echo "=== HOST ==="
hr
hostnamectl 2>/dev/null || hostname
uptime
echo
echo "--- HOST MEMORY ---"
free -h
echo
echo "--- HOST DISK ---"
df -h -x tmpfs -x devtmpfs -x squashfs
echo
echo "--- HOST FAILED UNITS ---"
LC_ALL=C systemctl --failed --no-pager || true
echo
echo "--- HOST RECENT HIGH-SEVERITY JOURNAL (emerg..err, last 80) ---"
journalctl -p 0..3 -n 80 --no-pager 2>/dev/null || true
echo
echo "--- ZFS POOLS ---"
zpool status 2>/dev/null || echo "no pools available"

echo
hr
echo "=== LXC GUESTS (running) ==="
hr
pct list 2>/dev/null | awk 'NR>1 && $2=="running" {print $1}' | while read -r ctid; do
  echo
  echo "----- CT ${ctid} -----"
  pct exec "${ctid}" -- bash -c '
    printf "host="; hostname
    printf "uptime="; uptime -p 2>/dev/null || uptime
    printf "mem="; free -h | awk "/Mem:/ {print \"used=\"\$3, \"total=\"\$2, \"avail=\"\$7}"
    printf "swap="; free -h | awk "/Swap:/ {print \"used=\"\$3, \"total=\"\$2}"
    printf "disk-root="; df -Ph / | awk "NR==2 {print \"used=\"\$3, \"size=\"\$2, \"pct=\"\$5}"
    printf "failed-units="; LC_ALL=C systemctl list-units --all --type=service --state=failed,activating --no-legend --no-pager 2>/dev/null | wc -l
    LC_ALL=C systemctl list-units --all --type=service --state=failed,activating --no-legend --no-pager 2>/dev/null | sed -n "1,5p"
  ' 2>&1

  DPCT="$(pct exec "${ctid}" -- bash -c "df -Ph / | awk 'NR==2{print \$5}'" 2>/dev/null | tr -d '[:space:]')"
  if disk_check_report "${DPCT}"; then
    pct exec "${ctid}" -- bash -c 'du -xhd1 / 2>/dev/null | sort -h | tail -20' 2>&1 | sed 's/^/  /'
  fi
done

echo
hr
echo "=== QEMU GUESTS (running) ==="
hr
qm list 2>/dev/null | awk 'NR>1 && $3=="running" {print $1}' | while read -r vmid; do
  echo
  echo "----- VM ${vmid} -----"
  if ! qm agent "${vmid}" ping >/dev/null 2>&1; then
    echo "  no QEMU guest agent reachable, skipping in-guest checks."
    continue
  fi

  guest_exec_out "${vmid}" '
    printf "host="; hostname
    printf "uptime="; uptime -p 2>/dev/null || uptime
    printf "mem="; free -h | awk "/Mem:/ {print \"used=\"\$3, \"total=\"\$2, \"avail=\"\$7}"
    printf "swap="; free -h | awk "/Swap:/ {print \"used=\"\$3, \"total=\"\$2}"
    printf "disk-root="; df -Ph / | awk "NR==2 {print \"used=\"\$3, \"size=\"\$2, \"pct=\"\$5}"
    printf "failed-units="; LC_ALL=C systemctl list-units --all --type=service --state=failed,activating --no-legend --no-pager 2>/dev/null | wc -l
    LC_ALL=C systemctl list-units --all --type=service --state=failed,activating --no-legend --no-pager 2>/dev/null | sed -n "1,5p"
  '
  echo

  DPCT="$(guest_exec_out "${vmid}" "df -Ph / | awk 'NR==2{print \$5}'" | tr -d '[:space:]')"
  if disk_check_report "${DPCT}"; then
    # `du -xhd1 /` always ends with a total line for "/" itself; a chained
    # qm guest exec call occasionally comes back short with no error
    # (out-truncated:0, exited:1) after preceding exec calls in the same
    # guest - reproducible, cause not fully isolated. One retry is enough
    # in testing; if it still comes up short, say so rather than print a
    # silently incomplete breakdown.
    DRILL="$(guest_exec_out "${vmid}" 'du -xhd1 / 2>/dev/null | sort -h | tail -20')"
    if ! printf '%s' "${DRILL}" | tail -1 | grep -qE '/$'; then
      sleep 2
      DRILL="$(guest_exec_out "${vmid}" 'du -xhd1 / 2>/dev/null | sort -h | tail -20')"
    fi
    if printf '%s' "${DRILL}" | tail -1 | grep -qE '/$'; then
      printf '%s\n' "${DRILL}" | sed 's/^/  /'
    else
      echo "  [breakdown came back incomplete twice - rerun manually: qm guest exec ${vmid} -- bash -c 'du -xhd1 / | sort -h | tail -20']"
    fi
  fi
done

echo
hr
echo "=== STOPPED QEMU VMS ==="
hr
qm list 2>/dev/null | awk 'NR>1 && $3!="running" {print $1, $2, $3}'
