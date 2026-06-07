#!/usr/bin/env bash
set -euo pipefail

# Publishing script: consumes latest artifact for this host and updates docs/
ARTIFACT_BASE=${ARTIFACT_BASE:-/srv/artifacts/hc}
HOST=$(hostname -s 2>/dev/null || hostname)

# Find latest artifact for this host
LATEST_DIR=$(ls -1d ${ARTIFACT_BASE}/${HOST}-* 2>/dev/null | sort | tail -n1 || true)
if [ -z "${LATEST_DIR}" ]; then
  echo "No artifacts found for ${HOST} under ${ARTIFACT_BASE}" >&2
  exit 1
fi

TS=$(basename "${LATEST_DIR}" | sed -E "s/^${HOST}-//")

echo "[publish-health-docs] Using artifact: ${LATEST_DIR}"

backup_ts=$(date -u +"%Y-%m-%dT%H%M%SZ")
BACKUP_DIR="${ARTIFACT_BASE}/${HOST}-${backup_ts}-backup-docs"
mkdir -p "${BACKUP_DIR}"

echo "[publish-health-docs] Backing up current generated docs to ${BACKUP_DIR}"
mkdir -p "${BACKUP_DIR}/docs"
cp -r docs/health "${BACKUP_DIR}/docs/" 2>/dev/null || true
cp -r docs/inventory "${BACKUP_DIR}/docs/" 2>/dev/null || true

mkdir -p docs/health
mkdir -p docs/inventory

# Build latest health doc (summary + links to artifact)
HEALTH_LATEST="docs/health/latest.md"
cat > "${HEALTH_LATEST}" <<-MD
# Health report for ${HOST}

Generated: ${TS}

Artifact directory: \\`${LATEST_DIR}\\`

Summary and raw data are available in the artifact directory. Raw logs are not included here to avoid leaking sensitive data.

MD

# Build latest inventory doc by copying the artifact summary if exists
if [ -f "${LATEST_DIR}/summary.md" ]; then
  cp "${LATEST_DIR}/summary.md" "docs/inventory/latest.md"
else
  cat > "docs/inventory/latest.md" <<-MD2
# Inventory for ${HOST}

Generated: ${TS}

No summary.md in artifact; see artifact directory: \\`${LATEST_DIR}\\`

MD2
fi

# Update index files
INDEX_INV="docs/inventory/index.md"
cat > "${INDEX_INV}" <<-IDX
# Inventory index

Latest: [latest.md](latest.md)

Recent runs:

* ${TS} — [artifact](${LATEST_DIR})

IDX

INDEX_HEALTH="docs/health/index.md"
cat > "${INDEX_HEALTH}" <<-IDX2
# Health index

Latest: [latest.md](latest.md)

Recent runs:

* ${TS} — [artifact](${LATEST_DIR})

IDX2

echo "[publish-health-docs] Checking for changes to commit"
if git status --porcelain | grep -qE 'docs/(health|inventory)/'; then
  echo "[publish-health-docs] Changes detected; committing and pushing"
  ./scripts/git_stage_and_push.sh "chore(reporting): update generated health/inventory docs for ${HOST} ${TS}"
else
  echo "[publish-health-docs] No changes to docs"
fi

echo "[publish-health-docs] Done"
