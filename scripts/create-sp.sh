#!/usr/bin/env bash
set -euo pipefail

if ! command -v az >/dev/null 2>&1; then
  echo "az CLI not found. Run this script in Azure Cloud Shell or install the Azure CLI."
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 <subscription-id>"
  echo "This will create a service principal with contributor role on the subscription."
  exit 1
fi
SUBSCRIPTION_ID=$1

read -p "Service principal name (default: html5video-sp): " SP_NAME
SP_NAME=${SP_NAME:-html5video-sp}

az account set --subscription "$SUBSCRIPTION_ID"

# Create the SP
CREDS=$(az ad sp create-for-rbac --name "$SP_NAME" --role contributor --scopes /subscriptions/$SUBSCRIPTION_ID --sdk-auth)

if [ -z "$CREDS" ]; then
  echo "Failed to create service principal. Check permissions."
  exit 1
fi

# Output instructions
cat <<EOF
Service principal created. Add the following JSON as the GitHub secret named 'AZURE_CREDENTIALS':

$CREDS

And set these repository secrets in GitHub:
- AZURE_WEBAPP_NAME: <your webapp name>
- AZURE_RESOURCE_GROUP: <your resource group name>
- AZURE_STORAGE_CONNECTION_STRING: <storage connection string>
- AZURE_BLOB_CONTAINER: videos
- AZURE_COSMOS_ENDPOINT: <cosmos endpoint>
- AZURE_COSMOS_KEY: <cosmos primary key>

You can now push to 'main' to trigger the CI/CD deployment workflow.
EOF
