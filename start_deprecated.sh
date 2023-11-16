#!/usr/bin/env bash
echo -e "**WARNING**: You are using an outdated version of the Azure Functions runtime. 
Function apps running on version 3.x have reached the end of life (EOL) of extended support as of December 13, 2022. 
This means that your function app may not receive security updates, bug fixes, or performance improvements. 
To avoid potential issues, we recommend that you upgrade to the latest version of the Azure Functions runtime as soon as possible. 
For more information on how to upgrade and the benefits of doing so please visit:
https://learn.microsoft.com/en-us/azure/azure-functions/migrate-version-3-version-4
Thank you for using Azure Functions!"
/azure-functions-host/Microsoft.Azure.WebJobs.Script.WebHost