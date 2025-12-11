#!/usr/bin/env bash
set -euo pipefail

# deploy-cloudshell.sh
# Usage:
#  ./scripts/deploy-cloudshell.sh --repo <owner/repo> [--subscription <sub id>] [--create-sp yes|no] [--resource-group <rg>] [--webapp <name>]

REPO=${REPO:-}
SUBSCRIPTION_ID=${SUBSCRIPTION_ID:-}
CREATE_SP=${CREATE_SP:-yes}
RESOURCE_GROUP=${RESOURCE_GROUP:-html5video-rg-$(date +%s)}
LOCATION=${LOCATION:-eastus}
STORAGE_ACCOUNT_NAME=${STORAGE_ACCOUNT_NAME:-html5videostor$(date +%s | cut -c1-8)}
COSMOSDB_ACCOUNT_NAME=${COSMOSDB_ACCOUNT_NAME:-html5videocdb$(date +%s | cut -c1-10)}
WEBAPP_NAME=${WEBAPP_NAME:-html5video-$(date +%s | cut -c1-8)}

# parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --repo) shift; REPO=$1; shift;;
    --subscription) shift; SUBSCRIPTION_ID=$1; shift;;
    --create-sp) shift; CREATE_SP=$1; shift;;
    --resource-group) shift; RESOURCE_GROUP=$1; shift;;
    --webapp) shift; WEBAPP_NAME=$1; shift;;
    --location) shift; LOCATION=$1; shift;;
    --storage) shift; STORAGE_ACCOUNT_NAME=$1; shift;;
    --cosmos) shift; COSMOSDB_ACCOUNT_NAME=$1; shift;;
    --help) echo "Usage: $0 --repo owner/repo [options]"; exit 0;;
    *) echo "Unknown arg $1"; echo "Usage: $0 --repo owner/repo [--subscription <sub id>]"; exit 1;;
  esac
done

if [ -z "$REPO" ]; then
  echo "Please specify a repo with --repo owner/repo"
  exit 1
fi

# Ensure az and gh are available
if ! command -v az >/dev/null 2>&1; then
  echo "Error: az CLI not found. Run in Cloud Shell or install the Azure CLI." >&2
  exit 1
fi
if ! command -v gh >/dev/null 2>&1; then
  echo "Error: gh CLI not found. Install GitHub CLI (https://cli.github.com/) and run 'gh auth login'." >&2
  exit 1
fi

# Use subscription if provided
if [ -n "$SUBSCRIPTION_ID" ]; then
  az account set --subscription "$SUBSCRIPTION_ID"
fi

# Create Service Principal if requested
if [ "$CREATE_SP" = "yes" ]; then
  echo "Creating a new Service Principal (sdk-auth JSON) with Contributor role on the subscription..."
  if [ -z "$SUBSCRIPTION_ID" ]; then
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
  fi
  az ad sp create-for-rbac --name html5video-sp --role contributor --scopes /subscriptions/$SUBSCRIPTION_ID --sdk-auth > sp.json
  AZ_CREDENTIALS_JSON=$(cat sp.json)
else
  if [ -z "$AZURE_CREDENTIALS" ]; then
    echo "AZURE_CREDENTIALS not set; either set it or pass --create-sp yes" >&2
    exit 1
  fi
  AZ_CREDENTIALS_JSON="$AZURE_CREDENTIALS"
fi

# Confirm gh auth
if ! gh auth status >/dev/null 2>&1; then
  echo "GitHub CLI not authenticated. Running 'gh auth login'..."
  gh auth login
fi

# Set GitHub secrets
set_secret() {
  secret_name=$1
  secret_value=$2
  if [ -z "$secret_value" ]; then
    echo "Warning: $secret_name value is empty, skipping..."
    return
  fi
  echo -n "$secret_value" | gh secret set "$secret_name" --repo "$REPO"
  echo "Set GitHub secret: $secret_name"
}

# Set AZURE_CREDENTIALS
echo "Adding Service Principal JSON as AZURE_CREDENTIALS in GitHub (repo: $REPO)"
set_secret "AZURE_CREDENTIALS" "$AZ_CREDENTIALS_JSON"
set_secret "AZURE_WEBAPP_NAME" "$WEBAPP_NAME"
set_secret "AZURE_RESOURCE_GROUP" "$RESOURCE_GROUP"
set_secret "AZURE_BLOB_CONTAINER" "videos"

# Fetch storage connection string & cosmos keys
echo "Fetching storage connection string..."
STORAGE_CONN=$(az storage account show-connection-string --name "$STORAGE_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" -o tsv || true)
if [ -z "$STORAGE_CONN" ]; then
  echo "Storage connection string empty. If the storage account was not created yet, it will be created during infra deploy. Skipping setting secret for now."
else
  set_secret "AZURE_STORAGE_CONNECTION_STRING" "$STORAGE_CONN"
fi

COSMOS_ENDPOINT=$(az cosmosdb show --name "$COSMOSDB_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --query documentEndpoint -o tsv || true)
COSMOS_KEY=$(az cosmosdb keys list --name "$COSMOSDB_ACCOUNT_NAME" --resource-group "$RESOURCE_GROUP" --query primaryMasterKey -o tsv || true)
if [ -n "$COSMOS_ENDPOINT" ]; then
  set_secret "AZURE_COSMOS_ENDPOINT" "$COSMOS_ENDPOINT"
fi
if [ -n "$COSMOS_KEY" ]; then
  set_secret "AZURE_COSMOS_KEY" "$COSMOS_KEY"
fi

# Run the deploy script in the current Cloud Shell/session
echo "Running deploy-all script to create infra and app..."
RESOURCE_GROUP="$RESOURCE_GROUP" STORAGE_ACCOUNT_NAME="$STORAGE_ACCOUNT_NAME" COSMOSDB_ACCOUNT_NAME="$COSMOSDB_ACCOUNT_NAME" WEBAPP_NAME="$WEBAPP_NAME" LOCATION="$LOCATION" bash ./scripts/deploy-all.sh

# Final: output app URL
APP_HOST=$(az webapp show --name $WEBAPP_NAME --resource-group $RESOURCE_GROUP --query defaultHostName -o tsv)
if [ -n "$APP_HOST" ]; then
  echo "App URL: https://$APP_HOST"
fi

echo "Done. If you used a created Service Principal ('sp.json'), consider removing it from the local machine and rotating the secrets."