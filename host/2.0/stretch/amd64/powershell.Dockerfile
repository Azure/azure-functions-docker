ARG BASE_IMAGE_TAG=dev
ARG WORKER_TAG=0.1.10-alpha

# Upzip worker step
FROM azure-functions/base:${BASE_IMAGE_TAG} AS functions-base
ARG BASE_IMAGE_TAG
ARG WORKER_TAG

# Add the nupkg to the container and unzip it
ADD https://www.myget.org/F/azure-appservice/api/v2/package/Microsoft.Azure.Functions.PowerShellWorker/${WORKER_TAG} PowerShellWorker.nupkg
RUN apt-get update && apt-get install -y unzip && unzip -q PowerShellWorker.nupkg

# Copy the powershell worker to the workers folder
FROM azure-functions/base:${BASE_IMAGE_TAG}
COPY --from=functions-base contentFiles/any/any/workers/powershell azure-functions-host/workers/powershell
