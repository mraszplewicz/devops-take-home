#!/bin/bash
set -e

APP_GATEWAY_NAME=$1
FRONTEND_HTTP_SETTINGS_NAME=$2

az network application-gateway http-settings update --gateway-name $APP_GATEWAY_NAME \
                            --name $FRONTEND_HTTP_SETTINGS_NAME --host-name-from-backend-pool true