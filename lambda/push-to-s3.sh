#!/bin/bash

FUNCTION_BUCKET="dumpzonehg"
FUCTION_BUCKET_FOLDER="pylambda"
ZIP_NAME="pylambda.zip"
ZIP_S3_URL="s3://${FUNCTION_BUCKET}/${FUCTION_BUCKET_FOLDER}/${ZIP_NAME}"

## ColorVars
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Pushing lambda zip to ${ZIP_S3_URL}${NC}"
aws s3 cp $ZIP_NAME $ZIP_S3_URL
