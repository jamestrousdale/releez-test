#!/usr/bin/env bash
# Squash all commits since initial-state into one new commit, then move the
# initial-state tag to HEAD. Useful when you've been experimenting and want
# to save the current state as the new clean baseline.
#
# Note: version tags (core-0.1.0, ui-0.1.0, etc.) are not affected.
set -euo pipefail

cd "$(dirname "$0")/.."

if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: not a git repository. Run scripts/init.sh first."
  exit 1
fi

if ! git rev-parse initial-state > /dev/null 2>&1; then
  echo "Error: initial-state tag not found. Run scripts/init.sh first."
  exit 1
fi

CURRENT=$(git rev-parse HEAD)
INITIAL=$(git rev-parse initial-state)

if [ "$CURRENT" = "$INITIAL" ]; then
  echo "Already at initial-state. Nothing to squash."
  exit 0
fi

COUNT=$(git rev-list initial-state..HEAD | wc -l | tr -d ' ')
echo "Squashing $COUNT commit(s) since initial-state..."

git reset --soft initial-state
git commit -m "chore: squashed test state"
git tag -f initial-state HEAD

echo "✓ Done. initial-state updated to $(git rev-parse --short HEAD)."
echo "  Use scripts/reset.sh to return to this point."
