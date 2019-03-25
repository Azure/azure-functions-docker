#! /bin/bash

set -e

DIR=$(dirname $0)

# Building stretch
ACR=azurefunctions.azurecr.io
ACR_NAMESPACE=public/azure-functions

if [ -z "$branch" ]; then
    branch=master
fi

function build_image {
    local language=$1
    local tag=$2
    local base_dir=$3
    local base_lang=$4
    local base_tag=$5

    if [ -z "$base_tag" ]; then
        base_tag=$tag
    fi

    if [ -z "$base_lang" ]; then
        base_image=$ACR/$ACR_NAMESPACE/base:$base_tag
    else
        base_image=$ACR/$ACR_NAMESPACE/$base_lang:$base_tag
    fi

    if [ -z "$base_dir" ]; then
        base_dir=$DIR/host/2.0/stretch/amd64
    fi

    if [[ "$(docker images -q $base_image 2> /dev/null)" == "" ]] && [ "$language" != "base" ] ; then
        build_image base $tag $base_dir
    fi


    local current_image=$ACR/$ACR_NAMESPACE/$language:$tag

    if [ "$language" == "base" ]; then
        docker build -t $current_image -f $base_dir/$language.Dockerfile $base_dir
    else
        docker build -t $current_image --build-arg BASE_IMAGE=$base_image \
            -f $base_dir/$language.Dockerfile \
            $base_dir
    fi

    if ! [ -z "$RUN_TESTS" ] && [ "$language" != "base" ]; then
        dotnet run --project $DIR/test/test.csproj $current_image
    fi
}

function push_image {
    local language=$1
    local tag=$2

    current_image=$ACR/$ACR_NAMESPACE/$language:$tag
    docker push $current_image
}


function build_all_stretch {
    local languages=( base dotnet node powershell python mesh java )
    for language in "${languages[@]}"
    do
        if [ "$language" == "mesh" ]; then
            build_image $language $branch $DIR/host/2.0/stretch/amd64 python
        else
            build_image $language $branch $DIR/host/2.0/stretch/amd64 base
        fi

        if [[ "$branch" == 2\.0\.* ]]; then
            push_image $language
        fi
    done
}

function build_all_appservice {
    local languages=( dotnet node powershell python java )
    for language in "${languages[@]}"
    do
        build_image $language $branch-appservice $DIR/host/2.0/stretch/amd64/appservice $language $branch

        if [[ "$branch" == 2\.0\.* ]]; then
            push_image $language
        fi
    done
}

function build_all_alpine {
    local languages=( dotnet node powershell python java )
    for language in "${languages[@]}"
    do
        build_image $language $branch-alpine $DIR/host/2.0/alpine/amd64/ base

        if [[ "$branch" == 2\.0\.* ]]; then
            push_image $language
        fi
    done
}

function build_all_stretch_slim {
    echo "slim"
}

function purge_all {
    docker system prune -f -a
}

if [ "$1" == "all" ]; then
    build_all_stretch
    build_all_appservice
    # build_all_stretch_slim
    # build_all_alpine
elif [ "$1" == "stretch" ]; then
    build_all_stretch
elif [ "$1" == "appservice" ]; then
    build_all_appservice
elif [ "$1" == "alpine" ]; then
    build_all_alpine
elif ! [ -z "$1" ] && ! [ -z "$2" ]; then
    build_image $1 $2 $3 $4 $5
fi

if ! [ -z "$CI_RUN" ]; then
    purge_all
fi