#!/bin/bash -e -o pipefail

while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
      -n|--stack-name)
        STACK_NAME="$2"
        if [[ "${STACK_NAME::1}" == "-" ]]; then
          echo "No stack name provided"
          exit -1
        fi
        shift # past argument
        ;;
      *)
        echo "unknown option $key provided"
        ;;
  esac
  shift # past argument or value
done


Template_File="cloudformation.yml"

if [ -z "$STACK_NAME" ]; then
  STACK_NAME="pylambda"
fi

## Create Change Set Name
DATE_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
CHANGE_SET_NAME=${STACK_NAME}-${DATE_STAMP}
CREATE_FAILED="false"

## Stored Parameters
export PARAMETERS_CONTENTS=$(envsubst < full_parameters.json)

echo "creating changeset $CHANGE_SET_NAME for stack $STACK_NAME..."
aws cloudformation create-change-set --stack-name $STACK_NAME --change-set-name $CHANGE_SET_NAME --template-body file://$Template_File --parameters "$PARAMETERS_CONTENTS" --capabilities CAPABILITY_NAMED_IAM
echo "waiting for changeset $CHANGE_SET_NAME to complete..."
aws cloudformation wait change-set-create-complete --stack-name $STACK_NAME --change-set-name $CHANGE_SET_NAME || { aws cloudformation describe-change-set --change-set-name $CHANGE_SET_NAME --stack-name $STACK_NAME | jq ". | {Status, StatusReason}" && CREATE_FAILED="true"; }
if [ $CREATE_FAILED = "true" ]; then
  echo "Deleting Failed change set"
  aws cloudformation delete-change-set --change-set-name $CHANGE_SET_NAME --stack-name $STACK_NAME
  exit -1
fi

echo "creation of $CHANGE_SET_NAME changeset is complete"
echo "Execute the changeset as follows: ./execute-changeset.sh $CHANGE_SET_NAME"
