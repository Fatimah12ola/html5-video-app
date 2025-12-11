#!/usr/bin/env bash
set -e

OS="$(uname -s)"

if command -v az >/dev/null 2>&1; then
  echo "Azure CLI is already installed: $(az --version | head -n 1)"
  exit 0
fi

if [[ "$OS" == "Linux" ]]; then
  echo "Attempting to install Azure CLI on Linux (Debian/Ubuntu/WSL recommended)..."
  if command -v apt >/dev/null 2>&1; then
    echo "Running apt-based installer..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  elif command -v yum >/dev/null 2>&1; then
    echo "Using dnf/yum installer. Please follow docs: https://aka.ms/InstallAzureCLI"
  else
    echo "Unknown Linux package manager. See: https://learn.microsoft.com/cli/azure/install-azure-cli"
  fi
elif [[ "$OS" == "Darwin" ]]; then
  echo "Attempting Homebrew installation on macOS..."
  if command -v brew >/dev/null 2>&1; then
    brew update
    brew install azure-cli
  else
    echo "Homebrew not found. Install from https://brew.sh or visit https://learn.microsoft.com/cli/azure/install-azure-cli"
  fi
else
  echo "Windows detected — attempting to install using winget. You may need administrative privileges."
  if command -v winget >/dev/null 2>&1; then
    echo "Running: winget install --id Microsoft.AzureCLI -e --silent"
    winget install --id Microsoft.AzureCLI -e --silent || echo "winget install failed. Install manually: https://learn.microsoft.com/cli/azure/install-azure-cli"
  else
    echo "winget not found. Use https://aka.ms/installazurecliwindows for instructions"
  fi
fi

echo "Azure CLI installation attempt finished. Please re-open your terminal and run 'az --version' to verify."
