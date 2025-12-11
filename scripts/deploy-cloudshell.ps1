param(
  [Parameter(Mandatory=$true)]
  [string]$Repo,
  [Parameter(Mandatory=$false)]
  [string]$SubscriptionId = $null,
  [Parameter(Mandatory=$false)]
  [string]$ResourceGroup = $("html5video-rg-{0}" -f (Get-Date -UFormat %s)),
  [Parameter(Mandatory=$false)]
  [string]$Location = 'eastus',
  [Parameter(Mandatory=$false)]
  [string]$StorageAccountName = $("html5videostor{0}" -f (Get-Date -UFormat %s)),
  [Parameter(Mandatory=$false)]
  [string]$CosmosDbAccountName = $("html5videocdb{0}" -f (Get-Date -UFormat %s)),
  [Parameter(Mandatory=$false)]
  [string]$WebAppName = $("html5video{0}" -f (Get-Date -UFormat %s)),
  [Parameter(Mandatory=$false)]
  [ValidateSet('yes','no')]
  [string]$CreateSp = 'yes'
)

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Error 'Azure CLI (az) not found. Use Cloud Shell or install the Azure CLI.'
    exit 1
}
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Error 'GitHub CLI (gh) not found. Install it and run gh auth login.'
    exit 1
}

if ($SubscriptionId) { az account set --subscription $SubscriptionId }

# Create SP if requested
if ($CreateSp -eq 'yes') {
    if (-not $SubscriptionId) { $SubscriptionId = az account show --query id -o tsv }
    Write-Host "Creating Service Principal..."
    $credsJson = az ad sp create-for-rbac --name html5video-sp --role contributor --scopes /subscriptions/$SubscriptionId --sdk-auth | Out-String
} else {
    if (-not $env:AZURE_CREDENTIALS) { Write-Error 'AZURE_CREDENTIALS not set. Provide it or set CreateSp to yes.'; exit 1 }
    $credsJson = $env:AZURE_CREDENTIALS
}

# Authenticate gh
try { gh auth status } catch { gh auth login }

function Set-Secret([string]$repo, [string]$name, [string]$value) {
    if ([string]::IsNullOrEmpty($value)) { Write-Host "Skipping empty secret: $name"; return }
    $value | gh secret set $name --repo $repo
    Write-Host "Set secret $name for $repo"
}

Set-Secret -repo $Repo -name 'AZURE_CREDENTIALS' -value $credsJson
Set-Secret -repo $Repo -name 'AZURE_WEBAPP_NAME' -value $WebAppName
Set-Secret -repo $Repo -name 'AZURE_RESOURCE_GROUP' -value $ResourceGroup
Set-Secret -repo $Repo -name 'AZURE_BLOB_CONTAINER' -value 'videos'

# Try to fetch storage & cosmos details
$storageConn = az storage account show-connection-string --name $StorageAccountName --resource-group $ResourceGroup -o tsv 2>$null
if ($storageConn) { Set-Secret -repo $Repo -name 'AZURE_STORAGE_CONNECTION_STRING' -value $storageConn }
$cosmosEndpoint = az cosmosdb show --name $CosmosDbAccountName --resource-group $ResourceGroup --query documentEndpoint -o tsv 2>$null
$cosmosKey = az cosmosdb keys list --name $CosmosDbAccountName --resource-group $ResourceGroup --query primaryMasterKey -o tsv 2>$null
if ($cosmosEndpoint) { Set-Secret -repo $Repo -name 'AZURE_COSMOS_ENDPOINT' -value $cosmosEndpoint }
if ($cosmosKey) { Set-Secret -repo $Repo -name 'AZURE_COSMOS_KEY' -value $cosmosKey }

# Run the deploy
$env:RESOURCE_GROUP = $ResourceGroup
$env:STORAGE_ACCOUNT_NAME = $StorageAccountName
$env:COSMOSDB_ACCOUNT_NAME = $CosmosDbAccountName
$env:WEBAPP_NAME = $WebAppName
$env:LOCATION = $Location

Write-Host "Running deploy-all.ps1..."
& "$PSScriptRoot\deploy-all.ps1" -ResourceGroup $ResourceGroup -Location $Location -StorageAccountName $StorageAccountName -CosmosDbAccountName $CosmosDbAccountName -WebAppName $WebAppName

$host = az webapp show --name $WebAppName --resource-group $ResourceGroup --query defaultHostName -o tsv
if ($host) { Write-Host "Deployment complete. App URL: https://$host" }
