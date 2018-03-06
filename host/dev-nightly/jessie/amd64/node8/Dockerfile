FROM azure-functions-base:stretch

RUN apt-get update && \
    apt-get install -y curl && \
    curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    apt-get install - y \ 
        nodejs

ENV AzureWebJobsScriptRoot=/app

ENV WEBSITE_HOSTNAME=localhost:80

CMD ["dotnet", "/azure-functions-runtime/Microsoft.Azure.WebJobs.Script.WebHost.dll"]
