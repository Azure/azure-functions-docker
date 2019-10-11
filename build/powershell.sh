#! /bin/bash
set -e

DIR=$(dirname $0)

if [ -z "$REGISTRY" ]; then
  REGISTRY=azure-functions/
fi

if [ -z "$IMAGE_TAG_VERSION" ]; then
  IMAGE_TAG_VERSION=3.0
fi

if [ -z "$DOCKERFILE_BASE" ]; then
  DOCKERFILE_BASE="3.0/buster"
fi

function test_image {
  npm run test $1 --prefix $DIR/../test
}

function build {
  # build powershell:$IMAGE_TAG_VERSION.x-powershell6 and powershell:$IMAGE_TAG_VERSION.x-powershell6-appservice
  docker build -t "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6"            -f $DIR/../host/$DOCKERFILE_BASE/amd64/powershell6.Dockerfile            $DIR/../host/$DOCKERFILE_BASE/amd64/
  docker build -t "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6-appservice" -f $DIR/../host/$DOCKERFILE_BASE/amd64/appservice/powershell6.Dockerfile $DIR/../host/$DOCKERFILE_BASE/amd64/appservice
  test_image "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6"
  test_image "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6-appservice"

  # tag default image
  docker tag "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6"            "${REGISTRY}powershell:${IMAGE_TAG_VERSION}"
  docker tag "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6-appservice" "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-appservice"

  # tag quickstart image
  docker tag "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-appservice" "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-appservice-quickstart"
}

function push {
  # push default powershell:$IMAGE_TAG_VERSION.x and powershell:$IMAGE_TAG_VERSION.x-appservice images
  docker push "${REGISTRY}powershell:${IMAGE_TAG_VERSION}"
  docker push "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-appservice"
  docker push "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-appservice-quickstart"

  # push default powershell:$IMAGE_TAG_VERSION.x-powershell6 and powershell:$IMAGE_TAG_VERSION.x-powershell6-appservice images
  docker push "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6"
  docker push "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6-appservice"
}

function purge {
  # purge default powershell:$IMAGE_TAG_VERSION.x and powershell:$IMAGE_TAG_VERSION.x-appservice images
  docker rmi "${REGISTRY}powershell:${IMAGE_TAG_VERSION}"
  docker rmi "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-appservice"
  docker rmi "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-appservice-quickstart"

  # purge default powershell:$IMAGE_TAG_VERSION.x-powershell6 and powershell:$IMAGE_TAG_VERSION.x-powershell6-appservice images
  docker rmi "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6"
  docker rmi "${REGISTRY}powershell:${IMAGE_TAG_VERSION}-powershell6-appservice"
}

function tag_push {
  # tag & push default powershell:$MAJOR_VERSION and powershell:$MAJOR_VERSION-appservice images
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}"
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}-appservice"
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}-appservice-quickstart"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}"                       "${REGISTRY}powershell:$MAJOR_VERSION"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}-appservice"            "${REGISTRY}powershell:$MAJOR_VERSION-appservice"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}-appservice-quickstart" "${REGISTRY}powershell:$MAJOR_VERSION-appservice-quickstart"
  docker push "${REGISTRY}powershell:$MAJOR_VERSION"
  docker push "${REGISTRY}powershell:$MAJOR_VERSION-appservice"
  docker push "${REGISTRY}powershell:$MAJOR_VERSION-appservice-quickstart"

  # tag & push default powershell:$MAJOR_VERSION-powershell6 and powershell:$MAJOR_VERSION-powershell6-appservice images
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}-powershell6"
  docker pull "${REGISTRY}powershell:${RELEASE_VERSION}-powershell6-appservice"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}-powershell6"            "${REGISTRY}powershell:$MAJOR_VERSION-powershell6"
  docker tag  "${REGISTRY}powershell:${RELEASE_VERSION}-powershell6-appservice" "${REGISTRY}powershell:$MAJOR_VERSION-powershell6-appservice"
  docker push "${REGISTRY}powershell:$MAJOR_VERSION-powershell6"
  docker push "${REGISTRY}powershell:$MAJOR_VERSION-powershell6-appservice"
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
  if [ -z "$MAJOR_VERSION" ]; then
    echo "ERROR: MAJOR_VERSION is required when running tag_push"
    exit 1
  fi
  tag_push
else
  echo "Unknown option $1"
  echo "Examples:"
  echo -e "\t$0 build"
  echo -e "\tBuilds all images tagged with IMAGE_TAG_VERSION and REGISTRY"
  echo ""
  echo -e "\t$0 push"
  echo -e "\tPushes all images tagged with IMAGE_TAG_VERSION and REGISTRY to REGISTRY"
  echo ""
  echo -e "\t$0 purge"
  echo -e "\tPurges images from local docker storage"
  echo ""
  echo -e "\t$0 all"
  echo -e "\tBuild, push and purge"
  echo ""
  echo -e "\t$0 tag_push"
  echo -e "\tTags \$RELEASE_VERSION images with \$MAJOR_VERSION and pushes them"
  echo ""
fi