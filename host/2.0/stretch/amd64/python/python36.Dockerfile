ARG BASE_IMAGE
ARG BASE_PYTHON_IMAGE
FROM ${BASE_IMAGE} as runtime-image
ARG BASE_PYTHON_IMAGE
FROM ${BASE_PYTHON_IMAGE}

COPY --from=runtime-image ["/azure-functions-host", "/azure-functions-host"]
COPY --from=runtime-image [ "/workers/python", "/azure-functions-host/workers/python" ]
COPY --from=runtime-image [ "/FuncExtensionBundles", "/FuncExtensionBundles" ]

ENV FUNCTIONS_WORKER_RUNTIME_VERSION=3.6

CMD [ "/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost" ]
