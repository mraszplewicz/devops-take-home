# Deployment instructions

## Requirements
- bash
- Docker (all tools are installed in docker container)

Tested on Ubuntu 18.04 with Docker 18.03.1-ce

## Running Azure deployment
```
./deploy.sh
```

First run will ask for Azure credentials. You have to use provided link and device code. It will take about 30 minutes or more to complete, so please be patient!

Terraform will write app_url at the end of the output.

## Tools used
- Bash
- Docker (to build and run the code)
- Terraform
- Sqlcmd
- Azure CLI

## Azure resources used
- Application gateway
- Storage with static website hosting
- App Service
- Azure SQL