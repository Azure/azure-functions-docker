#! /bin/bash

DIR=$(dirname $0)

function print_usage {
  echo -e "Usage: $0 <MajorVersion> <FullVersion>\n"
  echo -e "Requires gnu-sed for it to work. Please install it using `brew install gnu-sed --with-default-names`"
  echo -e "Example: $0 3.0 3.1.1"
  echo -e "Example: $0 4.0 4.10.2"
}

if [ "$1" != "3" ] && [ "$1" != "4" ]; then
  echo -e "MajorVersion must be '3', or '4' Got '$1'\n"
  print_usage
  exit 1
fi

if [ -z "$2" ]; then
  echo -e "Please pass the FullVersion. The whole FullVersion is required.\n"
  print_usage
  exit 1
fi

if [ "$1" == "3" ]; then
   find $DIR/3.0 -name "*Dockerfile" -exec gsed -i "s/\bHOST_VERSION=$1\..*/HOST_VERSION=$2/g" {} \;
else 
   find $DIR/$1 -name "*Dockerfile" -exec gsed -i "s/\bHOST_VERSION=$1\..*/HOST_VERSION=$2/g" {} \;
fi
