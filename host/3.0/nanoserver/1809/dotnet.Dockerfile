# escape=`

# Installer image
FROM mcr.microsoft.com/windows/servercore:ltsc2019 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve .NET Core SDK
RUN $dotnet_sdk_version = '5.0.408'; `
    Invoke-WebRequest -OutFile dotnet.zip https://dotnetcli.azureedge.net/dotnet/Sdk/$dotnet_sdk_version/dotnet-sdk-$dotnet_sdk_version-win-x64.zip; `
    $dotnet_sha512 = '3845485401695b325d9afee67e33c6b3a45902476e408dd74ebc8815ad2c4f4b5d70a6b993e87ff587d0d9b0e5a3d66eaf3dd6bf715b0012ffee70501a716485'; `
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
    HOST_VERSION=3.8.0

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    $BuildNumber = $Env:HOST_VERSION.split('.')[-1]; `
    Invoke-WebRequest -OutFile host.zip https://github.com/Azure/azure-functions-host/archive/v$Env:HOST_VERSION.zip; `
    Expand-Archive host.zip .; `
    cd azure-functions-host-$Env:HOST_VERSION; `
    /dotnet/dotnet publish /p:BuildNumber=$BuildNumber /p:CommitHash=$Env:HOST_VERSION src\WebJobs.Script.WebHost\WebJobs.Script.WebHost.csproj  -c Release --output C:\runtime


# Runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-nanoserver-1809

COPY --from=installer-env ["C:\\runtime", "C:\\runtime"]

ENV AzureWebJobsScriptRoot=C:\approot `
    WEBSITE_HOSTNAME=localhost:80

CMD ["dotnet", "C:\\runtime\\Microsoft.Azure.WebJobs.Script.WebHost.dll"]
