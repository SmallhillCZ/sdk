#!/bin/bash

REPO=https://github.com/smallhillcz/sdk
CMD=$(basename $0)
TEMP_DIR=$(mktemp -d)
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

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_BRANCH=$(git branch --show-current)

TARGET_DIR=$SKELETON
TARGET_EXISTS=$(ls -A | grep $TARGET_DIR)

if [ -z "$TARGET_EXISTS" ]; then
    echo -e "Adding \033[33m$SKELETON\033[0m from \033[33m$REPO\033[0m to \033[33mskeleton\033[0m branch and merging to \033[33m$REPO_BRANCH\033[0m"
else
    echo -e "Updating \033[33m$SKELETON\033[0m from \033[33m$REPO\033[0m to \033[33mskeleton\033[0m branch and merging to \033[33m$REPO_BRANCH\033[0m"
fi

git clone --depth=1 $REPO $TEMP_DIR/skeleton 2>/dev/null

git switch skeleton 2>/dev/null || git switch -c skeleton 2>/dev/null

cp -r $TEMP_DIR/skeleton/$SKELETON $REPO_ROOT/ 2>/dev/null

git add -A $REPO_ROOT/$SKELETON

if [ -z "$TARGET_EXISTS" ]; then
    git commit -m "feat(skeleton): add $SKELETON from $REPO"
else
    git commit -m "feat(skeleton): update $SKELETON from $REPO"
fi

rm -fr $TEMP_DIR 2>/dev/null

git switch $REPO_BRANCH 2>/dev/null

git merge --no-ff skeleton
