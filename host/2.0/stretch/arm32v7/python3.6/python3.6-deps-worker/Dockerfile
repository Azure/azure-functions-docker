ARG WORKER_TAG=dev
FROM microsoft/azure-functions-python3.6:arm32v7-python3.6-deps
ARG WORKER_TAG

RUN [ "cross-build-start" ]
RUN pip install -e git+https://github.com/Azure/azure-functions-python-worker.git@${WORKER_TAG}#egg=azure-functions
RUN [ "cross-build-end" ]