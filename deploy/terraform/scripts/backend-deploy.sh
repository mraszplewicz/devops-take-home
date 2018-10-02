#!/bin/bash
set -e

APP_NAME=$1

# setting not available in terraform provider
az webapp config set --name $APP_NAME --startup-file "dotnet devops-app-api.dll"

USER=$(az webapp deployment list-publishing-profiles -n $APP_NAME --query "[?publishMethod=='MSDeploy'].userName" -o tsv)
PASSWORD=$(az webapp deployment list-publishing-profiles -n $APP_NAME --query "[?publishMethod=='MSDeploy'].userPWD" -o tsv)

az webapp show --name $APP_NAME

curl -X POST -u $USER:$PASSWORD --data-binary @/build.zip https://$APP_NAME.scm.azurewebsites.net/api/zipdeploy
