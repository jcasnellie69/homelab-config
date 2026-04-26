#!/usr/bin/env bash
set -euo pipefail

# Stage, commit, and push changes from repository root.
# Usage: ./scripts/git_stage_and_push.sh "commit message"
# If no message is provided, a timestamped message will be used.

MSG="${1:-chore: repo changes $(date -u +%Y-%m-%dT%H%M%SZ)}"

if [ ! -d .git ]; then
  echo "Not a git repository (no .git directory found). Run from repo root." >&2
  exit 1
fi

# Determine current branch
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ -z "$BRANCH" ]; then
  echo "Unable to determine current branch." >&2
  exit 1
fi

echo "Staging all changes..."
git add -A

if git diff --staged --quiet; then
  echo "No changes to commit." >&2
  exit 0
fi

echo "Committing: $MSG"
git commit -m "$MSG"

echo "Pushing to origin/$BRANCH"
git push origin "$BRANCH"

echo "Done."

exit 0
