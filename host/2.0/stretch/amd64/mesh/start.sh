#! /bin/bash

dotnet /warmup-helper/WarmupHelper.dll &

exec /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost