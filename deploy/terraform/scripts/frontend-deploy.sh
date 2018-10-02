#!/bin/bash
set -e

STORAGE_ACCOUNT_NAME=$1

az extension add --name storage-preview || true

az storage blob service-properties update --account-name $STORAGE_ACCOUNT_NAME --static-website --404-document index.html --index-document index.html

az storage blob upload-batch -s /src/frontend -d \$web --account-name $STORAGE_ACCOUNT_NAME
