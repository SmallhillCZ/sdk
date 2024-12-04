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
while getopts ":r:h" opt; do
    case ${opt} in
    r)
        REPO=$OPTARG
        ;;
    h)
        echo "Usage:"
        echo "  $CMD [options] <skeleton>"
        echo "Options:"
        echo "  -r <repo>  Use custom repo"
        exit 0
        ;;
    \?)
        echo "Error: Invalid option: $OPTARG" 1>&2
        exit 1
        ;;
    esac
done

CURRENT_BRANCH=$(git branch --show-current)

echo -e "Adding \033[33m$SKELETON\033[0m from \033[33m$REPO\033[0m to \033[33mskeleton\033[0m branch and merging to \033[33m$CURRENT_BRANCH\033[0m"

git clone --depth=1 $REPO $TEMP_DIR/skeleton 2>/dev/null

git switch -c skeleton 2>/dev/null

cp -r $TEMP_DIR/skeleton/$SKELETON ./ 2>/dev/null

git add -A
git commit -m "feat(skeleton): add $SKELETON from $REPO"

rm -fr $TEMP_DIR 2>/dev/null

git switch $CURRENT_BRANCH 2>/dev/null

git merge --no-ff skeleton
