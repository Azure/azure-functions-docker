ARG namespace=microsoft
FROM ${namespace}/azure-functions-python3.6:dev-jessie
ENV AzureWebJobsScriptRoot=/home/site/wwwroot

ENV host:logger:consoleLoggingMode=always

COPY . /home/site/wwwroot

RUN cd /home/site/wwwroot && \
    source /workers/worker_env/bin/activate &&\
    pip3 install -r requirements.txt

CMD ["bash","/home/site/wwwroot/start.sh"]
