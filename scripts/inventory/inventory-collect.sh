#!/usr/bin/env bash
set -euo pipefail

# Inventory collection script
# Writes raw logs, JSON metadata, and a Markdown summary into ARTIFACT_DIR

ARTIFACT_BASE=${ARTIFACT_BASE:-/srv/artifacts/hc}
TS=$(date -u +"%Y-%m-%dT%H%M%SZ")
HOST=$(hostname -s 2>/dev/null || hostname)
ARTIFACT_DIR="${ARTIFACT_BASE}/${HOST}-${TS}"

mkdir -p "${ARTIFACT_DIR}/raw"
mkdir -p "${ARTIFACT_DIR}/json"

echo "[inventory-collect] Writing artifact to ${ARTIFACT_DIR}"

out() { echo "[inventory-collect] $@"; }

out "Collecting basic host info"
hostname > "${ARTIFACT_DIR}/raw/hostname.txt" 2>&1 || true
uptime -p > "${ARTIFACT_DIR}/raw/uptime.txt" 2>&1 || uptime > "${ARTIFACT_DIR}/raw/uptime.txt" 2>&1 || true
uname -a > "${ARTIFACT_DIR}/raw/uname.txt" 2>&1 || true

out "Collecting network information"
ip addr show > "${ARTIFACT_DIR}/raw/ip_addr.txt" 2>&1 || ip a > "${ARTIFACT_DIR}/raw/ip_addr.txt" 2>&1 || true
ip route > "${ARTIFACT_DIR}/raw/ip_route.txt" 2>&1 || true
cat /etc/resolv.conf > "${ARTIFACT_DIR}/raw/resolv.conf" 2>&1 || true

out "Collecting storage information"
df -hT > "${ARTIFACT_DIR}/raw/df.txt" 2>&1 || true
lsblk -a > "${ARTIFACT_DIR}/raw/lsblk.txt" 2>&1 || true
if command -v zpool >/dev/null 2>&1; then
  zpool status > "${ARTIFACT_DIR}/raw/zpool_status.txt" 2>&1 || true
  zpool list > "${ARTIFACT_DIR}/raw/zpool_list.txt" 2>&1 || true
fi

out "Collecting Docker info (if available)"
if command -v docker >/dev/null 2>&1; then
  docker ps -a --format '{{json .}}' > "${ARTIFACT_DIR}/raw/docker_ps.json" 2>&1 || docker ps -a > "${ARTIFACT_DIR}/raw/docker_ps.txt" 2>&1 || true
fi

out "Collecting listening ports"
ss -tunlp > "${ARTIFACT_DIR}/raw/listening_ports.txt" 2>&1 || ss -ltnp > "${ARTIFACT_DIR}/raw/listening_ports.txt" 2>&1 || true

out "Collecting Proxmox inventory if available"
if command -v pvesh >/dev/null 2>&1; then
  pvesh get /nodes > "${ARTIFACT_DIR}/raw/pvesh_nodes.txt" 2>&1 || true
fi
if command -v qm >/dev/null 2>&1; then
  qm list > "${ARTIFACT_DIR}/raw/qm_list.txt" 2>&1 || true
fi
if command -v pct >/dev/null 2>&1; then
  pct list > "${ARTIFACT_DIR}/raw/pct_list.txt" 2>&1 || true
fi

out "Collecting recent health checks"
systemctl --failed > "${ARTIFACT_DIR}/raw/systemctl_failed.txt" 2>&1 || true
journalctl -p err -n 200 > "${ARTIFACT_DIR}/raw/journal_errors.txt" 2>&1 || true

out "Writing metadata JSON"
META_FILE="${ARTIFACT_DIR}/json/metadata.json"
cat > "${META_FILE}" <<-JSON
{
  "timestamp": "${TS}",
  "hostname": "${HOST}",
  "artifact_dir": "${ARTIFACT_DIR}",
  "branch": "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')",
  "commit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
}
JSON

out "Generating Markdown summary"
MD_FILE="${ARTIFACT_DIR}/summary.md"
cat > "${MD_FILE}" <<-MD
# Inventory for ${HOST}

Generated: ${TS}

| Item | Value |
|---|---|
| Hostname | \\`$(cat "${ARTIFACT_DIR}/raw/hostname.txt" 2>/dev/null || echo "$(hostname)" )\\` |
| Uptime | $(head -n1 "${ARTIFACT_DIR}/raw/uptime.txt" 2>/dev/null || echo "N/A") |
| Kernel / OS | $(head -n1 "${ARTIFACT_DIR}/raw/uname.txt" 2>/dev/null || echo "N/A") |
| IPs (first lines) | $(head -n2 "${ARTIFACT_DIR}/raw/ip_addr.txt" 2>/dev/null | sed ':a;N;$!ba;s/\n/ /g' || echo "N/A") |
| Default route | $(head -n1 "${ARTIFACT_DIR}/raw/ip_route.txt" 2>/dev/null || echo "N/A") |
| DNS | $(grep -E '^nameserver' "${ARTIFACT_DIR}/raw/resolv.conf" 2>/dev/null | awk '{print $2}' | paste -s -d', ' - || echo "N/A") |
| Storage summary | $(head -n1 "${ARTIFACT_DIR}/raw/df.txt" 2>/dev/null || echo "N/A") |
| Docker containers | $(if [ -f "${ARTIFACT_DIR}/raw/docker_ps.json" ]; then echo "See raw/docker_ps.json"; else echo "none"; fi) |
| Listening ports | $(head -n3 "${ARTIFACT_DIR}/raw/listening_ports.txt" 2>/dev/null | sed ':a;N;$!ba;s/\n/ /g' || echo "N/A") |
| Recent failed units | $(head -n3 "${ARTIFACT_DIR}/raw/systemctl_failed.txt" 2>/dev/null | sed ':a;N;$!ba;s/\n/ /g' || echo "None") |
| Artifact dir | ${ARTIFACT_DIR} |

MD

echo "[inventory-collect] Done: ${ARTIFACT_DIR}"
echo "${ARTIFACT_DIR}"
