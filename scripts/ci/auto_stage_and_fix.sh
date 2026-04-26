#!/usr/bin/env bash
set -euo pipefail

# Auto-run available fixers (eslint/stylelint/markdownlint/ruff) then stage and push any changes.
# Intended for CI (GitHub Actions) or local use.

echo "Auto linter fixer starting..."

ROOT="$(pwd)"

run_npx() {
  cmd="$1"
  echo "Running npx $cmd"
  npx --yes $cmd || true
}

# Python fixer: ruff
if command -v ruff >/dev/null 2>&1; then
  echo "Running ruff --fix"
  ruff check --fix . || true
else
  echo "ruff not found; skipping python auto-fixes"
fi

# JS/TS: eslint
if [ -f package.json ]; then
  echo "package.json found — attempting eslint --fix via npx"
  run_npx "eslint . --ext .js,.ts,.jsx,.tsx --fix"
else
  echo "no package.json — skipping eslint"
fi

# CSS: stylelint
if [ -f package.json ]; then
  echo "Attempting stylelint --fix via npx"
  run_npx "stylelint '**/*.{css,scss,less}' --fix" 
fi

# Markdown: markdownlint-cli
echo "Attempting markdownlint fixes via npx"
run_npx "markdownlint-cli2 --fix '**/*.md'" || true

# Optional project-specific fix command
if [ -x ./scripts/ci/project_fix.sh ]; then
  echo "Running project-specific fixer scripts/ci/project_fix.sh"
  ./scripts/ci/project_fix.sh || true
fi

echo "Staging all changes..."
git add -A

if git diff --staged --quiet; then
  echo "No changes detected after auto-fixes. Exiting."
  exit 0
fi

MSG="chore(auto-fix): apply linter fixes and stage untracked files (auto)"
echo "Committing: $MSG"
git commit -m "$MSG" || true

BRANCH=$(git rev-parse --abbrev-ref HEAD || echo "")
if [ -z "$BRANCH" ]; then
  echo "Unable to determine branch; skipping push." >&2
  exit 0
fi

echo "Pushing to origin/$BRANCH"
git push origin "$BRANCH" || true

echo "Auto linter fixer finished."

exit 0
