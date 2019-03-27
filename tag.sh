#! /bin/bash

set -e

ACR=azurefunctions.azurecr.io
ACR_NAMESPACE=public/azure-functions

function pull_tag_push {
    local image_to_pull=$1
    local new_image_name=$2

    docker pull $image_to_pull
    docker tag $image_to_pull $new_image_name
    docker push $new_image_name
}

images=( base dotnet node python powershell )
for i in "${images[@]}"
do
    current_image=$ACR/$ACR_NAMESPACE/$i:$ReleaseVersion
    current_base=$ACR/$ACR_NAMESPACE/$i

    pull_tag_push $current_image $current_base:2.0
    pull_tag_push $current_image $current_base:latest
    pull_tag_push $current_image $current_base:2.0-iot-edge

    if [ "$i" != "base" ]; then
        pull_tag_push $current_image-appservice $current_base:2.0-appservice
    fi

    if [ "$i" == "python" ]; then
        pull_tag_push $current_image $current_base:2.0-python3.6
        pull_tag_push $current_image-appservice $current_base:2.0-python3.6-appservice
    elif [ "$i" == "node" ]; then
        pull_tag_push $current_image $current_base:2.0-node8
        pull_tag_push $current_image-appservice $current_base:2.0-node8-appservice
    elif [ "$i" == "powershell" ]; then
        pull_tag_push $current_image $current_base:2.0-pwsh6
        pull_tag_push $current_image-appservice $current_base:2.0-pwsh6-appservice
    fi
done

images=( dotnet powershell java )
for i in "${images[@]}"
do
    current_image=$ACR/$ACR_NAMESPACE/$i:$ReleaseVersion-alpine
    current_base=$ACR/$ACR_NAMESPACE/$i

    pull_tag_push $current_image $current_base:2.0-alpine

    if [ "$i" == "powershell" ]; then
        pull_tag_push $current_image $current_base:2.0-pwsh6
    fi
done