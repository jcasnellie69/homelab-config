#!/usr/bin/env bash
# Safe GitOps helper for staging, committing, and optionally pushing monitored workspace changes.

set -euo pipefail

DRY_RUN=1
DO_PUSH=0
ALLOW_MAIN=0
BRANCH_NAME=""
REPORT_PATH="artifacts/automation/workspace-gitops-monitor-report.json"
COMMIT_MSG="chore(workspace): sync monitored updates"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

usage() {
  cat <<'EOF'
Usage: gitops_sync.sh [--apply] [--push] [--allow-main] [--branch NAME] [--report PATH] [--message "..."]

Defaults to dry-run mode.
  --apply            Actually stage and commit changes.
  --push             Push after committing (requires --apply).
  --allow-main       Allow direct commit/push on main.
  --branch NAME      Branch to create or reuse when main safety branching is needed.
  --report PATH      Output path for the gitops monitor report.
  --message TEXT     Override the commit message.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      DRY_RUN=0
      ;;
    --push)
      DO_PUSH=1
      ;;
    --allow-main)
      ALLOW_MAIN=1
      ;;
    --branch)
      BRANCH_NAME="$2"
      shift
      ;;
    --report)
      REPORT_PATH="$2"
      shift
      ;;
    --message)
      COMMIT_MSG="$2"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

cd "${REPO_DIR}"

echo "[gitops] repository: ${REPO_DIR}"

if [[ -f scripts/session/workspace_gitops_monitor.py ]]; then
  python scripts/session/workspace_gitops_monitor.py --report "${REPORT_PATH}"
fi

git status --short --branch

current_branch="$(git rev-parse --abbrev-ref HEAD)"

if [[ ${DRY_RUN} -eq 1 ]]; then
  echo "[gitops] dry-run only; no changes staged or pushed"
  exit 0
fi

if [[ "${current_branch}" == "main" && ${ALLOW_MAIN} -ne 1 ]]; then
  timestamp="$(date +%Y%m%d-%H%M%S)"
  safe_branch="${BRANCH_NAME:-chore/workspace-sync-${timestamp}}"

  if git show-ref --verify --quiet "refs/heads/${safe_branch}"; then
    git switch "${safe_branch}"
  else
    git switch -c "${safe_branch}"
  fi

  current_branch="$(git rev-parse --abbrev-ref HEAD)"
  echo "[gitops] using safety branch: ${current_branch}"
fi

git add -A

if git diff --cached --quiet; then
  echo "[gitops] no staged changes to commit"
  exit 0
fi

git commit -m "${COMMIT_MSG}"
echo "[gitops] commit created on branch ${current_branch}"

if [[ ${DO_PUSH} -eq 1 ]]; then
  git push -u origin "${current_branch}"
fi
