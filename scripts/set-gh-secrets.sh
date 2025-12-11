#!/usr/bin/env bash
set -euo pipefail

# Helper to set common Azure secrets in GitHub using gh; requires gh CLI
# Usage: ./scripts/set-gh-secrets.sh <repo> <secret-name> <value>
# Example: ./scripts/set-gh-secrets.sh owner/repo AZURE_WEBAPP_NAME myapp

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found. Install and authenticate via 'gh auth login'"
  exit 1
fi

if [ $# -lt 3 ]; then
  echo "Usage: $0 <repo> <secret-name> <value>"
  exit 1
fi

REPO=$1
SECRET_NAME=$2
VALUE=$3

echo "$VALUE" | gh secret set "$SECRET_NAME" --repo "$REPO"

echo "Secret $SECRET_NAME set for $REPO"
