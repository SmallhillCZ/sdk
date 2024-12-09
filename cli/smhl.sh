#!/bin/bash -e

PACKAGE_ROOT=$(realpath "$(dirname $(realpath $0))/..")
VERSION=$(jq -r '.version' $PACKAGE_ROOT/package.json)
CMD=$(basename $0)

COMMAND=$1

case $COMMAND in
"skeleton")
    shift
    $PACKAGE_ROOT/skeleton/cli/skeleton.sh $@
    ;;
*)
    echo -e "Smallhill SDK v$VERSION"
    echo -e ""
    echo -e "Usage: \033[33m$CMD <COMMAND> <ARGS>\033[0m"
    echo -e ""
    echo -e "Commands:"
    echo -e "  skeleton - generate project files from skeleton repository"
    echo -e ""
    echo -e "use \033[33m$CMD <COMMAND> -h\033[0m for more information on a specific command"
    exit 1
    ;;
esac
