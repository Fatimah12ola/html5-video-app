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

# Deploy the Bicep
az deployment group create --resource-group "$RESOURCE_GROUP" --template-file azure/bicep/main.bicep

# Display outputs
az deployment group show --name $(basename "$RESOURCE_GROUP") --resource-group "$RESOURCE_GROUP" --query properties.outputs

echo "Bicep deployment completed. Update your environment variables with the outputs as needed."