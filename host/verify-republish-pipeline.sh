#! /bin/bash



DIR=$(dirname $0)
IFS=$'\n'

fullversion=$1
majorversion=${fullversion:0:1}

if [ "$majorversion" != "2" ] && [ "$majorversion" != "3" ] && [ "$majorversion" != "4" ]; then
  echo -e "MajorVersion must be 2, 3, or 4 Got '$1'\n"
  print_usage
  exit 1
fi

if [ "$majorversion" == "2" ]; then
   echo -e "MajorVersion 2 is not supported by this script. Continuing with NoOp"
   exit 0
fi

if [ "$majorversion" == "3" ]; then
   echo -e "MajorVersion 3 detected. Verifying pipelines in host/3.0/"
   TARGET="./3.0"
else 
   echo -e "MajorVersion 4 detected. Verifying pipelines in host/4/"
   TARGET="./4"
fi

repub=($(((grep "docker push".* ${TARGET}/republish.yml) | awk -F 'TARGET_REGISTRY' '{print $2}') ))

pub=($(((((grep "docker push".*  ${TARGET}/publish.yml)| grep -v appservice)| grep -v nanoserver) | awk -F 'TARGET_REGISTRY' '{print $2}') ))

difference=($(comm -3 <(printf '%s\n' "${repub[@]}"|sort -u) <(printf '%s\n' "${pub[@]}"|sort -u)))

if [ -z "$difference" ]; then
  echo -e "No differences between Republish and Publish pipelines.\n"
  exit 0
fi

echo ${#difference[@]}
if [ ${#difference[@]} == 1 ] && [[ $difference == *"nanoserver"* ]]; then
   echo -e "Republish pipeline excludes nanoserver image. This is a known difference. Redeployment Safe. \n"
   exit 0
else 
   echo -e "Republish and Publish pipelines inconsistent. Other than the /base image all pipelines should publish the same non-appservice images. The following differences exist for non-appservice images between the pipelines: "
   echo -e ${difference[@]}
   exit 1
fi
