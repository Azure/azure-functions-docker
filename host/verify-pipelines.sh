#! /bin/bash



DIR=$(dirname $0)
IFS=$'\n'

check_sovereign() {
  sharedimages=($(comm -12 <(printf '%s\n' "${stage[@]}"|sort -u) <(printf '%s\n' "${pub[@]}"|sort -u)))
  sovereign=($(((grep "docker push".*appservice ${TARGET}/publish-appservice-stage-sovereign-clouds.yml) | awk -F'-appservice' '{print $1}') | awk -F 'TARGET_REGISTRY' '{print $2}') )
  diffsovereign=($(comm -3 <(printf '%s\n' "${sharedimages[@]}"|sort -u) <(printf '%s\n' "${sovereign[@]}"|sort -u)))
  if [ -z "$diffsovereign" ]; then
    echo -e "Sovereign pipeline verified for ${TARGET}/. Proceed with release.\n"
    exit 0
  else 
    echo -e "Sovereign pipeline is invalid. Other than the /base image all pipelines should publish the same -appservice images. The following differences exist for -appservice images in the sovereign pipeline: "
    echo -e ${diffsovereign[@]}
    exit 1
  fi
}

if [ "$1" != "2.0" ] && [ "$1" != "3" ] && [ "$1" != "4" ]; then
  echo -e "MajorVersion must be 2.0, 3, or 4 Got '$1'\n"
  print_usage
  exit 1
fi

if [ "$1" == "2.0" ]; then
   echo -e "MajorVersion 2.0 is not supported by this script. Continuing with NoOp"
   exit 0
fi

if [ "$1" == "3" ]; then
   echo -e "MajorVersion 3 detected. Verifying pipelines in host/3.0/"
   TARGET="./3.0"
else 
   echo -e "MajorVersion 4 detected. Verifying pipelines in host/4/"
   TARGET="./4"
fi

stage=($(((grep "docker push".*appservice ${TARGET}/publish-appservice-stage.yml) | awk -F'-appservice' '{print $1}') | awk -F 'TARGET_REGISTRY' '{print $2}') )

pub=($((((grep "docker push".*appservice  ${TARGET}/publish.yml)| grep -v quickstart) | awk -F'-appservice' '{print $1}') | awk -F 'TARGET_REGISTRY' '{print $2}') )

difference=($(comm -3 <(printf '%s\n' "${stage[@]}"|sort -u) <(printf '%s\n' "${pub[@]}"|sort -u)))

if [ -z "$difference" ]; then
  echo -e "No differences between Stage and Publish pipelines.  Verifying sovereign cloud pipeline.\n"
  check_sovereign
  exit 0
fi

if [ ${#difference[@]} == 1 ] && [[ $difference =~ "base" ]]; then
   echo -e "Stage pipeline excludes base image. This is a known difference. Rollout Safe. Verifying sovereign cloud pipeline."
   check_sovereign
   exit 0
else 
   echo -e "Publish and stage pipelines inconsistent. Other than the /base image all pipelines should publish the same -appservice images. The following differences exist for -appservice images between the pipelines: "
   echo -e ${difference[@]}
   exit 1
fi
