#!/usr/bin/env bash

if [ -z $PORT ]; then
  ASPNETCORE_URLS=http://*:80
else
  ASPNETCORE_URLS=http://*:$PORT
fi

if [ -z $SSH_PORT ]; then
  SSH_PORT=2222
fi

sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config

service ssh start

if [ -f /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost ]; then
    /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost
else
    dotnet /azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost.dll
fi