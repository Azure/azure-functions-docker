FROM microsoft/azure-functions-python3.6:dev-jessie
ENV AzureWebJobsScriptRoot=/home/site/wwwroot

ENV host:logger:consoleLoggingMode=always

COPY . /home/site/wwwroot

CMD ["bash","/home/site/wwwroot/start.sh"]
