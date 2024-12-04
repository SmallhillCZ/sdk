#!/bin/bash -e

REPO=https://github.com/smallhillcz/sdk
CMD=$(basename $0)
TEMP_DIR=$(mktemp -d)
SKELETON_DIR=$1
TARGET_DIR=$SKELETON
SKELETON_BRANCH=skeleton

# error if skeleton is not specified
if [ -z "$SKELETON_DIR" ]; then
    echo "Please specify skeleton folder"
    exit 1
fi

# if second argument is specified, use it as target
if [ ! -z "$2" ]; then
    TARGET_DIR=$2
fi

# select custom repo with -r option
while getopts ":r:hb:" opt; do
    case ${opt} in
    r)
        REPO=$OPTARG
        ;;
    b)
        SKELETON_BRANCH=$OPTARG
        ;;
    h)
        echo "Usage:"
        echo "  $CMD [options] <skeleton> [<target>]"
        echo "Options:"
        echo "  -r <repo>  Use custom repo (default: https://github.com/smallhillcz/sdk)"
        echo "  -b <branch>  Use custom branch for skeletons (default: skeleton)"
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

# issue warning when REPO_BRANCH is equal to SKELETON_BRANCH
if [ "$REPO_BRANCH" == "$SKELETON_BRANCH" ]; then
    echo -e "\033[33mError:\033[0m current branch ($REPO_BRANCH) is equal to skeleton branch ($SKELETON_BRANCH)"
    exit 1
fi

TARGET_EXISTS=0
if [ -d $REPO_ROOT/$SKELETON_DIR ]; then
    TARGET_EXISTS=1
fi

if [ -z "$TARGET_EXISTS" ]; then
    echo -e "Adding \033[33m$SKELETON_DIR\033[0m from \033[33m$REPO\033[0m to $TARGET_DIR in \033[33mskeleton\033[0m branch and merging to \033[33m$REPO_BRANCH\033[0m"
else
    echo -e "Updating \033[33m$SKELETON_DIR\033[0m from \033[33m$REPO\033[0m to $TARGET_DIR in \033[33mskeleton\033[0m branch and merging to \033[33m$REPO_BRANCH\033[0m"
fi

echo ""

git clone --quiet --depth=1 $REPO $TEMP_DIR/skeleton 1>/dev/null

if git show-ref --quiet refs/heads/$SKELETON_BRANCH; then
    git switch $SKELETON_BRANCH 1>/dev/null
else
    git switch -c $SKELETON_BRANCH 1>/dev/null
fi

cp -r $TEMP_DIR/skeleton/$SKELETON_DIR/. $REPO_ROOT/$TARGET_DIR 1>/dev/null

git add -A $REPO_ROOT/$TARGET_DIR

if [ -z "$TARGET_EXISTS" ]; then
    git commit -m "feat(skeleton): add $TARGET_DIR from $REPO#$SKELETON_DIR"
else
    git commit -m "feat(skeleton): update $TARGET_DIR from $REPO#$SKELETON_DIR"
fi

rm -fr $TEMP_DIR 1>/dev/null

git switch $REPO_BRANCH 1>/dev/null

git merge --no-ff $SKELETON_BRANCH
