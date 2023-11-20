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

echo -e "**WARNING**: You are using an outdated version of the Azure Functions runtime:
https://learn.microsoft.com/en-us/azure/azure-functions/migrate-version-3-version-4
===================================================================================="

if [ -f /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost ]; then
    /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost
else
    dotnet /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll
fi