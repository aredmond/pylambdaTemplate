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
  STACK_NAME="pylambda"
fi

## Stored Parameters
export PARAMETERS_CONTENTS=$(envsubst < bootstrap_parameters.json)

echo "creating $STACK_NAME stack..."
aws cloudformation create-stack --stack-name $STACK_NAME --template-body file://$Template_File --parameters "$PARAMETERS_CONTENTS" --capabilities CAPABILITY_NAMED_IAM
echo "waiting for creation of $STACK_NAME to complete..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
echo "creation of $STACK_NAME is complete"
