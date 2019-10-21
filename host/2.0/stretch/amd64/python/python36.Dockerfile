ARG BASE_IMAGE
ARG BASE_PYTHON_IMAGE
FROM ${BASE_IMAGE} as runtime-image
ARG BASE_PYTHON_IMAGE
FROM ${BASE_PYTHON_IMAGE}

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

# Add custom worker config
COPY ./python36-context/start.sh ./python36-context/worker.config.json /azure-functions-host/workers/python/
RUN chmod +x /azure-functions-host/workers/python/start.sh

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]