FROM microsoft/azure-functions-python3.6:arm32v7-python3.6-deps-grpcio

RUN [ "cross-build-start" ]
RUN pip install -I grpcio-tools~=1.9.1
RUN [ "cross-build-end" ]