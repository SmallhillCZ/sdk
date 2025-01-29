#!/bin/bash -e

PACKAGE_ROOT=$(realpath "$(dirname $(realpath $0))/..")
VERSION=$(jq -r '.version' $PACKAGE_ROOT/package.json)
GENERATOR_BIN=$PACKAGE_ROOT/node_modules/.bin/openapi-generator-cli

display_help() {
    echo -e "\033[33mSmallhill OpenAPI SDK v$VERSION\033[0m"
    echo -e "OpenAPI SDK generator for typescript+axios using @openapitools/openapi-generator-cli with custom templates"
    echo -e "https://github.com/SmallhillCZ/openapi-sdk"
    echo -e ""
    echo -e "Usage:"
    echo -e "  \033[33mopenapi-sdk [-h]\033[0m      displays this help"
    echo -e "  \033[33mopenapi-sdk <options>\033[0m generates SDK"
    echo -e ""
    echo -e "Options:"
    echo -e "  -i, --input-spec <file>  OpenAPI spec file"
    echo -e "  -o, --output <dir>       Output directory"
    echo -e ""
    echo -e "  for other options see https://openapi-generator.tech/docs/usage/#generate"
}

# display help on -h
if [ "$1" == "-h" ]; then
    display_help
    exit 0
fi

if [ -z "$1" ]; then
    echo -e "\033[31mError: Generator options not specified\033[0m"
    echo -e ""
    display_help
    exit 1
fi

$GENERATOR_BIN generate \
    -g typescript-axios \
    -t $PACKAGE_ROOT/templates \
    $@
