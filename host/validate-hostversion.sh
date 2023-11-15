#!/bin/bash
if [ "$1" == "3" ]; then
   echo -e "MajorVersion 3 detected. Verifying host_version in host/3.0/"
   TARGET="./3.0"
else 
   echo -e "MajorVersion 4 detected. Verifying host_version in host/4/"
   TARGET="./4"
fi
# Assume the docker files are in the current directory or any of its subdirectories and have the extension .Dockerfile
# Store the first file name in a variable
first_file=$(find $TARGET -name '*.Dockerfile' | head -n 1)
# Extract the HOST_VERSION value from the first file
expected_host_version=$(grep -m 1 -oP 'ARG HOST_VERSION=\K.*' $first_file)
echo "Expected Host Version for all images in $TARGET : $expected_host_version"
# Declare a boolean variable to indicate inconsistency
inconsistent=false
# Loop through the rest of the files and compare their values with the first one
for file in $(find $TARGET -name '*.Dockerfile'); do
  # Extract the HOST_VERSION value from the current file
  current_version=$(grep -m 1 -oP 'ARG HOST_VERSION=\K.*' $file)
  # Check if current_version is empty // Known files with no hostVersion *-core-tools.Dockerfile and *-build.Dockerfile
  if [ -z "$current_version" ]; then
    if [[ "$file" == *-core-tools* ]] || [[ "$file" == *-build* ]]; then
      # Ignore the file
      continue
    else
      # Print a message and set the inconsistency flag to true
      echo "No HOST_VERSION found in $file"
      inconsistent=true
    fi
  fi
  # Compare the values and print a message if they are different
  if [ "$current_version" != "$expected_host_version" ]; then
    echo "Mismatch found: $file has HOST_VERSION=$current_version, while $first_file has HOST_VERSION=$expected_host_version"
    # Set the inconsistency flag to true
    inconsistent=true
  fi
done
# Check the inconsistency flag and exit with a 1 if it is true
if [ "$inconsistent" == "true" ]; then
  echo "Inconsistency detected: HOST_VERSION values are not the same across all files"
  exit 1
fi
exit 0
