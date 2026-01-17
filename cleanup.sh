#!/bin/bash
set -euxo pipefail

# Delete all releases on GitHub
gh release list | awk '{print $1}' | while read -r line; do gh release delete -y "$line"; done

# Delete all tags locally and remotely
git tag -d $(git tag -l)
git push origin --delete $(git tag -l)

# Reset the repository to its initial commit
git reset --hard $(git rev-list --max-parents=0 HEAD)