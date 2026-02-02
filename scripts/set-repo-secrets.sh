#!/usr/bin/env bash
set -euo pipefail

# Usage:
# WIKI_PAT=<value> MCP_GATEWAY_TOKEN=<value> GITHUB_PAT=<value> gh auth login && ./scripts/set-repo-secrets.sh

REPO="jcasnellie69/homelab-config"

echo "Setting repository secrets for $REPO"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found. Install https://cli.github.com/" >&2
  exit 1
fi

set_secret() {
  name=$1
  value=$2
  if [ -z "${value:-}" ]; then
    echo "Skipping $name: value empty"
    return
  fi
  echo "Setting secret $name"
  echo -n "$value" | gh secret set "$name" -R "$REPO"
}

set_secret WIKI_PAT "${WIKI_PAT:-}"
set_secret MCP_GATEWAY_TOKEN "${MCP_GATEWAY_TOKEN:-}"
set_secret GITHUB_PAT "${GITHUB_PAT:-}"

echo "Secrets set (if provided)."
