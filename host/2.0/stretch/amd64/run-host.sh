#! /bin/bash

while true
do
    dotnet /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll
    echo "process exited with $?"
    echo "restarting host process"
done