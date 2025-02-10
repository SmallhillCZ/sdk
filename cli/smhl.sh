#!/bin/bash -e

PACKAGE_ROOT=$(realpath "$(dirname $(realpath $0))/..")
VERSION=$(jq -r '.version' $PACKAGE_ROOT/package.json)
CMD=$(basename $0)

COMMAND=$1

get_command_path() {
    if [ -f "./node_modules/.bin/$1" ]; then
        COMMAND_PATH="./node_modules/.bin/$1"
    elif [ -f "$PACKAGE_ROOT/node_modules/.bin/$1" ]; then
        COMMAND_PATH="$PACKAGE_ROOT/node_modules/.bin/$1"
    else
        COMMAND_PATH="npx --package=$2 $1"    
    fi
}

case $COMMAND in
"skeleton")
    get_command_path skeleton @smallhillcz/skeleton
    ;;
"openapi")
    get_command_path openapi-sdk @smallhillcz/openapi-sdk
    ;;
*)
    echo -e "Smallhill SDK v$VERSION"
    echo -e ""
    echo -e "Usage: \033[33m$CMD <COMMAND> <ARGS>\033[0m"
    echo -e ""
    echo -e "Command:       Info:                Repository:"
    echo -e "\033[33mskeleton\033[0m       smhl skeleton -h     https://github.com/SmallhillCZ/skeleton"
    echo -e "\033[33mopenapi\033[0m        smhl openapi -h      https://github.com/SmallhillCZ/openapi-sdk"
    echo -e ""
    echo -e "use \033[33m$CMD <COMMAND> -h\033[0m for more information on a specific command"
    exit 1
    ;;
esac

shift
$COMMAND_PATH $@