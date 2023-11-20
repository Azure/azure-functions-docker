# escape=`

# Installer image
FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve .NET Core SDK
RUN $dotnet_sdk_version = '5.0.404'; `
    Invoke-WebRequest -OutFile dotnet.zip https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-win-x64.zip; `
    $dotnet_sha512 = 'a6d254a46e93a41bf41df34c941503cfc5f61af20ffc0abc571bbaf238fd66f0fcc879e7181e1e1af788e96912b31012e817bf1202e55b8f27c17352f3f5528d'; `
    if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $dotnet_sha512) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    Expand-Archive dotnet.zip -DestinationPath dotnet; `
    Remove-Item -Force dotnet.zip

ENV ASPNETCORE_URLS=http://+:80 `
    DOTNET_RUNNING_IN_CONTAINER=true `
    DOTNET_USE_POLLING_FILE_WATCHER=true `
    NUGET_XMLDOC_MODE=skip `
    PublishWithAspNetCoreTargetManifest=false `
    HOST_VERSION=3.20.2

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    $BuildNumber = $Env:HOST_VERSION.split('.')[-1]; `
    Invoke-WebRequest -OutFile host.zip https://github.com/Azure/azure-functions-host/archive/v$Env:HOST_VERSION.zip; `
    Expand-Archive host.zip .; `
    cd azure-functions-host-$Env:HOST_VERSION; `
    /dotnet/dotnet publish /p:BuildNumber=$BuildNumber /p:CommitHash=$Env:HOST_VERSION src\WebJobs.Script.WebHost\WebJobs.Script.WebHost.csproj  -c Release --output C:\runtime


# Runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-nanoserver-1809

COPY --from=installer-env ["C:\\runtime", "C:\\runtime"]
COPY start_deprecated.sh /azure-functions-host/

ENV AzureWebJobsScriptRoot=C:\approot `
    WEBSITE_HOSTNAME=localhost:80

CMD ["/azure-functions-host/start_deprecated.sh"]