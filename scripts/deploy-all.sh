#!/usr/bin/env bash
set -euo pipefail

# Deploy everything: Bicep, storage container, webapp, app settings, and deploy app
# Usage:
#   RESOURCE_GROUP=my-rg WEBAPP_NAME=myapp ./scripts/deploy-all.sh

# Defaults
RESOURCE_GROUP=${RESOURCE_GROUP:-html5video-rg-$(date +%s)}
LOCATION=${LOCATION:-eastus}
STORAGE_ACCOUNT_NAME=${STORAGE_ACCOUNT_NAME:-html5videostor$(date +%s | cut -c1-8)}
COSMOSDB_ACCOUNT_NAME=${COSMOSDB_ACCOUNT_NAME:-html5videocdb$(date +%s | cut -c1-10)}
WEBAPP_NAME=${WEBAPP_NAME:-html5video-$(date +%s | cut -c1-8)}

if ! command -v az >/dev/null 2>&1; then
  echo "az CLI not found. Use Cloud Shell or install Azure CLI first."
  exit 1
fi

# Ensure logged in
if ! az account show >/dev/null 2>&1; then
  echo "Logging in to Azure (device code flow)..."
  az login --use-device-code
fi

echo "Using Resource Group: $RESOURCE_GROUP"
# Create RG
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Deploy bicep
echo "Deploying Bicep resources (Storage & Cosmos)..."
RESOURCE_GROUP="$RESOURCE_GROUP" STORAGE_ACCOUNT_NAME="$STORAGE_ACCOUNT_NAME" COSMOSDB_ACCOUNT_NAME="$COSMOSDB_ACCOUNT_NAME" LOCATION="$LOCATION" ./scripts/deploy-bicep.sh

# Get storage connection string
STORAGE_CONN=$(az storage account show-connection-string --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" -o tsv)
if [ -z "$STORAGE_CONN" ]; then
  echo "Failed to get storage connection string. Check permissions or existence of the storage account." >&2
  exit 1
fi

# Create container
az storage container create --name videos --connection-string "$STORAGE_CONN" || true

# Get Cosmos endpoint & key
COSMOS_ENDPOINT=$(az cosmosdb show --name "$COSMOSDB_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --query documentEndpoint -o tsv)
COSMOS_KEY=$(az cosmosdb keys list --name "$COSMOSDB_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --query primaryMasterKey -o tsv)

# Create or update the web app
echo "Creating and deploying web app: $WEBAPP_NAME"
az webapp up --name "$WEBAPP_NAME" --resource-group "$RESOURCE_GROUP" --runtime "NODE:18-lts" --logs

# Set app settings
echo "Setting app settings..."
az webapp config appsettings set --name "$WEBAPP_NAME" --resource-group "$RESOURCE_GROUP" --settings \
  AZURE_STORAGE_CONNECTION_STRING="$STORAGE_CONN" AZURE_BLOB_CONTAINER="videos" \
  AZURE_COSMOS_ENDPOINT="$COSMOS_ENDPOINT" AZURE_COSMOS_KEY="$COSMOS_KEY"

# Restart app
az webapp restart --name "$WEBAPP_NAME" --resource-group "$RESOURCE_GROUP"

APP_HOST=$(az webapp show --name "$WEBAPP_NAME" --resource-group "$RESOURCE_GROUP" --query defaultHostName -o tsv)

echo "Deployment complete. App URL: https://$APP_HOST"
echo "Tip: the app uses local file fallback if Storage/Cosmos are not configured. For production, rotate keys and use KeyVault + Managed Identity." 
