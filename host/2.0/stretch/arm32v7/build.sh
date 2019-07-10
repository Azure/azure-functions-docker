#! /bin/bash
set -e

HostCommit=dev
BuildNumber=2.0.12562

images=( base node python powershell )
for i in "${images[@]}"
do
    imageName="azurefunctions.azurecr.io/public/azure-functions/$i:2.0-arm32v7"
    base=base
    pull=""

    if [ "$i" = "base" ]; then
        echo "base image, add --pull"
        pull="--pull"
    fi

    echo "Building $imageName"

    docker build --no-cache $pull -t $imageName \
    --build-arg HOST_COMMIT=$HostCommit \
    --build-arg BASE_IMAGE=azurefunctions.azurecr.io/public/azure-functions/$base \
    --build-arg BUILD_NUMBER=$BuildNumber \
    --build-arg BASE_IMAGE_TAG=2.0-arm32v7 \
    -f $i.Dockerfile \
    .
done

docker tag \
    azurefunctions.azurecr.io/public/azure-functions/base:2.0-arm32v7 \
    azurefunctions.azurecr.io/public/azure-functions/dotnet:2.0-arm32v7
