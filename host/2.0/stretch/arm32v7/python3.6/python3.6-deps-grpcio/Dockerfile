FROM microsoft/azure-functions-python3.6:arm32v7-python3.6-deps

RUN [ "cross-build-start" ]
RUN pip install -U grpcio~=1.9.1
RUN [ "cross-build-end" ]