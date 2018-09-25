#!/bin/bash -e -o pipefail
#!/bin/bash
set -e -o pipefail

CHANGE_SET_NAME=$1
if [ -z $CHANGE_SET_NAME ]; then
  echo "You Must Specify a changeset name"
fi


STACK_NAME=$2
if [ -z $STACK_NAME ]; then
  STACK_NAME="pylambda"
fi

echo "excuting changeset $CHANGE_SET_NAME on stack $STACK_NAME..."
aws cloudformation execute-change-set --stack-name $STACK_NAME --change-set-name $CHANGE_SET_NAME
echo "waiting for update of $STACK_NAME to complete..."
aws cloudformation wait stack-update-complete --stack-name $STACK_NAME
echo "update of $STACK_NAME is complete, changeset $CHANGE_SET_NAME applied"
