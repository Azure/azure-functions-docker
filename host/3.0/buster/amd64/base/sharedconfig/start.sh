#!/usr/bin/env bash

export DOTNET_USE_POLLING_FILE_WATCHER=true

if [ -z $PORT ]; then
  export ASPNETCORE_URLS=http://*:80
else
  export ASPNETCORE_URLS=http://*:$PORT
fi

if [ -z $SSH_PORT ]; then
  export SSH_PORT=2222
fi

if [ "$APPSVC_REMOTE_DEBUGGING" == "TRUE" ]; then
    export languageWorkers__node__arguments="--inspect=0.0.0.0:$APPSVC_TUNNEL_PORT"
    export languageWorkers__python__arguments="-m ptvsd --host localhost --port $APPSVC_TUNNEL_PORT"
fi

# Get environment variables to show up in SSH session
eval $(printenv | sed -n "s/^\([^=]\+\)=\(.*\)$/export \1=\2/p" | sed 's/"/\\\"/g' | sed '/=/s//="/' | sed 's/$/"/' >> /etc/profile)

# starting sshd process
sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config

service ssh start

echo -e "**WARNING**: You are using an outdated version of the Azure Functions runtime. 
Function apps running on version 3.x have reached the end of life (EOL) of extended support as of December 13, 2022. 
This means that your function app may not receive security updates, bug fixes, or performance improvements. 
To avoid potential issues, we recommend that you upgrade to the latest version of the Azure Functions runtime as soon as possible. 
For more information on how to upgrade and the benefits of doing so please visit:
https://learn.microsoft.com/en-us/azure/azure-functions/migrate-version-3-version-4
Thank you for using Azure Functions!"


if [ -f /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost ]; then
    /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost
else
    dotnet /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll
fi