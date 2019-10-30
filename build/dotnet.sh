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
  # build base image
  docker build -t "${REGISTRY}base:${IMAGE_TAG_VERSION}" -f $DIR/../host/$DOCKERFILE_BASE/amd64/base.Dockerfile $DIR/../host/$DOCKERFILE_BASE/amd64/

  # build dotnet:$IMAGE_TAG_VERSION.x and dotnet:$IMAGE_TAG_VERSION.x-appservice
  docker build -t "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}"            -f $DIR/../host/$DOCKERFILE_BASE/amd64/dotnet.Dockerfile            --build-arg BASE_IMAGE="${REGISTRY}base:${IMAGE_TAG_VERSION}"   $DIR/../host/$DOCKERFILE_BASE/amd64/
  docker build -t "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}-appservice" -f $DIR/../host/$DOCKERFILE_BASE/amd64/appservice/dotnet.Dockerfile --build-arg BASE_IMAGE="${REGISTRY}dotnet:${IMAGE_TAG_VERSION}" $DIR/../host/$DOCKERFILE_BASE/amd64/appservice
  test_image "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}"
  test_image "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}-appservice"

  # tag quickstart image
  docker tag "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}-appservice" "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}-appservice-quickstart"
}

function push {
  # push default dotnet:$IMAGE_TAG_VERSION.x and dotnet:$IMAGE_TAG_VERSION.x-appservice images
  docker push "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}"
  docker push "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}-appservice"
  docker push "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}-appservice-quickstart"
}

function purge {
  # purge default dotnet:$IMAGE_TAG_VERSION.x and dotnet:$IMAGE_TAG_VERSION.x-appservice images
  docker rmi "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}"
  docker rmi "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}-appservice"
  docker rmi "${REGISTRY}dotnet:${IMAGE_TAG_VERSION}-appservice-quickstart"
}

function tag_push {
  # push default dotnet:$MAJOR_VERSION and dotnet:$MAJOR_VERSION-appservice images
  DOTNET_MAJOR_VERSION=${MAJOR_VERSION%%.*}
  docker pull "${REGISTRY}dotnet:${RELEASE_VERSION}"
  docker pull "${REGISTRY}dotnet:${RELEASE_VERSION}-appservice"
  docker pull "${REGISTRY}dotnet:${RELEASE_VERSION}-appservice-quickstart"
  docker tag  "${REGISTRY}dotnet:${RELEASE_VERSION}"                       "${REGISTRY}dotnet:$MAJOR_VERSION"
  docker tag  "${REGISTRY}dotnet:${RELEASE_VERSION}-appservice"            "${REGISTRY}dotnet:$MAJOR_VERSION-appservice"
  docker tag  "${REGISTRY}dotnet:${RELEASE_VERSION}-appservice-quickstart" "${REGISTRY}dotnet:$MAJOR_VERSION-appservice-quickstart"
  docker push "${REGISTRY}dotnet:$MAJOR_VERSION"
  docker push "${REGISTRY}dotnet:$MAJOR_VERSION-appservice"
  docker push "${REGISTRY}dotnet:$MAJOR_VERSION-dotnet${DOTNET_MAJOR_VERSION}-appservice"
  docker push "${REGISTRY}dotnet:$MAJOR_VERSION-appservice-quickstart"
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
  echo -e "\tBuilds all images tagged with \$IMAGE_TAG_VERSION and \$REGISTRY"
  echo ""
  echo -e "\t$0 push"
  echo -e "\tPushes all images tagged with \$IMAGE_TAG_VERSION and \$REGISTRY to \$REGISTRY"
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