#!/bin/bash

# Source and destination directories
source_dir="/var/ssl/root"
destination_dir="/usr/local/share/ca-certificates"

# Check if the source directory has no files with the .crt extension
if [ "$(ls "$source_dir"/*.crt 2>/dev/null)" ]; then
   
   # Copy CA certificates
   cp "$source_dir"/*.crt "$destination_dir"
   
   # Run update-ca-certificates command to update the CA certificate store
   update-ca-certificates

   echo "CA certificates copied and updated successfully."
fi