#! /bin/bash
set -e

DIR=$(dirname $0)

if [ -z "$REGISTRY" ]; then
  REGISTRY=azure-functions/
fi

if [ -z "$HOST_VERSION" ]; then
  HOST_VERSION=2.0
fi

function test_image {
  npm run test $1 --prefix $DIR/../test
}

function build {
  # build base image
  docker build -t "${REGISTRY}base:${HOST_VERSION}" -f $DIR/../host/2.0/stretch/amd64/base.Dockerfile $DIR/../host/2.0/stretch/amd64/

  # build dotnet:$HOST_VERSION.x and dotnet:$HOST_VERSION.x-appservice
  docker build -t "${REGISTRY}dotnet:${HOST_VERSION}"            -f $DIR/../host/2.0/stretch/amd64/dotnet.Dockerfile            --build-arg BASE_IMAGE="${REGISTRY}base:${HOST_VERSION}"   $DIR/../host/2.0/stretch/amd64/
  docker build -t "${REGISTRY}dotnet:${HOST_VERSION}-appservice" -f $DIR/../host/2.0/stretch/amd64/appservice/dotnet.Dockerfile --build-arg BASE_IMAGE="${REGISTRY}dotnet:${HOST_VERSION}" $DIR/../host/2.0/stretch/amd64/appservice
  test_image "${REGISTRY}dotnet:${HOST_VERSION}"
  test_image "${REGISTRY}dotnet:${HOST_VERSION}-appservice"

  # tag quickstart image
  docker tag "${REGISTRY}dotnet:${HOST_VERSION}-appservice" "${REGISTRY}dotnet:${HOST_VERSION}-appservice-quickstart"
}

function push {
  # push default dotnet:$HOST_VERSION.x and dotnet:$HOST_VERSION.x-appservice images
  docker push "${REGISTRY}dotnet:${HOST_VERSION}"
  docker push "${REGISTRY}dotnet:${HOST_VERSION}-appservice"
  docker push "${REGISTRY}dotnet:${HOST_VERSION}-appservice-quickstart"
}

function purge {
  # purge default dotnet:$HOST_VERSION.x and dotnet:$HOST_VERSION.x-appservice images
  docker rmi "${REGISTRY}dotnet:${HOST_VERSION}"
  docker rmi "${REGISTRY}dotnet:${HOST_VERSION}-appservice"
  docker rmi "${REGISTRY}dotnet:${HOST_VERSION}-appservice-quickstart"
}

function tag_push {
  # push default dotnet:2.0 and dotnet:2.0-appservice images
  docker pull "${REGISTRY}dotnet:${RELEASE_VERSION}"
  docker pull "${REGISTRY}dotnet:${RELEASE_VERSION}-appservice"
  docker pull "${REGISTRY}dotnet:${RELEASE_VERSION}-appservice-quickstart"
  docker tag  "${REGISTRY}dotnet:${RELEASE_VERSION}"                       "${REGISTRY}dotnet:2.0"
  docker tag  "${REGISTRY}dotnet:${RELEASE_VERSION}-appservice"            "${REGISTRY}dotnet:2.0-appservice"
  docker tag  "${REGISTRY}dotnet:${RELEASE_VERSION}-appservice-quickstart" "${REGISTRY}dotnet:2.0-appservice-quickstart"
  docker push "${REGISTRY}dotnet:2.0"
  docker push "${REGISTRY}dotnet:2.0-appservice"
  docker push "${REGISTRY}dotnet:2.0-appservice-quickstart"
}

if [ "$1" == "build" ]; then
  build
elif [ "$1" == "push" ]; then
  push
elif [ "$1" == "purge" ]; then
  purge
elif [ "$1" == "all" ]; then
  build
  push
  purge
elif [ "$1" == "tag_push" ]; then
  if [ -z "$RELEASE_VERSION" ]; then
    echo "ERROR: RELEASE_VERSION is required when running tag_push"
    exit 1
  fi
  tag_push
else
  echo "Unknown option $1"
  echo "Examples:"
  echo -e "\t$0 build"
  echo -e "\tBuilds all images tagged with HOST_VERSION and REGISTRY"
  echo ""
  echo -e "\t$0 push"
  echo -e "\tPushes all images tagged with HOST_VERSION and REGISTRY to REGISTRY"
  echo ""
  echo -e "\t$0 purge"
  echo -e "\tPurges images from local docker storage"
  echo ""
  echo -e "\t$0 all"
  echo -e "\tBuild, push and purge"
  echo ""
  echo -e "\t$0 tag_push"
  echo -e "\tTags \$RELEASE_VERSION images with 2.0 and pushes them"
  echo ""
fi