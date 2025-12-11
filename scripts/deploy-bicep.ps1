param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroup,
    [Parameter(Mandatory=$false)]
    [string]$Location = 'eastus',
    [Parameter(Mandatory=$false)]
    [string]$StorageAccountName,
    [Parameter(Mandatory=$false)]
    [string]$CosmosDbAccountName
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

az deployment group create --resource-group $ResourceGroup --name $deploymentName --template-file azure/bicep/main.bicep --verbose

az group create --name $ResourceGroup --location $Location

if (-not $StorageAccountName) {
    $StorageAccountName = "html5videostor$([int][double]::Parse((Get-Date -UFormat %s)))"
    # enforce lowercase and 3-24 char length
    $StorageAccountName = $StorageAccountName.ToLower().Substring(0, [Math]::Min(24, $StorageAccountName.Length))
}
if (-not $CosmosDbAccountName) {
    $CosmosDbAccountName = "html5videocdb$([int][double]::Parse((Get-Date -UFormat %s)))"
    $CosmosDbAccountName = $CosmosDbAccountName.ToLower().Substring(0, [Math]::Min(44, $CosmosDbAccountName.Length))
}

$deploymentName = "html5video-$(Get-Date -UFormat %s)"
az deployment group create --resource-group $ResourceGroup --name $deploymentName --template-file azure/bicep/main.bicep --parameters storageAccountName=$StorageAccountName cosmosDbAccountName=$CosmosDbAccountName --verbose

az deployment group show --resource-group $ResourceGroup --name $deploymentName --query properties.outputs -o json

Write-Host "Bicep deployment completed (deployment: $deploymentName). Update your environment variables with the outputs as needed."