#!/usr/bin/env bash
# Prepare the ansible LXC/control node with the collections required for Proxmox, NetBox, and OPNsense automation.

set -euo pipefail

REPO_DIR="${REPO_DIR:-/root/homelab-config}"
REQ_FILE="${REPO_DIR}/deploy/ansible/collections/requirements.yml"

if [[ ${EUID} -ne 0 ]]; then
  echo "Run this script as root inside the Ansible control node or on Alpha via pct exec." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends python3 python3-pip python3-venv git curl sshpass ansible-core
python3 -m pip install --upgrade pip

if [[ ! -f "${REQ_FILE}" ]]; then
  echo "Missing collection requirements file: ${REQ_FILE}" >&2
  exit 1
fi

ansible-galaxy collection install -r "${REQ_FILE}" --force
ansible-galaxy collection list | egrep 'community.proxmox|netbox.netbox|ansibleguy.opnsense|community.general|ansible.posix' || true

echo "[ansible] control node bootstrap complete"
