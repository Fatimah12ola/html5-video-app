#!/usr/bin/env bash
set -e

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI (az) not found. Please install it: https://learn.microsoft.com/cli/azure/install-azure-cli"
  exit 1
fi

if [ -z "$AZURE_WEBAPP_NAME" ]; then
  echo "Please set AZURE_WEBAPP_NAME env var or export before running."
  echo "Usage: AZURE_WEBAPP_NAME=yourapp ./scripts/deploy-azure.sh"
  exit 1
fi

az webapp up --name "$AZURE_WEBAPP_NAME" --runtime "NODE:18-lts" --sku F1 --verbose

# If you have a zip package to deploy, use:
# az webapp deploy --name "$AZURE_WEBAPP_NAME" --resource-group <rg> --src-path . --type zip

# Set application settings for Storage & Cosmos if present in environment
if [ ! -z "$AZURE_STORAGE_CONNECTION_STRING" ]; then
  az webapp config appsettings set --name "$AZURE_WEBAPP_NAME" --settings AZURE_STORAGE_CONNECTION_STRING="$AZURE_STORAGE_CONNECTION_STRING"
fi
if [ ! -z "$AZURE_BLOB_CONTAINER" ]; then
  az webapp config appsettings set --name "$AZURE_WEBAPP_NAME" --settings AZURE_BLOB_CONTAINER="$AZURE_BLOB_CONTAINER"
fi
if [ ! -z "$AZURE_COSMOS_ENDPOINT" ]; then
  az webapp config appsettings set --name "$AZURE_WEBAPP_NAME" --settings AZURE_COSMOS_ENDPOINT="$AZURE_COSMOS_ENDPOINT"
fi
if [ ! -z "$AZURE_COSMOS_KEY" ]; then
  az webapp config appsettings set --name "$AZURE_WEBAPP_NAME" --settings AZURE_COSMOS_KEY="$AZURE_COSMOS_KEY"
fi

echo "Deployed and set app settings. You can now browse to https://$AZURE_WEBAPP_NAME.azurewebsites.net"