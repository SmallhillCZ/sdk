#!/bin/bash

REPO=https://github.com/smallhillcz/sdk
CMD=$(basename $0)
TEMP_DIR=$(mktemp -d)

# get command used to run this script

SKELETON=$1
# error if skeleton is not specified
if [ -z "$SKELETON" ]; then
    echo "Please specify skeleton folder"
    exit 1
fi

# select custom repo with -r option
while getopts "r:h" opt; do
    case ${opt} in
    r)
        REPO=$OPTARG
        echo "Using custom repo $REPO"
        ;;
    h)
        echo "Usage:"
        echo "  $CMD [options] <skeleton>"
        echo "Options:"
        echo "  -r <repo>  Use custom repo"
        exit 0
        ;;
    \?)
        echo "Invalid option: $OPTARG" 1>&2
        exit 1
        ;;
    esac
done

git switch -c skeleton

git clone --depth=1 $REPO $TEMP_DIR/skeleton

cd $TEMP_DIR/skeleton

ls

# cp -r $TEMP_DIR/skeleton/$SKELETON $MODULE_PATH/

# rm -fr $TEMP_DIR
