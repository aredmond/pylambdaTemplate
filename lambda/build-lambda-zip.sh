#!/bin/bash

### Get directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

### Check if build directory exists, create it if does not
BUILD_DIR_NAME="build"
if [ -d $BUILD_DIR_NAME ]; then
    echo "Folder $BUILD_DIR_NAME exists, skipping creation."
else
    mkdir $BUILD_DIR_NAME
fi
BUILD_DIR_PATH="$SCRIPT_DIR/$BUILD_DIR_NAME"

if [ -f setup.cfg ]; then
    echo "setup.cfg Exists"
else
    echo -e "[install]\nprefix=" > setup.cfg
fi

### Pull The debs info the build folder
#pip install requests --install-option="--prefix=$BUILD_DIR_PATH/requests"
pip install requests -t $BUILD_DIR_PATH
cp pylambda.py $BUILD_DIR_PATH
rm pylambda.zip
cd $BUILD_DIR_PATH;zip -r ../pylambda.zip *; cd $SCRIPT_DIR

rm -rf $BUILD_DIR_PATH
