#! /bin/bash

set -e

ACR=azurefunctions.azurecr.io
ACR_NAMESPACE=public/azure-functions

if [ -z "$tag" ]; then
    tag=dev
fi

function pull_tag_push {
    local image_to_pull=$1
    local new_image_name=$2

    docker pull $image_to_pull
    docker tag $image_to_pull $new_image_name
    docker push $new_image_name
}

current_base=$ACR/$ACR_NAMESPACE/kudulite
current_image=$ACR/$ACR_NAMESPACE/kudulite:$ReleaseVersion

pull_tag_push $current_base:$tag $current_image
pull_tag_push $current_base:$tag $current_base:latest