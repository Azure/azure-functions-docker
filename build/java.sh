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

  # build java:$IMAGE_TAG_VERSION.x-java8 and java:$IMAGE_TAG_VERSION.x-java8-appservice
  docker build -t "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8"            -f $DIR/../host/$DOCKERFILE_BASE/amd64/java8.Dockerfile            --build-arg BASE_IMAGE="${REGISTRY}base:${IMAGE_TAG_VERSION}" $DIR/../host/$DOCKERFILE_BASE/amd64/
  docker build -t "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8-appservice" -f $DIR/../host/$DOCKERFILE_BASE/amd64/appservice/java8.Dockerfile --build-arg BASE_IMAGE="${REGISTRY}base:${IMAGE_TAG_VERSION}" $DIR/../host/$DOCKERFILE_BASE/amd64/appservice
  test_image "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8"
  test_image "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8-appservice"

  # tag default java:$IMAGE_TAG_VERSION.x and java:$IMAGE_TAG_VERSION.x-appservice
  docker tag "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8"            "${REGISTRY}java:${IMAGE_TAG_VERSION}"
  docker tag "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8-appservice" "${REGISTRY}java:${IMAGE_TAG_VERSION}-appservice"

  # tag quickstart image
  docker tag "${REGISTRY}java:${IMAGE_TAG_VERSION}-appservice" "${REGISTRY}java:${IMAGE_TAG_VERSION}-appservice-quickstart"
}

function push {
  # push default java:$IMAGE_TAG_VERSION.x and java:$IMAGE_TAG_VERSION.x-appservice images
  docker push "${REGISTRY}java:${IMAGE_TAG_VERSION}"
  docker push "${REGISTRY}java:${IMAGE_TAG_VERSION}-appservice"
  docker push "${REGISTRY}java:${IMAGE_TAG_VERSION}-appservice-quickstart"

  # push default java:$IMAGE_TAG_VERSION.x-java8 and java:$IMAGE_TAG_VERSION.x-java8-appservice images
  docker push "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8"
  docker push "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8-appservice"
}

function purge {
  # purge default java:$IMAGE_TAG_VERSION.x and java:$IMAGE_TAG_VERSION.x-appservice images
  docker rmi "${REGISTRY}java:${IMAGE_TAG_VERSION}"
  docker rmi "${REGISTRY}java:${IMAGE_TAG_VERSION}-appservice"
  docker rmi "${REGISTRY}java:${IMAGE_TAG_VERSION}-appservice-quickstart"

  # purge default java:$IMAGE_TAG_VERSION.x-java8 and java:$IMAGE_TAG_VERSION.x-java8-appservice images
  docker rmi "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8"
  docker rmi "${REGISTRY}java:${IMAGE_TAG_VERSION}-java8-appservice"
}

function tag_push {
  # tag & push default java:$MAJOR_VERSION and java:$MAJOR_VERSION-appservice images
  docker pull "${REGISTRY}java:${RELEASE_VERSION}"
  docker pull "${REGISTRY}java:${RELEASE_VERSION}-appservice"
  docker pull "${REGISTRY}java:${RELEASE_VERSION}-appservice-quickstart"
  docker tag  "${REGISTRY}java:${RELEASE_VERSION}"                       "${REGISTRY}java:$MAJOR_VERSION"
  docker tag  "${REGISTRY}java:${RELEASE_VERSION}-appservice"            "${REGISTRY}java:$MAJOR_VERSION-appservice"
  docker tag  "${REGISTRY}java:${RELEASE_VERSION}-appservice-quickstart" "${REGISTRY}java:$MAJOR_VERSION-appservice-quickstart"
  docker push "${REGISTRY}java:$MAJOR_VERSION"
  docker push "${REGISTRY}java:$MAJOR_VERSION-appservice"
  docker push "${REGISTRY}java:$MAJOR_VERSION-appservice-quickstart"

  # tag & push default java:$MAJOR_VERSION-java8 and java:$MAJOR_VERSION-java8-appservice images
  docker pull "${REGISTRY}java:${RELEASE_VERSION}-java8"
  docker pull "${REGISTRY}java:${RELEASE_VERSION}-java8-appservice"
  docker tag  "${REGISTRY}java:${RELEASE_VERSION}-java8"            "${REGISTRY}java:$MAJOR_VERSION-java8"
  docker tag  "${REGISTRY}java:${RELEASE_VERSION}-java8-appservice" "${REGISTRY}java:$MAJOR_VERSION-java8-appservice"
  docker push "${REGISTRY}java:$MAJOR_VERSION-java8"
  docker push "${REGISTRY}java:$MAJOR_VERSION-java8-appservice"
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