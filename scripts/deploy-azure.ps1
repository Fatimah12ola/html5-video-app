param(
    [Parameter(Mandatory = $true)]
    [string]$WebAppName
)

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI (az) not found. Install it: https://learn.microsoft.com/cli/azure/install-azure-cli"
    exit 1
}

az webapp up --name $WebAppName --runtime "NODE:18-lts" --sku F1 --verbose

if ($env:AZURE_STORAGE_CONNECTION_STRING) {
    az webapp config appsettings set --name $WebAppName --settings AZURE_STORAGE_CONNECTION_STRING="$env:AZURE_STORAGE_CONNECTION_STRING"
}
if ($env:AZURE_BLOB_CONTAINER) {
    az webapp config appsettings set --name $WebAppName --settings AZURE_BLOB_CONTAINER="$env:AZURE_BLOB_CONTAINER"
}
if ($env:AZURE_COSMOS_ENDPOINT) {
    az webapp config appsettings set --name $WebAppName --settings AZURE_COSMOS_ENDPOINT="$env:AZURE_COSMOS_ENDPOINT"
}
if ($env:AZURE_COSMOS_KEY) {
    az webapp config appsettings set --name $WebAppName --settings AZURE_COSMOS_KEY="$env:AZURE_COSMOS_KEY"
}

Write-Host "Deployed and set app settings. Browse to https://$WebAppName.azurewebsites.net"