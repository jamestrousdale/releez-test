#!/usr/bin/env bash
# Initialise the test repo with a realistic git history.
#
# After running this you have:
#   - Tags core-0.1.0 and ui-0.1.0 representing past releases
#   - 2 unreleased commits for core  (feat + fix  → expect 0.2.0)
#   - 1 unreleased commit  for ui   (feat         → expect 0.2.0)
#   - Tag initial-state pointing at HEAD for reset.sh / squash.sh
#
# Quick start:
#   releez projects changed
#   releez release start
set -euo pipefail

cd "$(dirname "$0")/.."

EXISTING_REPO=false
if [ -d .git ]; then
  EXISTING_REPO=true
fi

if [ "$EXISTING_REPO" = true ]; then
  echo "Existing repo detected — skipping git init."
  echo "Staging and committing any new files..."
  git add .
  if ! git diff --cached --quiet; then
    git commit -m "chore: add monorepo test fixtures"
  else
    echo "  Nothing new to commit."
  fi
else
  git init
  git checkout -b main
  git config user.email "releez-test@example.com"
  git config user.name "Releez Test"
  git add .
  git commit -m "chore: initial monorepo setup"
fi

# Simulate completed past releases at this commit
git tag core-0.1.0
git tag ui-0.1.0

# ── Unreleased core changes ───────────────────────────────────────────────────
cat >> packages/core/src/core/__init__.py << 'EOF'

def process(value: str) -> str:
    return value.strip()
EOF
git add packages/core/src/core/__init__.py
git commit -m "feat(core): add process helper"

cat >> packages/core/src/core/__init__.py << 'EOF'

def validate(value: str) -> bool:
    return bool(value)
EOF
git add packages/core/src/core/__init__.py
git commit -m "fix(core): handle empty string in validate"

# ── Unreleased ui changes ─────────────────────────────────────────────────────
cat >> packages/ui/src/ui/__init__.py << 'EOF'

def button(label: str) -> str:
    return f"<button>{label}</button>"
EOF
git add packages/ui/src/ui/__init__.py
git commit -m "feat(ui): add button component"

# ── Mark reset point ──────────────────────────────────────────────────────────
git tag initial-state

echo ""
echo "✓ Repo ready."
echo "  Tags:              core-0.1.0, ui-0.1.0 (past releases)"
echo "  Unreleased core:   feat + fix  → bump to 0.2.0"
echo "  Unreleased ui:     feat        → bump to 0.2.0"
echo ""
echo "Try:"
echo "  releez projects changed"
echo "  releez release start"
