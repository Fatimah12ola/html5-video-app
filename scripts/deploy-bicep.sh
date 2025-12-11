#!/usr/bin/env bash
set -e

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI (az) not found. Please install it: https://learn.microsoft.com/cli/azure/install-azure-cli"
  exit 1
fi

if [ -z "$RESOURCE_GROUP" ]; then
  echo "Please set RESOURCE_GROUP environment variable: export RESOURCE_GROUP=my-rg"
  exit 1
fi

if [ -z "$LOCATION" ]; then
  LOCATION="eastus"
fi

az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

# Generate storage and cosmos account names if not provided
if [ -z "$STORAGE_ACCOUNT_NAME" ]; then
  STORAGE_ACCOUNT_NAME="html5videostor$(date +%s)"
  STORAGE_ACCOUNT_NAME=$(echo "$STORAGE_ACCOUNT_NAME" | tr '[:upper:]' '[:lower:]' | cut -c1-24)
fi
if [ -z "$COSMOSDB_ACCOUNT_NAME" ]; then
  COSMOSDB_ACCOUNT_NAME="html5videocdb$(date +%s)"
  COSMOSDB_ACCOUNT_NAME=$(echo "$COSMOSDB_ACCOUNT_NAME" | tr '[:upper:]' '[:lower:]' | cut -c1-44)
fi

# Deploy the Bicep with a deterministic name and show outputs
DEPLOYMENT_NAME="html5video-$(date +%s)"
az deployment group create --resource-group "$RESOURCE_GROUP" --name "$DEPLOYMENT_NAME" --template-file azure/bicep/main.bicep --parameters storageAccountName=$STORAGE_ACCOUNT_NAME cosmosDbAccountName=$COSMOSDB_ACCOUNT_NAME --verbose

# Display outputs
az deployment group show --resource-group "$RESOURCE_GROUP" --name "$DEPLOYMENT_NAME" --query properties.outputs -o json

echo "Bicep deployment completed (deployment: $DEPLOYMENT_NAME). Update your environment variables with the outputs as needed."