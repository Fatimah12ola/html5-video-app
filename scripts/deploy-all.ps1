param(
  [string]$ResourceGroup = $("html5video-rg-{0}" -f (Get-Date -UFormat %s)),
  [string]$Location = 'eastus',
  [string]$StorageAccountName = $("html5videostor{0}" -f (Get-Date -UFormat %s)),
  [string]$CosmosDbAccountName = $("html5videocdb{0}" -f (Get-Date -UFormat %s)),
  [string]$WebAppName = $("html5video{0}" -f (Get-Date -UFormat %s))
)

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
  Write-Error "Azure CLI (az) not found. Use Cloud Shell or install it first: https://aka.ms/installazurecli"
  exit 1
}

# Ensure logged in
try { az account show > $null } catch { az login --use-device-code }

Write-Host "Using Resource Group: $ResourceGroup"
az group create --name $ResourceGroup --location $Location | Out-Null

Write-Host "Deploying bicep resources..."
& "$PSScriptRoot\deploy-bicep.ps1" -ResourceGroup $ResourceGroup -Location $Location -StorageAccountName $StorageAccountName -CosmosDbAccountName $CosmosDbAccountName

$StorageConn = az storage account show-connection-string --name $StorageAccountName --resource-group $ResourceGroup -o tsv
if (-not $StorageConn) { Write-Error "Failed to fetch storage connection string"; exit 1 }

az storage container create --name videos --connection-string $StorageConn | Out-Null

$CosmosEndpoint = az cosmosdb show --name $CosmosDbAccountName --resource-group $ResourceGroup --query documentEndpoint -o tsv
$CosmosKey = az cosmosdb keys list --name $CosmosDbAccountName --resource-group $ResourceGroup --query primaryMasterKey -o tsv

Write-Host "Creating & deploying web app: $WebAppName"
az webapp up --name $WebAppName --resource-group $ResourceGroup --runtime "NODE:18-lts" --logs

Write-Host "Setting app settings..."
az webapp config appsettings set --name $WebAppName --resource-group $ResourceGroup --settings \
  "AZURE_STORAGE_CONNECTION_STRING=$StorageConn" "AZURE_BLOB_CONTAINER=videos" "AZURE_COSMOS_ENDPOINT=$CosmosEndpoint" "AZURE_COSMOS_KEY=$CosmosKey"

az webapp restart --name $WebAppName --resource-group $ResourceGroup | Out-Null

$host = az webapp show --name $WebAppName --resource-group $ResourceGroup --query defaultHostName -o tsv
Write-Host "Deployment complete. App URL: https://$host"
