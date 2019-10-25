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

if [ -z "$namespace" ]; then
    namespace="Azure-App-Service"
fi

if [ -z "$branch" ]; then
    branch=master
fi

if [ -z "$tag" ]; then
    tag=dev
fi

base_dir=$DIR

current_image="$ACR/$ACR_NAMESPACE/kudulite:$tag"
echo -e "${CONSOLE_BOLD}${COLOR_GREEN}: Building $current_image ${CONSOLE_RESET}"
echo -e "${CONSOLE_BOLD}${COLOR_YELLOW}: Source Image $namespace/KuduLite $branch ${CONSOLE_RESET}"
echo -e "${CONSOLE_BOLD}${COLOR_YELLOW}: Destination Image $current_image ${CONSOLE_RESET}"
docker build --build-arg BRANCH="$branch" --build-arg NAMESPACE="$namespace" -t $current_image -f "$base_dir/Dockerfile" "$base_dir"
docker push "$current_image"

if ! [ -z "$CI_RUN" ]; then
    docker system prune -f -a
fi
