#!/usr/bin/env bash
# Reset the repo to the initial-state tag (clean slate).
# Also cleans up remote release branches, version tags, and open PRs
# created during experiments.
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

# Tags that were present at the original baseline — never delete these
BASELINE_TAGS="core-0.1.0 ui-0.1.0 initial-state"

# ── Local reset ───────────────────────────────────────────────────────────────
echo "Resetting local state to initial-state..."
git reset --hard initial-state
git clean -fd

# ── Remote cleanup ────────────────────────────────────────────────────────────
REMOTE=$(git remote | head -1)
if [ -z "$REMOTE" ]; then
  echo "✓ Done (no remote configured — local-only reset)."
  exit 0
fi

echo "Cleaning up remote '$REMOTE'..."

# Delete remote release/* branches
REMOTE_RELEASE_BRANCHES=$(git ls-remote --heads "$REMOTE" 'refs/heads/release/*' \
  | awk '{print $2}' | sed 's|refs/heads/||')
if [ -n "$REMOTE_RELEASE_BRANCHES" ]; then
  echo "$REMOTE_RELEASE_BRANCHES" | while read -r branch; do
    echo "  Deleting remote branch: $branch"
    git push "$REMOTE" --delete "$branch"
  done
else
  echo "  No remote release/* branches found."
fi

# Delete remote version tags (core-* and ui-*) except baselines
REMOTE_VERSION_TAGS=$(git ls-remote --tags "$REMOTE" \
    'refs/tags/core-*' 'refs/tags/ui-*' \
  | awk '{print $2}' | sed 's|refs/tags/||' | grep -v '\^{}' || true)
if [ -n "$REMOTE_VERSION_TAGS" ]; then
  echo "$REMOTE_VERSION_TAGS" | while read -r tag; do
    if echo "$BASELINE_TAGS" | grep -qw "$tag"; then
      echo "  Keeping baseline tag: $tag"
    else
      echo "  Deleting remote tag: $tag"
      git push "$REMOTE" --delete "$tag"
    fi
  done
else
  echo "  No remote version tags found."
fi

# Close open release PRs
if command -v gh >/dev/null 2>&1; then
  OPEN_PRS=$(gh pr list --state open --json number,headRefName \
    --jq '.[] | select(.headRefName | startswith("release/")) | .number' 2>/dev/null || true)
  if [ -n "$OPEN_PRS" ]; then
    echo "$OPEN_PRS" | while read -r pr; do
      echo "  Closing PR #$pr"
      gh pr close "$pr" --comment "Closed by reset.sh"
    done
  else
    echo "  No open release PRs found."
  fi
else
  echo "  gh CLI not found — close any open release PRs manually."
fi

echo "✓ Done. Reset to initial-state ($(git rev-parse --short HEAD))."
