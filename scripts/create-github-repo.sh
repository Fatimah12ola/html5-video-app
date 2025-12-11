#!/usr/bin/env bash
set -e

REPO_NAME=${1:-$(basename "$(pwd)")}
VISIBILITY=${2:-public}

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) not found. Install: https://cli.github.com/"
  echo "Or create a repo manually: https://github.com/new"
  exit 1
fi

# Check auth status
if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI not authenticated. Run 'gh auth login' to authenticate and try again."
  exit 1
fi

# Ensure git has an initial commit
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init
fi

if ! git status --porcelain | grep -q .; then
  echo "No changes to commit. Proceeding with repo creation."
else
  git add -A
  git commit -m "Initial commit"
fi

# Create remote repo and push using gh
if gh repo create "$REPO_NAME" --$VISIBILITY --source . --remote origin --push; then
  echo "Repo created and pushed: $REPO_NAME"
else
  echo "gh repo create failed. You can create the repo manually and then run:"
  echo "git remote add origin https://github.com/<your-username>/$REPO_NAME.git"
  echo "git push -u origin main"
fi
