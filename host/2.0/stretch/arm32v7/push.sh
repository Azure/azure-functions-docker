#! /bin/bash
set -e

images=( base dotnet node python mesh powershell )
for i in "${images[@]}"
do
    docker push azurefunctions.azurecr.io/public/azure-functions/$i:2.0-arm32v7
done