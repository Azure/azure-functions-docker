#!/bin/bash

set -euo pipefail

# Update Status
# Upload Status Json to the Blob Strage on Azure. 
# az long before execture this command
# -e: immediately exit if any commands has a non-zero exit status
# -o: prevents errors in a pipeline from being masked

usage() { echo "Usage: update_status -f <fileName> -s <status> -n <name>" 1>&2; exit 1; }

declare storageAccountName="tsushicistate"
declare container="healthcheck"
declare fileName=""
declare status=""
declare name=""

while getopts ":f:s:n:" arg; do
    case "${arg}" in
      f)
        fileName=${OPTARG}
      ;;
      s)
        status=${OPTARG}
      ;;
      n)
        name=${OPTARG}
      ;;
    esac
done

shift $((OPTIND-1))

if [[ -z "$fileName" ]]; then
  echo "Enter a fileName (e.g. azure-functions-core-tools.json)"
  usage;
fi

if [[ -z "$status" ]]; then
  echo "Enter a status (0: success, 1: warning, 2: error)"  
  usage;
fi

if [[ -z "$name" ]]; then
  echo "Enter a name (e.g. \"Azure Functions Core Tools CI\")"
  usage;
fi

currentDate=`date -u +%Y-%m-%dT%H:%M:%S%NZ`

echo "{\"Name\":\"${name}\", \"state\":${status},\"updatedTime\":\"${currentDate}\"}" > ${fileName}
echo "1-Upload status json to Blob storage (# az storage blob upload --account-name ${storageAccountName} --container-name ${container} --name ${fileName} --<resource-group>file ${fileName} )"
az storage blob upload --account-name ${storageAccountName} --container-name ${container} --name ${fileName} --file ${fileName} # --auth-mode login
