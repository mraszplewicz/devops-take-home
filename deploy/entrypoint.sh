#!/bin/sh
set -e

ORGANIZATION_PREFIX=mrasoft
AZURE_LOCATION=westeurope
AZURE_RESOURCE_GROUP=cyberVAutomated
TF_STATE_STORAGE_ACCOUNT_NAME=${ORGANIZATION_PREFIX}tfstate
ENVIRONMENT_NAME=devops
TF_STATE_STORAGE_CONTAINER_NAME="tfstate-$ENVIRONMENT_NAME"
SYSTEM_NAME=security-incident-list

if az account show
then 
  echo "Using azure cli stored credentials..."
else
  az login
fi

az group create --name $AZURE_RESOURCE_GROUP --location $AZURE_LOCATION
az configure --defaults location=$AZURE_LOCATION group=$AZURE_RESOURCE_GROUP

az storage account create \
    --name $TF_STATE_STORAGE_ACCOUNT_NAME \
    --sku Standard_LRS

TF_STATE_ARM_ACCESS_KEY=$(az storage account keys list --account-name $TF_STATE_STORAGE_ACCOUNT_NAME --query [0].value)

az storage container create \
    --name $TF_STATE_STORAGE_CONTAINER_NAME \
    --account-name $TF_STATE_STORAGE_ACCOUNT_NAME \
    --account-key $TF_STATE_ARM_ACCESS_KEY

terraform init \
    -backend-config="storage_account_name=$TF_STATE_STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=$TF_STATE_STORAGE_CONTAINER_NAME" \
    -backend-config="key=$SYSTEM_NAME.tfstate" \
    -backend-config="access_key=$TF_STATE_ARM_ACCESS_KEY"

# az account list-locations


#  group=MyResourceGroup

# az storage account list

# az storage account create \
#     --location <location> \
#     --name <account_name> \
#     --resource-group <resource_group> \
#     --sku <account_sku>

# terraform --help


# terraform apply