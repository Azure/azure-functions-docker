FROM python:3.6.4-stretch as python-env

RUN apt-get update && \
    apt-get install -y git

RUN git clone https://github.com/Azure/azure-functions-python-worker.git


FROM microsoft/azure-functions-base:dev-stretch

COPY --from=python-env ["azure-functions-python-worker", "workers/azure-functions-python-worker"]

## Install pyenv
RUN apt update && \
    apt list python3* | grep 3.6

RUN cd workers && \
    /bin/bash -c \
    "python3 --version && \
    python3 -m venv worker_env && \
    source worker_env/bin/activate && \
    cd azure-functions-python-worker && \
    pip3 install -r requirements.txt &&  \
    python3 setup.py build && \
    pip install -U -e .[dev]"

ENV workers:config:path /workers/azure-functions-python-worker
ENV workers:python:path /workers/azure-functions-python-path/python/worker.py
ENV AzureWebJobsScriptRoot=/app
ENV WEBSITE_HOSTNAME=localhost:80

CMD ["dotnet", "/azure-functions-runtime/Microsoft.Azure.WebJobs.Script.WebHost.dll"]
