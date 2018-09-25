#!/bin/bash

## Set AWS Region
STATE=$1
if [ -z $STATE ]; then
  echo -e "State not set, default is create."
  STATE="create"
fi

## ColorVars
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ $STATE = "create" ]; then
  echo -e "${GREEN}Creating Lambda Stack.$NC"
  cd iam
  bash iam-role-bootstrap.sh create
  echo -e "${GREEN}Sleeping 10 for Role creation.$NC"
  sleep 10
  cd ../lambda
  bash deploy-lambda.sh create
  cd ..
elif [ $STATE = "update" ]; then
  echo -e "${GREEN}Updating Lambda Stack.$NC"
  cd iam
  bash iam-role-bootstrap.sh update
  cd ../lambda/
  bash deploy-lambda.sh update
  cd ..
elif [ $STATE = "delete" ]; then
  echo -e "${GREEN}Deleting Lambda Stack.$NC"
  cd lambda
  bash deploy-lambda.sh delete
  cd ../iam
  bash iam-role-bootstrap.sh delete
  cd ..
else
  echo -e "${RED}State $STATE is not a valid input, please use: [create, update, delete] $NC default is create"
  exit 1
fi
