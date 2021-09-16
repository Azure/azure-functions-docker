#! /bin/bash

DIR=$(dirname $0)
IFS=$'\n'

stage=($(((grep "docker push".*appservice publish-appservice-stage.yml) | awk -F'-appservice' '{print $1}') | awk -F 'TARGET_REGISTRY' '{print $2}') )

pub=($((((grep "docker push".*appservice publish.yml)| grep -v quickstart) | awk -F'-appservice' '{print $1}') | awk -F 'TARGET_REGISTRY' '{print $2}') )

difference=($(comm -3 <(printf '%s\n' "${stage[@]}"|sort -u) <(printf '%s\n' "${pub[@]}"|sort -u)))

if [ -z "$difference" ]; then
  echo -e "No differences between Stage and Publish pipelines. Rollout Safe'\n"
  exit 0
fi

if [ ${#difference[@]} == 1 ] && [[ $difference =~ "base" ]]; then
   echo -e "Stage pipeline excludes base image. This is a known difference. Rollout Safe"
   exit 0
else 
   echo -e "Publish and stage pipelines inconsistent. The following differences exist for -appservice images between the pipelines: "
   echo -e ${difference[@]}
   exit 1
fi
