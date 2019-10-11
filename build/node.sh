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

  # build node:$IMAGE_TAG_VERSION.x-node8 and node:$IMAGE_TAG_VERSION.x-node8-appservice
  docker build -t "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8"            -f $DIR/../host/$DOCKERFILE_BASE/amd64/node8.Dockerfile            --build-arg BASE_IMAGE="${REGISTRY}base:${IMAGE_TAG_VERSION}"       $DIR/../host/$DOCKERFILE_BASE/amd64/
  docker build -t "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8-appservice" -f $DIR/../host/$DOCKERFILE_BASE/amd64/appservice/node8.Dockerfile --build-arg BASE_IMAGE="${REGISTRY}node:${IMAGE_TAG_VERSION}-node8" $DIR/../host/$DOCKERFILE_BASE/amd64/appservice
  test_image "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8"
  test_image "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8-appservice"

  # build node:$IMAGE_TAG_VERSION.x-node10 and node:$IMAGE_TAG_VERSION.x-node10-appservice
  docker build -t "${REGISTRY}node:${IMAGE_TAG_VERSION}-node10"            -f $DIR/../host/$DOCKERFILE_BASE/amd64/node10.Dockerfile            --build-arg BASE_IMAGE="${REGISTRY}base:${IMAGE_TAG_VERSION}"        $DIR/../host/$DOCKERFILE_BASE/amd64/
  docker build -t "${REGISTRY}node:${IMAGE_TAG_VERSION}-node10-appservice" -f $DIR/../host/$DOCKERFILE_BASE/amd64/appservice/node10.Dockerfile --build-arg BASE_IMAGE="${REGISTRY}node:${IMAGE_TAG_VERSION}-node10" $DIR/../host/$DOCKERFILE_BASE/amd64/appservice
  test_image "${REGISTRY}node:${IMAGE_TAG_VERSION}-node10"
  test_image "${REGISTRY}node:${IMAGE_TAG_VERSION}-node10-appservice"

  # build node:$IMAGE_TAG_VERSION.x-node12 and node:$IMAGE_TAG_VERSION.x-node12-appservice
  docker build -t "${REGISTRY}node:${IMAGE_TAG_VERSION}-node12"            -f $DIR/../host/$DOCKERFILE_BASE/amd64/node8.Dockerfile            --build-arg BASE_IMAGE="${REGISTRY}base:${IMAGE_TAG_VERSION}"        $DIR/../host/$DOCKERFILE_BASE/amd64/
  docker build -t "${REGISTRY}node:${IMAGE_TAG_VERSION}-node12-appservice" -f $DIR/../host/$DOCKERFILE_BASE/amd64/appservice/node8.Dockerfile --build-arg BASE_IMAGE="${REGISTRY}node:${IMAGE_TAG_VERSION}-node12" $DIR/../host/$DOCKERFILE_BASE/amd64/appservice
  test_image "${REGISTRY}node:${IMAGE_TAG_VERSION}-node12"
  test_image "${REGISTRY}node:${IMAGE_TAG_VERSION}-node12-appservice"

  # tag default node:$IMAGE_TAG_VERSION.x and node:$IMAGE_TAG_VERSION.x-appservice
  docker tag "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8"            "${REGISTRY}node:${IMAGE_TAG_VERSION}"
  docker tag "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8-appservice" "${REGISTRY}node:${IMAGE_TAG_VERSION}-appservice"

  # tag quickstart image
  docker tag "${REGISTRY}node:${IMAGE_TAG_VERSION}-appservice" "${REGISTRY}node:${IMAGE_TAG_VERSION}-appservice-quickstart"
}

function push {
  # push default node:$IMAGE_TAG_VERSION.x and node:$IMAGE_TAG_VERSION.x-appservice images
  docker push "${REGISTRY}node:${IMAGE_TAG_VERSION}"
  docker push "${REGISTRY}node:${IMAGE_TAG_VERSION}-appservice"
  docker push "${REGISTRY}node:${IMAGE_TAG_VERSION}-appservice-quickstart"

  # push default node:$IMAGE_TAG_VERSION.x-node8 and node:$IMAGE_TAG_VERSION.x-node8-appservice images
  docker push "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8"
  docker push "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8-appservice"

  # push default node:$IMAGE_TAG_VERSION.x-node10 and node:$IMAGE_TAG_VERSION.x-node10-appservice images
  docker push "${REGISTRY}node:${IMAGE_TAG_VERSION}-node10"
  docker push "${REGISTRY}node:${IMAGE_TAG_VERSION}-node10-appservice"

  # push default node:$IMAGE_TAG_VERSION.x-node12 and node:$IMAGE_TAG_VERSION.x-node12-appservice images
  docker push "${REGISTRY}node:${IMAGE_TAG_VERSION}-node12"
  docker push "${REGISTRY}node:${IMAGE_TAG_VERSION}-node12-appservice"
}

function purge {
  # purge default node:$IMAGE_TAG_VERSION.x and node:$IMAGE_TAG_VERSION.x-appservice images
  docker rmi "${REGISTRY}node:${IMAGE_TAG_VERSION}"
  docker rmi "${REGISTRY}node:${IMAGE_TAG_VERSION}-appservice"
  docker rmi "${REGISTRY}node:${IMAGE_TAG_VERSION}-appservice-quickstart"

  # purge default node:$IMAGE_TAG_VERSION.x-node8 and node:$IMAGE_TAG_VERSION.x-node8-appservice images
  docker rmi "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8"
  docker rmi "${REGISTRY}node:${IMAGE_TAG_VERSION}-node8-appservice"

  # purge default node:$IMAGE_TAG_VERSION.x-node10 and node:$IMAGE_TAG_VERSION.x-node10-appservice images
  docker rmi "${REGISTRY}node:${IMAGE_TAG_VERSION}-node10"
  docker rmi "${REGISTRY}node:${IMAGE_TAG_VERSION}-node10-appservice"

  # purge default node:$IMAGE_TAG_VERSION.x-node12 and node:$IMAGE_TAG_VERSION.x-node12-appservice images
  docker rmi "${REGISTRY}node:${IMAGE_TAG_VERSION}-node12"
  docker rmi "${REGISTRY}node:${IMAGE_TAG_VERSION}-node12-appservice"
}

function tag_push {
  # tag & push default node:$MAJOR_VERSION, node:$MAJOR_VERSION-appservice, and node:$MAJOR_VERSION-appservice-quickstart images
  docker pull "${REGISTRY}node:${RELEASE_VERSION}"
  docker pull "${REGISTRY}node:${RELEASE_VERSION}-appservice"
  docker pull "${REGISTRY}node:${RELEASE_VERSION}-appservice-quickstart"
  docker tag  "${REGISTRY}node:${RELEASE_VERSION}"                       "${REGISTRY}node:$MAJOR_VERSION"
  docker tag  "${REGISTRY}node:${RELEASE_VERSION}-appservice"            "${REGISTRY}node:$MAJOR_VERSION-appservice"
  docker tag  "${REGISTRY}node:${RELEASE_VERSION}-appservice-quickstart" "${REGISTRY}node:$MAJOR_VERSION-appservice-quickstart"
  docker push "${REGISTRY}node:$MAJOR_VERSION"
  docker push "${REGISTRY}node:$MAJOR_VERSION-appservice"
  docker push "${REGISTRY}node:$MAJOR_VERSION-appservice-quickstart"

  # tag & push default node:$MAJOR_VERSION-node8 and node:$MAJOR_VERSION-node8-appservice images
  docker pull "${REGISTRY}node:${RELEASE_VERSION}-node8"
  docker pull "${REGISTRY}node:${RELEASE_VERSION}-node8-appservice"
  docker tag  "${REGISTRY}node:${RELEASE_VERSION}-node8"            "${REGISTRY}node:$MAJOR_VERSION-node8"
  docker tag  "${REGISTRY}node:${RELEASE_VERSION}-node8-appservice" "${REGISTRY}node:$MAJOR_VERSION-node8-appservice"
  docker push "${REGISTRY}node:$MAJOR_VERSION-node8"
  docker push "${REGISTRY}node:$MAJOR_VERSION-node8-appservice"

  # tag & push default node:$MAJOR_VERSION-node10 and node:$MAJOR_VERSION-node10-appservice images
  docker pull "${REGISTRY}node:${RELEASE_VERSION}-node10"
  docker pull "${REGISTRY}node:${RELEASE_VERSION}-node10-appservice"
  docker tag  "${REGISTRY}node:${RELEASE_VERSION}-node10"            "${REGISTRY}node:$MAJOR_VERSION-node10"
  docker tag  "${REGISTRY}node:${RELEASE_VERSION}-node10-appservice" "${REGISTRY}node:$MAJOR_VERSION-node10-appservice"
  docker push "${REGISTRY}node:$MAJOR_VERSION-node10"
  docker push "${REGISTRY}node:$MAJOR_VERSION-node10-appservice"

  # tag & push default node:$MAJOR_VERSION-node12 and node:$MAJOR_VERSION-node12-appservice images
  docker pull "${REGISTRY}node:${RELEASE_VERSION}-node12"
  docker pull "${REGISTRY}node:${RELEASE_VERSION}-node12-appservice"
  docker tag  "${REGISTRY}node:${RELEASE_VERSION}-node12"            "${REGISTRY}node:$MAJOR_VERSION-node12"
  docker tag  "${REGISTRY}node:${RELEASE_VERSION}-node12-appservice" "${REGISTRY}node:$MAJOR_VERSION-node12-appservice"
  docker push "${REGISTRY}node:$MAJOR_VERSION-node12"
  docker push "${REGISTRY}node:$MAJOR_VERSION-node12-appservice"
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