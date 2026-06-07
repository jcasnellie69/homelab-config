#!/usr/bin/env bash
set -euo pipefail

# Remote deploy and execute reporting scripts on cluster nodes.
# Expects these environment variables to be set:
# - NODES (comma-separated hostnames or IPs)
# - SSH_USER
# - SSH_PORT (optional, default 22)
# - RUN_AS_SUDO (optional, if 'true' will prefix remote commands with sudo)
# The GitHub Action should write the SSH private key to ~/.ssh/id_rsa before invoking this script.

NODES=${NODES:-}
SSH_USER=${SSH_USER:-}
SSH_PORT=${SSH_PORT:-22}
RUN_AS_SUDO=${RUN_AS_SUDO:-false}

if [ -z "$NODES" ] || [ -z "$SSH_USER" ]; then
  echo "Required env vars missing. Set NODES (comma list) and SSH_USER." >&2
  exit 1
fi

SSH_OPTS="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p $SSH_PORT"

echo "Remote run starting. Nodes: $NODES"

for node in $(echo "$NODES" | tr ',' ' '); do
  echo "--- Processing $node ---"

  # Ensure remote base dir exists
  ssh $SSH_OPTS "$SSH_USER@$node" "mkdir -p ~/homelab-config" || { echo "SSH connect failed to $node"; continue; }

  # Copy scripts directory using tar over ssh for reliability
  echo "Uploading scripts to $node:~/homelab-config/"
  tar -C . -cf - scripts | ssh $SSH_OPTS "$SSH_USER@$node" "tar -C ~/homelab-config -xvf -" || { echo "Upload failed for $node"; continue; }

  # Make sure scripts are executable
  ssh $SSH_OPTS "$SSH_USER@$node" "chmod -R +x ~/homelab-config/scripts || true"

  # Prepare remote command prefix
  if [ "$RUN_AS_SUDO" = "true" ]; then
    PREFIX="sudo "
  else
    PREFIX=""
  fi

  # Run collection scripts on remote node
  echo "Running collect_inventory.sh on $node"
  ssh $SSH_OPTS "$SSH_USER@$node" "$PREFIX bash ~/homelab-config/scripts/reporting/collect_inventory.sh" || echo "collect_inventory failed on $node"

  echo "Running collect_health.sh on $node"
  ssh $SSH_OPTS "$SSH_USER@$node" "$PREFIX bash ~/homelab-config/scripts/reporting/collect_health.sh" || echo "collect_health failed on $node"

  echo "Completed node $node"
done

echo "Remote run finished. Artifacts should be on each node under /srv/artifacts/hc/"

exit 0
