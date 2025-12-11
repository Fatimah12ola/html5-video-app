param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    [Parameter(Mandatory=$false)]
    [string]$Location = 'eastus'
)

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI (az) not found. Install it: https://learn.microsoft.com/cli/azure/install-azure-cli"
    exit 1
}

# Ensure user logged in
try {
    az account show >/dev/null 2>&1
} catch {
    Write-Host "Azure CLI is installed, but you're not logged in. Run 'az login' and try again."
    exit 1
}

az group create --name $ResourceGroup --location $Location

$deploymentName = "html5video-$(Get-Date -UFormat %s)"
az deployment group create --resource-group $ResourceGroup --name $deploymentName --template-file azure/bicep/main.bicep --verbose

az deployment group show --resource-group $ResourceGroup --name $deploymentName --query properties.outputs -o json

Write-Host "Bicep deployment completed (deployment: $deploymentName). Update your environment variables with the outputs as needed."