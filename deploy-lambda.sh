#!/bin/bash

## Set AWS Region
STATE=$1
if [ -z $STATE ]; then
  echo -e "State not set, default is create."
  STATE="create"
fi
#STATE="create"
#STATE="update"
#STATE="delete"

## ColorVars
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

## Define Variables
FUNCTION_NAME="pylambdaTest"
RUNTIME="python2.7"
ROLE_NAME="pylambdaTempRole"
ROLE_ARN=$(aws iam get-role --role-name $ROLE_NAME | jq -r .Role.Arn)
#ROLE_ARN="arn:aws:iam::958306274796:role/service-role/testLambdaRole"
HANDLER_NAME="pylambda.pylambda_handler"
ZIP_NAME="pylambda.zip"
TIME_OUT=5

# aws lambda create-function --function-name $FUNCTION_NAME \
#     --runtime $RUNTIME \
#     --role $ROLE_ARN \
#     --handler $HANDLER_NAME \
#     --zip-file fileb://$ZIP_NAME

if [ $STATE = "create" ]; then
  echo -e "${GREEN}Creating $FUNCTION_NAME lambda function.$NC"
  aws lambda create-function --function-name $FUNCTION_NAME \
      --runtime $RUNTIME \
      --role $ROLE_ARN \
      --handler $HANDLER_NAME \
      --zip-file fileb://$ZIP_NAME \
      --timeout $TIME_OUT
elif [ $STATE = "update" ]; then
  echo -e "${GREEN}Updating $FUNCTION_NAME lambda function.$NC"
  aws lambda update-function-code --function-name $FUNCTION_NAME \
      --zip-file fileb://$ZIP_NAME
  aws lambda update-function-configuration --function-name $FUNCTION_NAME \
      --role $ROLE_ARN \
      --handler $HANDLER_NAME \
      --timeout $TIME_OUT
elif [ $STATE = "delete" ]; then
  echo -e "${GREEN}Deleting $FUNCTION_NAME lambda function.$NC"
  aws lambda delete-function --function-name $FUNCTION_NAME
else
  echo -e "${RED}State $STATE is not a valid input, please use: [create, update, delete] $NC default is create"
  exit 1
fi
