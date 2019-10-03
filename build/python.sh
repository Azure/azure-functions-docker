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

  # build python:$HOST_VERSION.x-python3.6 and python:$HOST_VERSION.x-python3.6-appservice
  docker build -t "${REGISTRY}python:${HOST_VERSION}-python3.6-deps"       -f $DIR/../host/2.0/stretch/amd64/python/python36-deps.Dockerfile $DIR/../host/2.0/stretch/amd64/python
  docker build -t "${REGISTRY}python:${HOST_VERSION}-python3.6-buildenv"   -f $DIR/../host/2.0/stretch/amd64/python/python36-buildenv.Dockerfile --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${HOST_VERSION}-python3.6-deps"                                                          $DIR/../host/2.0/stretch/amd64/python
  docker build -t "${REGISTRY}python:${HOST_VERSION}-python3.6"            -f $DIR/../host/2.0/stretch/amd64/python/python36.Dockerfile          --build-arg BASE_IMAGE="${REGISTRY}base:${HOST_VERSION}" --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${HOST_VERSION}-python3.6-deps" $DIR/../host/2.0/stretch/amd64/python
  docker build -t "${REGISTRY}python:${HOST_VERSION}-python3.6-appservice" -f $DIR/../host/2.0/stretch/amd64/appservice/python36.Dockerfile      --build-arg BASE_IMAGE="${REGISTRY}python:${HOST_VERSION}-python3.6"                                                                      $DIR/../host/2.0/stretch/amd64/appservice
  test_image "${REGISTRY}python:${HOST_VERSION}-python3.6"
  test_image "${REGISTRY}python:${HOST_VERSION}-python3.6-appservice"

  # build python:$HOST_VERSION.x-python3.7 and python:$HOST_VERSION.x-python3.7-appservice
  docker build -t "${REGISTRY}python:${HOST_VERSION}-python3.7-deps"       -f $DIR/../host/2.0/stretch/amd64/python/python37-deps.Dockerfile $DIR/../host/2.0/stretch/amd64/python
  docker build -t "${REGISTRY}python:${HOST_VERSION}-python3.7-buildenv"   -f $DIR/../host/2.0/stretch/amd64/python/python37-buildenv.Dockerfile --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${HOST_VERSION}-python3.7-deps"                                                          $DIR/../host/2.0/stretch/amd64/python
  docker build -t "${REGISTRY}python:${HOST_VERSION}-python3.7"            -f $DIR/../host/2.0/stretch/amd64/python/python37.Dockerfile          --build-arg BASE_IMAGE="${REGISTRY}base:${HOST_VERSION}" --build-arg BASE_PYTHON_IMAGE="${REGISTRY}python:${HOST_VERSION}-python3.7-deps" $DIR/../host/2.0/stretch/amd64/python
  docker build -t "${REGISTRY}python:${HOST_VERSION}-python3.7-appservice" -f $DIR/../host/2.0/stretch/amd64/appservice/python37.Dockerfile      --build-arg BASE_IMAGE="${REGISTRY}python:${HOST_VERSION}-python3.7"                                                                      $DIR/../host/2.0/stretch/amd64/appservice
  test_image "${REGISTRY}python:${HOST_VERSION}-python3.7"
  test_image "${REGISTRY}python:${HOST_VERSION}-python3.7-appservice"

  # tag default python:$HOST_VERSION.x and python:$HOST_VERSION.x-appservice
  docker tag "${REGISTRY}python:${HOST_VERSION}-python3.6" "${REGISTRY}python:${HOST_VERSION}"
  docker tag "${REGISTRY}python:${HOST_VERSION}-python3.6-appservice" "${REGISTRY}python:${HOST_VERSION}-appservice"

  # tag quickstart image
  docker tag "${REGISTRY}python:${HOST_VERSION}-appservice" "${REGISTRY}python:${HOST_VERSION}-appservice-quickstart"
}

function push {
  # push build-env images
  docker push "${REGISTRY}python:${HOST_VERSION}-python3.6-buildenv"
  docker push "${REGISTRY}python:${HOST_VERSION}-python3.7-buildenv"

  # push default python:$HOST_VERSION.x and python:$HOST_VERSION.x-appservice images
  docker push "${REGISTRY}python:${HOST_VERSION}"
  docker push "${REGISTRY}python:${HOST_VERSION}-appservice"
  docker push "${REGISTRY}python:${HOST_VERSION}-appservice-quickstart"

  # push default python:$HOST_VERSION.x-python3.6 and python:$HOST_VERSION.x-python3.6-appservice images
  docker push "${REGISTRY}python:${HOST_VERSION}-python3.6"
  docker push "${REGISTRY}python:${HOST_VERSION}-python3.6-appservice"

  # push default python:$HOST_VERSION.x-python3.7 and python:$HOST_VERSION.x-python3.7-appservice images
  docker push "${REGISTRY}python:${HOST_VERSION}-python3.7"
  docker push "${REGISTRY}python:${HOST_VERSION}-python3.7-appservice"
}

function purge {
  # purge deps image
  docker rmi "${REGISTRY}python:${HOST_VERSION}-python3.6-deps"
  docker rmi "${REGISTRY}python:${HOST_VERSION}-python3.7-deps"

  # purge build-env images
  docker rmi "${REGISTRY}python:${HOST_VERSION}-python3.6-buildenv"
  docker rmi "${REGISTRY}python:${HOST_VERSION}-python3.7-buildenv"

  # purge default python:$HOST_VERSION.x and python:$HOST_VERSION.x-appservice images
  docker rmi "${REGISTRY}python:${HOST_VERSION}"
  docker rmi "${REGISTRY}python:${HOST_VERSION}-appservice"
  docker rmi "${REGISTRY}python:${HOST_VERSION}-appservice-quickstart"

  # purge default python:$HOST_VERSION.x-python3.6 and python:$HOST_VERSION.x-python3.6-appservice images
  docker rmi "${REGISTRY}python:${HOST_VERSION}-python3.6"
  docker rmi "${REGISTRY}python:${HOST_VERSION}-python3.6-appservice"

  # purge default python:$HOST_VERSION.x-python3.7 and python:$HOST_VERSION.x-python3.7-appservice images
  docker rmi "${REGISTRY}python:${HOST_VERSION}-python3.7"
  docker rmi "${REGISTRY}python:${HOST_VERSION}-python3.7-appservice"
}

function tag_push {
  # tag & push build-env images
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.6-buildenv"
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.7-buildenv"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.6-buildenv" "${REGISTRY}python:2.0-python3.6-buildenv"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.7-buildenv" "${REGISTRY}python:2.0-python3.7-buildenv"
  docker push "${REGISTRY}python:2.0-python3.6-buildenv"
  docker push "${REGISTRY}python:2.0-python3.7-buildenv"

  # tag & push default python:2.0 and python:2.0-appservice images
  docker pull "${REGISTRY}python:${RELEASE_VERSION}"
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-appservice"
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-appservice-quickstart"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}"                       "${REGISTRY}python:2.0"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-appservice"            "${REGISTRY}python:2.0-appservice"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-appservice-quickstart" "${REGISTRY}python:2.0-appservice-quickstart"
  docker push "${REGISTRY}python:2.0"
  docker push "${REGISTRY}python:2.0-appservice"
  docker push "${REGISTRY}python:2.0-appservice-quickstart"

  # tag & push default python:2.0-python3.6 and python:2.0-python3.6-appservice images
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.6"
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.6-appservice"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.6"            "${REGISTRY}python:2.0-python3.6"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.6-appservice" "${REGISTRY}python:2.0-python3.6-appservice"
  docker push "${REGISTRY}python:2.0-python3.6"
  docker push "${REGISTRY}python:2.0-python3.6-appservice"

  # tag & push default python:2.0-python3.7 and python:2.0-python3.7-appservice images
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.7"
  docker pull "${REGISTRY}python:${RELEASE_VERSION}-python3.7-appservice"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.7"            "${REGISTRY}python:2.0-python3.7"
  docker tag  "${REGISTRY}python:${RELEASE_VERSION}-python3.7-appservice" "${REGISTRY}python:2.0-python3.7-appservice"
  docker push "${REGISTRY}python:2.0-python3.7"
  docker push "${REGISTRY}python:2.0-python3.7-appservice"
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