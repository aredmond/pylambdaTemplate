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


Template_File="cloudformation_bootstrap.yml"

if [ -z "$STACK_NAME" ]; then
  STACK_NAME=pylambda
fi

## Stored Parameters
export PARAMETERS_CONTENTS=$(envsubst < bootstrap_parameters.json)

echo "deleting $STACK_NAME stack..."
aws cloudformation delete-stack --stack-name $STACK_NAME
echo "waiting for deletion of $STACK_NAME to complete..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME
echo "deletion of $STACK_NAME is complete"
