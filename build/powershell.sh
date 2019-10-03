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
  # build powershell:$HOST_VERSION.x-powershell6 and powershell:$HOST_VERSION.x-powershell6-appservice
  docker build -t "${REGISTRY}powershell:${HOST_VERSION}-powershell6"            -f $DIR/../host/2.0/stretch/amd64/powershell6.Dockerfile            $DIR/../host/2.0/stretch/amd64/
  docker build -t "${REGISTRY}powershell:${HOST_VERSION}-powershell6-appservice" -f $DIR/../host/2.0/stretch/amd64/appservice/powershell6.Dockerfile $DIR/../host/2.0/stretch/amd64/appservice
  test_image "${REGISTRY}powershell:${HOST_VERSION}-powershell6"
  test_image "${REGISTRY}powershell:${HOST_VERSION}-powershell6-appservice"

  # tag default image
  docker tag "${REGISTRY}powershell:${HOST_VERSION}-powershell6"            "${REGISTRY}powershell:${HOST_VERSION}"
  docker tag "${REGISTRY}powershell:${HOST_VERSION}-powershell6-appservice" "${REGISTRY}powershell:${HOST_VERSION}-appservice"

  # tag quickstart image
  docker tag "${REGISTRY}powershell:${HOST_VERSION}-appservice" "${REGISTRY}powershell:${HOST_VERSION}-appservice-quickstart"
}

function push {
  # push default powershell:$HOST_VERSION.x and powershell:$HOST_VERSION.x-appservice images
  docker push "${REGISTRY}powershell:${HOST_VERSION}"
  docker push "${REGISTRY}powershell:${HOST_VERSION}-appservice"
  docker push "${REGISTRY}powershell:${HOST_VERSION}-appservice-quickstart"

  # push default powershell:$HOST_VERSION.x-powershell6 and powershell:$HOST_VERSION.x-powershell6-appservice images
  docker push "${REGISTRY}powershell:${HOST_VERSION}-powershell6"
  docker push "${REGISTRY}powershell:${HOST_VERSION}-powershell6-appservice"
}

function purge {
  # purge default powershell:$HOST_VERSION.x and powershell:$HOST_VERSION.x-appservice images
  docker rmi "${REGISTRY}powershell:${HOST_VERSION}"
  docker rmi "${REGISTRY}powershell:${HOST_VERSION}-appservice"
  docker rmi "${REGISTRY}powershell:${HOST_VERSION}-appservice-quickstart"

  # purge default powershell:$HOST_VERSION.x-powershell6 and powershell:$HOST_VERSION.x-powershell6-appservice images
  docker rmi "${REGISTRY}powershell:${HOST_VERSION}-powershell6"
  docker rmi "${REGISTRY}powershell:${HOST_VERSION}-powershell6-appservice"
}

function tag_push {
  # tag & push default powershell:2.0 and powershell:2.0-appservice images
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}"
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}-appservice"
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}-appservice-quickstart"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}"                       "${REGISTRY}powershell:2.0"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}-appservice"            "${REGISTRY}powershell:2.0-appservice"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}-appservice-quickstart" "${REGISTRY}powershell:2.0-appservice-quickstart"
  docker push "${REGISTRY}powershell:2.0"
  docker push "${REGISTRY}powershell:2.0-appservice"
  docker push "${REGISTRY}powershell:2.0-appservice-quickstart"

  # tag & push default powershell:2.0-powershell6 and powershell:2.0-powershell6-appservice images
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}-powershell6"
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}-powershell6-appservice"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}-powershell6"            "${REGISTRY}powershell:2.0-powershell6"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}-powershell6-appservice" "${REGISTRY}powershell:2.0-powershell6-appservice"
  docker push "${REGISTRY}powershell:2.0-powershell6"
  docker push "${REGISTRY}powershell:2.0-powershell6-appservice"
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