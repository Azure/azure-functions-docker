ARG BASE_IMAGE=mcr.microsoft.com/azure-functions/base:2.0
ARG BASE_PYTHON_IMAGE=mcr.microsoft.com/azure-functions/python:2.0-python3.6-deps
FROM ${BASE_IMAGE} as runtime-image
ARG BASE_PYTHON_IMAGE
FROM ${BASE_PYTHON_IMAGE}

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]

# Add custom worker config
COPY ./python-context/start.sh ./python-context/worker.config.json /azure-functions-host/workers/python/
RUN chmod +x /azure-functions-host/workers/python/start.sh

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]