#!/bin/bash
if [ "$1" == "3" ]; then
   echo -e "MajorVersion 3 detected. Verifying Extension Bundles in host/3.0/"
   TARGET="./3.0"
else 
   echo -e "MajorVersion 4 detected. Verifying Extension Bundles in host/4/"
   TARGET="./4"
fi

check_extension_bundle() {
  # Assume the docker files are in the current directory or any of its subdirectories and have the extension .Dockerfile
  # Store the first file name in a variable
  first_file=$(find $TARGET -name '*.Dockerfile' | head -n 1)
  # Extract the Ext Bundle Version value from the first file
  expected_version=$(grep -m 1 -oP "EXTENSION_BUNDLE_VERSION_V$VERSION=\K\S*" $first_file)
  echo "Expected ExtensionBundleV$VERSION Version for all images in $TARGET : $expected_version from $first_file"
  # Declare a boolean variable to indicate inconsistency
  inconsistent=false
  # Loop through the rest of the files and compare their values with the first one
  for file in $(find $TARGET -name '*.Dockerfile'); do
    # Extract the Ext Bundle value from the current file
    current_version=$(grep -m 1 -oP "EXTENSION_BUNDLE_VERSION_V$VERSION=\K\S*" $file)
    # Check if current_version is empty // Known files with no hostVersion *-core-tools.Dockerfile and *-build.Dockerfile
    # Ext bundle not included in dotnet isolated images.
    if [ -z "$current_version" ]; then
      if [[ "$file" == *-core-tools* ]] || [[ "$file" == *-build* ]] || [[ "$file" == *dotnet-isolated* ]]; then
        # Ignore the file
        continue
      else
        # Print a message and set the inconsistency flag to true
        echo "No EXTENSION_BUNDLE_VERSION_V$VERSION found in $file"
        inconsistent=true
      fi
    fi
    # Compare the values and print a message if they are different
    if [ "$current_version" != "$expected_version" ]; then
      echo "Mismatch found: $file has EXTENSION_BUNDLE_VERSION_V$VERSION=$current_version"
      # Set the inconsistency flag to true
      inconsistent=true
    fi
  done
  # Check the inconsistency flag and exit with a 1 if it is true
  if [ "$inconsistent" == "true" ]; then
    echo "Inconsistency detected: EXTENSION_BUNDLE_VERSION_V$VERSION values are not the same across all files"
    echo "$first_file has EXTENSION_BUNDLE_VERSION_V$VERSION=$expected_version"
    exit 1
  fi
}
VERSION=2
check_extension_bundle
VERSION=3
check_extension_bundle
VERSION=4
check_extension_bundle

exit 0
