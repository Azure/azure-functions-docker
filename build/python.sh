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

  # build python:$IMAGE_TAG_VERSION.x-python3.6 and python:$IMAGE_TAG_VERSION.x-python3.6-appservice
  docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-deps"       -f $DIR/../host/$DOCKERFILE_BASE/amd64/python/python36-deps.Dockerfile $DIR/../host/$DOCKERFILE_BASE/amd64/python
  docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-buildenv"   -f $DIR/../host/$DOCKERFILE_BASE/amd64/python/python36-buildenv.Dockerfile --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-deps"                                                          $DIR/../host/$DOCKERFILE_BASE/amd64/python
  docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6"            -f $DIR/../host/$DOCKERFILE_BASE/amd64/python/python36.Dockerfile          --build-arg BASE_IMAGE="${REGISTRY}base:${IMAGE_TAG_VERSION}" --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-deps" $DIR/../host/$DOCKERFILE_BASE/amd64/python
  docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-appservice" -f $DIR/../host/$DOCKERFILE_BASE/amd64/appservice/python36.Dockerfile      --build-arg BASE_IMAGE="${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6"                                                                      $DIR/../host/$DOCKERFILE_BASE/amd64/appservice
  test_image "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6"
  test_image "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-appservice"

  # build python:$IMAGE_TAG_VERSION.x-python3.7 and python:$IMAGE_TAG_VERSION.x-python3.7-appservice
  docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-deps"       -f $DIR/../host/$DOCKERFILE_BASE/amd64/python/python37-deps.Dockerfile $DIR/../host/$DOCKERFILE_BASE/amd64/python
  docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-buildenv"   -f $DIR/../host/$DOCKERFILE_BASE/amd64/python/python37-buildenv.Dockerfile --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-deps"                                                          $DIR/../host/$DOCKERFILE_BASE/amd64/python
  docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7"            -f $DIR/../host/$DOCKERFILE_BASE/amd64/python/python37.Dockerfile          --build-arg BASE_IMAGE="${REGISTRY}base:${IMAGE_TAG_VERSION}" --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-deps" $DIR/../host/$DOCKERFILE_BASE/amd64/python
  docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-appservice" -f $DIR/../host/$DOCKERFILE_BASE/amd64/appservice/python37.Dockerfile      --build-arg BASE_IMAGE="${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7"                                                                      $DIR/../host/$DOCKERFILE_BASE/amd64/appservice
  test_image "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7"
  test_image "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-appservice"

  # build python:$IMAGE_TAG_VERSION.x-python3.8 and python:$IMAGE_TAG_VERSION.x-python3.8-appservice
  if [ "$DOCKERFILE_BASE" != "2.0/stretch" ]; then
    docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-deps"       -f $DIR/../host/$DOCKERFILE_BASE/amd64/python/python38-deps.Dockerfile $DIR/../host/$DOCKERFILE_BASE/amd64/python
    docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-buildenv"   -f $DIR/../host/$DOCKERFILE_BASE/amd64/python/python38-buildenv.Dockerfile --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-deps"                                                          $DIR/../host/$DOCKERFILE_BASE/amd64/python
    docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8"            -f $DIR/../host/$DOCKERFILE_BASE/amd64/python/python38.Dockerfile          --build-arg BASE_IMAGE="${REGISTRY}base:${IMAGE_TAG_VERSION}" --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-deps" $DIR/../host/$DOCKERFILE_BASE/amd64/python
    docker build -t "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-appservice" -f $DIR/../host/$DOCKERFILE_BASE/amd64/appservice/python38.Dockerfile      --build-arg BASE_IMAGE="${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8"                                                                      $DIR/../host/$DOCKERFILE_BASE/amd64/appservice
    test_image "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8"
    test_image "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-appservice"
  fi

  # tag default python:$IMAGE_TAG_VERSION.x and python:$IMAGE_TAG_VERSION.x-appservice
  docker tag "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6" "${REGISTRY}python:${IMAGE_TAG_VERSION}"
  docker tag "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-appservice" "${REGISTRY}python:${IMAGE_TAG_VERSION}-appservice"

  # tag quickstart image
  docker tag "${REGISTRY}python:${IMAGE_TAG_VERSION}-appservice" "${REGISTRY}python:${IMAGE_TAG_VERSION}-appservice-quickstart"
}

function push {
  # push build-env images
  docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-buildenv"
  docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-buildenv"
  if [ "$DOCKERFILE_BASE" != "2.0/stretch" ]; then
    docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-buildenv"
  fi

  # push default python:$IMAGE_TAG_VERSION.x and python:$IMAGE_TAG_VERSION.x-appservice images
  docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}"
  docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-appservice"
  docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-appservice-quickstart"

  # push default python:$IMAGE_TAG_VERSION.x-python3.6 and python:$IMAGE_TAG_VERSION.x-python3.6-appservice images
  docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6"
  docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-appservice"

  # push default python:$IMAGE_TAG_VERSION.x-python3.7 and python:$IMAGE_TAG_VERSION.x-python3.7-appservice images
  docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7"
  docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-appservice"

  # push default python:$IMAGE_TAG_VERSION.x-python3.8 and python:$IMAGE_TAG_VERSION.x-python3.8-appservice images
  if [ "$DOCKERFILE_BASE" != "2.0/stretch" ]; then
    docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8"
    docker push "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-appservice"
  fi
}

function purge {
  # purge deps image
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-deps"
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-deps"
  if [ "$DOCKERFILE_BASE" != "2.0/stretch" ]; then
    docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-deps"
  fi

  # purge build-env images
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-buildenv"
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-buildenv"
  if [ "$DOCKERFILE_BASE" != "2.0/stretch" ]; then
    docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-buildenv"
  fi

  # purge default python:$IMAGE_TAG_VERSION.x and python:$IMAGE_TAG_VERSION.x-appservice images
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}"
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-appservice"
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-appservice-quickstart"

  # purge default python:$IMAGE_TAG_VERSION.x-python3.6 and python:$IMAGE_TAG_VERSION.x-python3.6-appservice images
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6"
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.6-appservice"

  # purge default python:$IMAGE_TAG_VERSION.x-python3.7 and python:$IMAGE_TAG_VERSION.x-python3.7-appservice images
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7"
  docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.7-appservice"

  # purge default python:$IMAGE_TAG_VERSION.x-python3.8 and python:$IMAGE_TAG_VERSION.x-python3.8-appservice images
  if [ "$DOCKERFILE_BASE" != "2.0/stretch" ]; then
    docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8"
    docker rmi "${REGISTRY}python:${IMAGE_TAG_VERSION}-python3.8-appservice"
  fi
}

function tag_push {
  # tag & push build-env images
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.6-buildenv"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.6-buildenv" "${REGISTRY}python:$MAJOR_VERSION-python3.6-buildenv"
  docker push "${REGISTRY}python:$MAJOR_VERSION-python3.6-buildenv"

  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.7-buildenv"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.7-buildenv" "${REGISTRY}python:$MAJOR_VERSION-python3.7-buildenv"
  docker push "${REGISTRY}python:$MAJOR_VERSION-python3.7-buildenv"

  if [ "$MAJOR_VERSION" != "2.0" ]; then
    docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.8-buildenv"
    docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.8-buildenv" "${REGISTRY}python:$MAJOR_VERSION-python3.8-buildenv"
    docker push "${REGISTRY}python:$MAJOR_VERSION-python3.8-buildenv"
  fi

  # tag & push default python:$MAJOR_VERSION and python:$MAJOR_VERSION-appservice images
  docker pull "${REGISTRY}python:${RELEASE_VERSION}"
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-appservice"
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-appservice-quickstart"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}"                       "${REGISTRY}python:$MAJOR_VERSION"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-appservice"            "${REGISTRY}python:$MAJOR_VERSION-appservice"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-appservice-quickstart" "${REGISTRY}python:$MAJOR_VERSION-appservice-quickstart"
  docker push "${REGISTRY}python:$MAJOR_VERSION"
  docker push "${REGISTRY}python:$MAJOR_VERSION-appservice"
  docker push "${REGISTRY}python:$MAJOR_VERSION-appservice-quickstart"

  # tag & push default python:$MAJOR_VERSION-python3.6 and python:$MAJOR_VERSION-python3.6-appservice images
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.6"
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.6-appservice"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.6"            "${REGISTRY}python:$MAJOR_VERSION-python3.6"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.6-appservice" "${REGISTRY}python:$MAJOR_VERSION-python3.6-appservice"
  docker push "${REGISTRY}python:$MAJOR_VERSION-python3.6"
  docker push "${REGISTRY}python:$MAJOR_VERSION-python3.6-appservice"

  # tag & push default python:$MAJOR_VERSION-python3.7 and python:$MAJOR_VERSION-python3.7-appservice images
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.7"
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.7-appservice"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.7"            "${REGISTRY}python:$MAJOR_VERSION-python3.7"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.7-appservice" "${REGISTRY}python:$MAJOR_VERSION-python3.7-appservice"
  docker push "${REGISTRY}python:$MAJOR_VERSION-python3.7"
  docker push "${REGISTRY}python:$MAJOR_VERSION-python3.7-appservice"

  # tag & push default python:$MAJOR_VERSION-python3.8 and python:$MAJOR_VERSION-python3.8-appservice images
  if [ "$MAJOR_VERSION" != "2.0" ]; then
    docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.8"
    docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.8-appservice"
    docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.8"            "${REGISTRY}python:$MAJOR_VERSION-python3.8"
    docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.8-appservice" "${REGISTRY}python:$MAJOR_VERSION-python3.8-appservice"
    docker push "${REGISTRY}python:$MAJOR_VERSION-python3.8"
    docker push "${REGISTRY}python:$MAJOR_VERSION-python3.8-appservice"
  fi
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
