#!/usr/bin/env bash
echo -e "**WARNING**: You are using an outdated version of the Azure Functions runtime:
https://learn.microsoft.com/en-us/azure/azure-functions/migrate-version-3-version-4
===================================================================================="

if [ -f /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost ]; then
    /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost
else
    dotnet /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll
fi