#!/bin/bash

# Source and destination directories
source_dir="/var/ssl/root"
destination_dir="/usr/local/share/ca-certificates"

if [[ "$WEBSITES_INCLUDE_CLOUD_CERTS" == "true" ]]; then
    echo "WEBSITES_INCLUDE_CLOUD_CERTS is set to true."
    agc_source_dir="/usr/local/azure/certs"
    if [ "$(ls "$agc_source_dir"/*.crt 2>/dev/null)" ]; then
      # Copy CA certificates
      cp "$agc_source_dir"/*.crt "$destination_dir"
      # Run update-ca-certificates command to update the CA certificate store
      update-ca-certificates
    fi
else
    echo "WEBSITES_INCLUDE_CLOUD_CERTS is not set to true."
fi


# Check if the source directory has no files with the .crt extension
if [ "$(ls "$source_dir"/*.crt 2>/dev/null)" ]; then
   
   # Copy CA certificates
   cp "$source_dir"/*.crt "$destination_dir"
   
   # Run update-ca-certificates command to update the CA certificate store
   update-ca-certificates

   echo "CA certificates copied and updated successfully."
fi