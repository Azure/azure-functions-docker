#! /bin/bash

set -e

DIR=$(dirname $0)
ESC_SEQ="\033["
CONSOLE_RESET=$ESC_SEQ"39;49;00m"
COLOR_RED=$ESC_SEQ"31;01m"
COLOR_GREEN=$ESC_SEQ"32;01m"
COLOR_YELLOW=$ESC_SEQ"33;01m"
COLOR_CYAN=$ESC_SEQ"36;01m"
CONSOLE_BOLD=$ESC_SEQ"1m"

# Building stretch
ACR=azurefunctions.azurecr.io
ACR_NAMESPACE=public/azure-functions

if [ -z "$tag" ]; then
    tag=dev
fi

base_dir=$DIR

temporary_image="$ACR/$ACR_NAMESPACE/kudulite:$tag-prerelease"

echo -e "${CONSOLE_BOLD}${COLOR_YELLOW} Testing $temporary_image ${CONSOLE_RESET}"
export STORAGE_ACCOUNT_NAME="$storageAccountName"
export STORAGE_ACCOUNT_KEY="$storageAccountKey"
export V2_RUNTIME_VERSION="$v2RuntimeVersion"
export V3_RUNTIME_VERSION="$v3RuntimeVersion"
export TEST_RUNTIME_IMAGE="$testRuntimeImage"
npm run test-kudulite $temporary_image --prefix test/

echo -e "${CONSOLE_BOLD}${COLOR_GREEN} Test PASSED. $temporary_image ${CONSOLE_RESET}"