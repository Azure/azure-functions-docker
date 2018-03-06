#!/bin/bash
pwd
ls /workers/worker_env/bin
source /workers/worker_env/bin/activate
dotnet /azure-functions-runtime/Microsoft.Azure.WebJobs.Script.WebHost.dll
