#! /bin/bash

COUNTER=0
while [ $COUNTER -lt 5 ]; do
    dotnet /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll
    echo "process exited with $?"
    echo "restarting host process: $COUNTER"
    let COUNTER=COUNTER+1
done