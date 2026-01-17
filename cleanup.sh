#!/bin/bash
set -euxo pipefail

# Delete all releases on GitHub
gh release list | awk '{print $1}' | while read -r line; do gh release delete -y "$line"; done

# Delete all tags locally and remotely
git tag -d $(git tag -l)
git push origin --delete $(git tag -l) || true

# Reset the master branch to match the starter branch
git checkout starter
git branch -D master || true
git checkout -b master
git push -f origin master