#!/usr/bin/env bash
set -e

# Simple tool checker for common CLI tools used by this project.

check_cmd() {
  cmd=$1
  friendly=$2
  if command -v $cmd >/dev/null 2>&1; then
    printf "%s: %s\n" "$friendly" "$($cmd --version 2>/dev/null || echo 'found')"
  else
    printf "%s: NOT FOUND\n" "$friendly"
  fi
}

check_cmd node "Node"
check_cmd npm "npm"
check_cmd git "git"
check_cmd gh "GitHub CLI (gh)"
check_cmd az "Azure CLI (az)"
check_cmd docker "Docker"

echo "If any tools are missing, follow the links below to install them:"
printf "- Node.js & npm: https://nodejs.org/\n"
printf "- Git: https://git-scm.com/downloads\n"
printf "- GitHub CLI: https://cli.github.com/\n"
printf "- Azure CLI: https://learn.microsoft.com/cli/azure/install-azure-cli\n"
printf "- Docker: https://docs.docker.com/get-docker/\n"

exit 0
