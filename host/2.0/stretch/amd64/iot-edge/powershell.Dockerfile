ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/powershell
ARG BASE_IMAGE_TAG=2.0
FROM ${BASE_IMAGE}:${BASE_IMAGE_TAG}

CMD ["dotnet", "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll"]