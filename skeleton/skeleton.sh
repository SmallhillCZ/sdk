#!/bin/bash -e

REPO=https://github.com/smallhillcz/sdk
CMD=$(basename $0)
TEMP_DIR=$(mktemp -d)
# TEMP_DIR=/workspaces/tmp
SKELETON_DIR=$1
TARGET_DIR=$SKELETON
SKELETON_BRANCH=skeleton
WORKDIR=$(pwd)

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
UNTRACKED_DIR=$REPO_ROOT/.untracked

cd $REPO_ROOT

# issue warning when REPO_BRANCH is equal to SKELETON_BRANCH
if [ "$REPO_BRANCH" == "$SKELETON_BRANCH" ]; then
    echo -e "\033[33mWarning:\033[0m current branch ($REPO_BRANCH) is equal to skeleton branch ($SKELETON_BRANCH)"
    exit 0
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

# create a list of all files in the repository which are not tracked by git
UNTRACKED_FILES=$(git status --porcelain | grep '^??' | cut -c4-)

# move untracked files out of the way
mkdir -p $TEMP_DIR/untracked
for file in $UNTRACKED_FILES; do
    mkdir -p $(dirname "$UNTRACKED_DIR/$file")
    mv "$REPO_ROOT/$file" "$UNTRACKED_DIR/$file"
done

# remove target directory and copy new skeleton
rm -fr $REPO_ROOT/$TARGET_DIR 1>/dev/null
cp -r $TEMP_DIR/skeleton/$SKELETON_DIR/. $REPO_ROOT/$TARGET_DIR 1>/dev/null

git add -A $REPO_ROOT/$TARGET_DIR

# return untracked files back
for file in $UNTRACKED_FILES; do
    mkdir -p $(dirname "$REPO_ROOT/$file")
    mv "$UNTRACKED_DIR/$file" "$REPO_ROOT/$file"
done
rm -fr $UNTRACKED_DIR 1>/dev/null

# if no staged files, exit
if [ -z "$(git diff --cached --exit-code)" ]; then
    echo "No changes"
    rm -fr $TEMP_DIR 1>/dev/null
    git switch $REPO_BRANCH 1>/dev/null
    exit 0
fi

# merge changes to original branch
if [ -z "$TARGET_EXISTS" ]; then
    git commit -m "feat(skeleton): add $TARGET_DIR from $REPO#$SKELETON_DIR"
else
    git commit -m "feat(skeleton): update $TARGET_DIR from $REPO#$SKELETON_DIR"
fi

# cleanup
rm -fr $TEMP_DIR 1>/dev/null

git switch $REPO_BRANCH 1>/dev/null

git merge --no-ff $SKELETON_BRANCH
