#!/usr/bin/env bash
# PVE_tools_install.sh — Baseline monitoring/diagnostics tooling for a Proxmox node
# Run as root on the PVE host. No sudo used. Safe to re-run.

set -euo pipefail

# --- Config -----------------------------------------------------------------
# Toggle noninteractive installs (recommended on servers)
export DEBIAN_FRONTEND=noninteractive

# Package groups (keep tidy for future edits)
DISK_PKGS=(smartmontools zfsutils-linux lshw hdparm nvme-cli)
SYS_PKGS=(sysstat iotop htop iftop)
NET_PKGS=(iperf3 ethtool net-tools)
MISC_PKGS=(jq curl lm-sensors pciutils usbutils)

ALL_PKGS=("${DISK_PKGS[@]}" "${SYS_PKGS[@]}" "${NET_PKGS[@]}" "${MISC_PKGS[@]}")

# --- Functions --------------------------------------------------------------
have() { command -v "$1" >/dev/null 2>&1; }
log()  { echo -e "[+] $*"; }
warn() { echo -e "[!] $*"; }

# --- Install ----------------------------------------------------------------
log "Updating apt cache…"
apt-get update -y

log "Installing baseline packages…"
apt-get install -y "${ALL_PKGS[@]}"

# --- Light post-install tweaks ----------------------------------------------
# sysstat collection timers (varies by distro). If unit exists, enable it.
if systemctl list-unit-files | grep -q '^sysstat\.service'; then
  log "Enabling sysstat service"
  systemctl enable --now sysstat.service || warn "Could not enable sysstat.service"
fi

# lm-sensors: we do NOT run sensors-detect here to avoid interactive prompts.
warn "Run 'sensors-detect' later if you want extended sensor coverage (interactive)."

# iftop/htop/iotop: nothing to configure; use interactively.

# --- Quick version echo (sanity) --------------------------------------------
log "Tool versions (short):"
smartctl --version | head -n1 || true
zpool --version 2>/dev/null || true
lshw -short | head -n3 || true
hdparm -V | head -n1 || true
nvme version 2>/dev/null || nvme list 2>/dev/null || true

iostat -V 2>/dev/null || true
htop --version 2>/dev/null | head -n1 || true
iotop --version 2>/dev/null | head -n1 || true

iperf3 --version 2>/dev/null | head -n1 || true
ethtool --version 2>/dev/null || true
ifconfig --version 2>/dev/null | head -n1 || true

jq --version 2>/dev/null || true
curl --version 2>/dev/null | head -n1 || true
sensors 2>/dev/null | head -n5 || true
lspci 2>/dev/null | head -n3 || true
lsusb 2>/dev/null | head -n3 || true

log "All done. You can now run PVE_tools_check.sh to validate."
