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

## Set Variables
ROLE_NAME="pylambdaTempRole"
BASIC_POLICY_NAME="pylambdaTempBasicPolicy"
ACCESS_POLICY_NAME="pylambdaTempAccessPolicy"


if [ $STATE = "create" ]; then
  echo -e "${GREEN}Creating IAM Role ${ROLE_NAME}.$NC"
  ## Create Basic Policy allowing the lambda fuction to log its output
  BASIC_POLICY_OUTPUT=$(aws iam create-policy --policy-name $BASIC_POLICY_NAME \
      --policy-document file://basic_policy.json)
  echo $BASIC_POLICY_OUTPUT
  BASIC_POLICY_ARN=$(echo $BASIC_POLICY_OUTPUT | jq -r .Policy.Arn)
  ## Create Access Policy allowing the lambda fuction to interact with AWS Resources
  ACCESS_POLICY_OUTPUT=$(aws iam create-policy --policy-name $ACCESS_POLICY_NAME \
      --policy-document file://access_policy.json)
  echo $ACCESS_POLICY_OUTPUT
  ACCESS_POLICY_ARN=$(echo $ACCESS_POLICY_OUTPUT | jq -r .Policy.Arn)
  ## Create the role the lambda function will assume
  ROLE_OUTPUT=$(aws iam create-role --role-name $ROLE_NAME \
      --path "/service-role/" \
      --assume-role-policy-document file://trust_policy.json)
  ## Attach the policies created above to the lambda role
  aws iam attach-role-policy --role-name $ROLE_NAME \
      --policy-arn $BASIC_POLICY_ARN
  aws iam attach-role-policy --role-name $ROLE_NAME \
      --policy-arn $ACCESS_POLICY_ARN
elif [ $STATE = "update" ]; then
  echo -e "${GREEN}Updating IAM Role ${ROLE_NAME}.$NC"
  ## Create New Basic Policy Version and Set as Default
  BASIC_POLICY_ARN=$(aws iam list-policies | jq -r ".Policies[] | select(.PolicyName==\"$BASIC_POLICY_NAME\") | .Arn")
  aws iam create-policy-version --policy-arn $BASIC_POLICY_ARN \
      --policy-document file://basic_policy.json \
      --set-as-default
  ## Create New Access Policy Version and Set as Default
  ACCESS_POLICY_ARN=$(aws iam list-policies | jq -r ".Policies[] | select(.PolicyName==\"$ACCESS_POLICY_NAME\") | .Arn")
  aws iam create-policy-version --policy-arn $ACCESS_POLICY_ARN \
      --policy-document file://access_policy.json \
      --set-as-default
  ## Delete Old Versions of Policies
  BASIC_VERSIONS_LIST=$(aws iam list-policy-versions --policy-arn $BASIC_POLICY_ARN)
  echo $BASIC_VERSIONS_LIST | jq -r '.Versions[] | select(.IsDefaultVersion==false) | .VersionId' | xargs -I{} sh -c "aws iam delete-policy-version --policy-arn $BASIC_POLICY_ARN --version-id {}"
  ACCESS_VERSIONS_LIST=$(aws iam list-policy-versions --policy-arn $ACCESS_POLICY_ARN)
  echo $ACCESS_VERSIONS_LIST | jq -r '.Versions[] | select(.IsDefaultVersion==false) | .VersionId' | xargs -I{} sh -c "aws iam delete-policy-version --policy-arn $ACCESS_POLICY_ARN --version-id {}"
  ## Update Trust Policy
  aws iam update-assume-role-policy --role-name $ROLE_NAME \
      --policy-document file://trust_policy.json
elif [ $STATE = "delete" ]; then
  #echo -e "${GREEN}Deleting IAM Role ${ROLE_NAME}.$NC"
  BASIC_POLICY_ARN=$(aws iam list-policies | jq -r ".Policies[] | select(.PolicyName==\"$BASIC_POLICY_NAME\") | .Arn")
  ACCESS_POLICY_ARN=$(aws iam list-policies | jq -r ".Policies[] | select(.PolicyName==\"$ACCESS_POLICY_NAME\") | .Arn")
  ## Detatch Policies
  aws iam detach-role-policy --role-name $ROLE_NAME \
      --policy-arn $BASIC_POLICY_ARN
  aws iam detach-role-policy --role-name $ROLE_NAME \
      --policy-arn $ACCESS_POLICY_ARN
  ## Delete Old Versions of Policies
  BASIC_VERSIONS_LIST=$(aws iam list-policy-versions --policy-arn $BASIC_POLICY_ARN)
  echo $BASIC_VERSIONS_LIST | jq -r '.Versions[] | select(.IsDefaultVersion==false) | .VersionId' | xargs -I{} sh -c "aws iam delete-policy-version --policy-arn $BASIC_POLICY_ARN --version-id {}"
  ACCESS_VERSIONS_LIST=$(aws iam list-policy-versions --policy-arn $ACCESS_POLICY_ARN)
  echo $ACCESS_VERSIONS_LIST | jq -r '.Versions[] | select(.IsDefaultVersion==false) | .VersionId' | xargs -I{} sh -c "aws iam delete-policy-version --policy-arn $ACCESS_POLICY_ARN --version-id {}"
  ## Delete default Policies
  aws iam delete-policy --policy-arn $BASIC_POLICY_ARN
  aws iam delete-policy --policy-arn $ACCESS_POLICY_ARN
  ## Delete Role
  aws iam delete-role --role-name $ROLE_NAME
else
  echo -e "${RED}State $STATE is not a valid input, please use: [create, update, delete] $NC default is create"
  exit 1
fi
