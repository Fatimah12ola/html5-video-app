param()

# This script attempts to install Azure CLI on Windows if winget is available. Otherwise it prints instructions.

if (Get-Command az -ErrorAction SilentlyContinue) {
    Write-Host "Azure CLI is already installed: $(az --version | Out-String -Stream | Select-Object -First 1)"
    Exit 0
}

if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Installing Azure CLI using winget. May require admin privileges."
    winget install --id Microsoft.AzureCLI -e --accept-package-agreements --accept-source-agreements
    Write-Host "If the command succeeded, reopen PowerShell and run 'az --version'."
} else {
    Write-Host "winget not found. Install Azure CLI manually from: https://learn.microsoft.com/cli/azure/install-azure-cli"
}
