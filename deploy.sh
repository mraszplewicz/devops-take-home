#!/bin/bash
# docker volume create azure.cfg

docker build -t deploy-devops-take-home -f deploy/Dockerfile .
docker run -v azure.cfg:/root/.azure deploy-devops-take-home