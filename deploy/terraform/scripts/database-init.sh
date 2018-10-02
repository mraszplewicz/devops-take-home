#!/bin/bash
set -e

SQL_SERVER_NAME=$1
DB_HOST=$2
DB_PORT=$3
DB_NAME=$4
DB_USER=$5
DB_PASSWORD=$6
RULE_NAME="initDBIP"

PUBLIC_IP=$(curl -s http://whatismyip.akamai.com/)

az sql server firewall-rule create -s $SQL_SERVER_NAME -n $RULE_NAME --start-ip-address $PUBLIC_IP --end-ip-address $PUBLIC_IP

# run initialization in docker - you don't have to install sqlcmd
cd /src/backend/db
docker build -t database-init .
docker run database-init /opt/mssql-tools/bin/sqlcmd -S tcp:$DB_HOST,$DB_PORT -d $DB_NAME -U $DB_USER -P $DB_PASSWORD -i /app/initialize-db.azuresql.sql
cd -

az sql server firewall-rule delete --name $RULE_NAME --server $SQL_SERVER_NAME