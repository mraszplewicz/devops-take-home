#!/bin/bash
set -e

eval "$(jq -r '@sh "STORAGE_ACCOUNT=\(.storage_account)"')"

URL=$(az storage account show -n $STORAGE_ACCOUNT --query "primaryEndpoints.web" --output tsv)

jq -n --arg url "$URL" '{"url":$url}'