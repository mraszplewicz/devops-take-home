#!/bin/bash
# docker volume create azure.cfg

docker build -t deploy-devops-take-home -f deploy/Dockerfile .
docker run \
    -e "ENVIRONMENT_NAME=$ENVIRONMENT_NAME" \
    -v azure.cfg:/root/.azure \
    -v //var/run/docker.sock:/var/run/docker.sock \
    deploy-devops-take-home