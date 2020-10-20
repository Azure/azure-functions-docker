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
destination_image="$ACR/$ACR_NAMESPACE/kudulite:$tag"

echo -e "${CONSOLE_BOLD}${COLOR_YELLOW} Pushing $destination_image ${CONSOLE_RESET}"
docker pull "$temporary_image"
docker tag "$temporary_image" "$destination_image"
docker push "$destination_image"

if ! [ -z "$CI_RUN" ]; then
    echo -e "${CONSOLE_BOLD}${COLOR_GREEN} Cleaning up... ${CONSOLE_RESET}"
    docker system prune -f
fi
