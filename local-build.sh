#bin/bash

set -e

#cp host/mvn-entrypoint.sh host/4/bullseye/amd64/java/java17

IMAGE_NAME=onobc/azure-functions-java17-build:1.0.0

docker build -t $IMAGE_NAME \
      -f host/4/bullseye/amd64/java/java17/java17-build.Dockerfile \
      host/4/bullseye/amd64/java/java17

docker push $IMAGE_NAME


IMAGE_NAME=onobc/azure-functions-java17:1.0.0

docker build -t $IMAGE_NAME \
        -f host/4/bullseye/amd64/java/java17/java17.Dockerfile \
        host/4/bullseye/amd64/java/java17

docker push $IMAGE_NAME