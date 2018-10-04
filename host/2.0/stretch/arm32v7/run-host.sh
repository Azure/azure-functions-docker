#! /bin/bash

COUNTER=0
while [ $COUNTER -lt 10 ]
do
    dotnet /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll
    echo "process exited with $?"
    echo "restarting host process"
    let COUNTER=COUNTER+1
done