#!/usr/bin/env bash
# PVE_tools_check.sh — Sanity check for monitoring tools on Proxmox node
# Runs after baseline packages are installed.

set -euo pipefail

echo "=== TOOL CHECKS ==="

# Disk / Storage
echo "[smartctl]"; smartctl --version | head -n1
echo "[zpool]"; zpool --version || echo "zpool not available"
echo "[lshw]"; lshw -short | head -n5
echo "[hdparm]"; hdparm -I /dev/sda 2>/dev/null | head -n5
echo "[nvme-cli]"; nvme list 2>/dev/null || echo "No NVMe devices found"

# System / Resource
echo "[iostat]"; iostat -x 1 1 | head -n5
echo "[htop] (press q to quit)"; htop
echo "[iotop] (press q to quit)"; iotop -b -n 1 | head -n5

# Networking
echo "[iftop] (press q to quit)"; iftop -t -s 1 | head -n10
echo "[iperf3]"; iperf3 --version | head -n1
echo "[ethtool]"; ethtool --version
echo "[net-tools]"; ifconfig -a | head -n5

# Logs / Troubleshooting
echo "[jq]"; jq --version
echo "[curl]"; curl --version | head -n1
echo "[lm-sensors]"; sensors | head -n10
echo "[pciutils]"; lspci | head -n5
echo "[usbutils]"; lsusb | head -n5


echo "=== END TOOL CHECKS ==="
