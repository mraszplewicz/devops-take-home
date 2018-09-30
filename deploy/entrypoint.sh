#!/bin/bash
set -e

ORGANIZATION_PREFIX=mrasoft
AZURE_LOCATION=westeurope
AZURE_RESOURCE_GROUP=cyberVAutomated
TF_STATE_STORAGE_ACCOUNT_NAME=${ORGANIZATION_PREFIX}tfstate
ENVIRONMENT_NAME=${ENVIRONMENT_NAME:=devops}
TF_STATE_STORAGE_CONTAINER_NAME="tfstate-$ENVIRONMENT_NAME"
SYSTEM_NAME=security-incident-list

if az account show
then 
  echo "Using azure cli stored credentials..."
else
  az login
fi

#compile application and copy to /build 
cd /src/backend/app
docker build -t devops-app-api .
APP_CONTAINER_ID=$(docker create devops-app-api)
docker cp $APP_CONTAINER_ID:/app /build
cd -

# az group create --name $AZURE_RESOURCE_GROUP --location $AZURE_LOCATION
az configure --defaults location=$AZURE_LOCATION group=$AZURE_RESOURCE_GROUP

# az storage account create \
#     --name $TF_STATE_STORAGE_ACCOUNT_NAME \
#     --sku Standard_LRS

TF_STATE_ARM_ACCESS_KEY=$(az storage account keys list --account-name $TF_STATE_STORAGE_ACCOUNT_NAME --query [0].value)

# az storage container create \
#     --name $TF_STATE_STORAGE_CONTAINER_NAME \
#     --account-name $TF_STATE_STORAGE_ACCOUNT_NAME \
#     --account-key $TF_STATE_ARM_ACCESS_KEY

# terraform force-unlock -force b9b3a9e5-c5ef-ce0a-8681-3cdbaee89c0b
terraform init \
    -backend-config="storage_account_name=$TF_STATE_STORAGE_ACCOUNT_NAME" \
    -backend-config="container_name=$TF_STATE_STORAGE_CONTAINER_NAME" \
    -backend-config="key=$SYSTEM_NAME.tfstate" \
    -backend-config="access_key=$TF_STATE_ARM_ACCESS_KEY"

export TF_VAR_system_name=$SYSTEM_NAME
export TF_VAR_environment_name=$ENVIRONMENT_NAME
export TF_VAR_resource_group=$AZURE_RESOURCE_GROUP
export TF_VAR_location=$AZURE_LOCATION

# terraform plan 
terraform apply -auto-approve
