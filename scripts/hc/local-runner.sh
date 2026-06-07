#!/usr/bin/env bash
set -euo pipefail

# Local runner wrapper to run validation, inventory collection and publish from repo root
# Intended to be executed on the homelab fileserver where the repo is mounted (e.g. mapped as Z:/)

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
cd "${REPO_ROOT}"

ARTIFACT_BASE=${ARTIFACT_BASE:-/srv/artifacts/hc}

echo "[local-runner] Repo root: ${REPO_ROOT}"

echo "[local-runner] Running validation"
./scripts/hc/hc-validate.sh

echo "[local-runner] Running inventory collection"
./scripts/inventory/inventory-collect.sh

echo "[local-runner] Publishing docs"
./scripts/publish/publish-health-docs.sh

echo "[local-runner] Done"
