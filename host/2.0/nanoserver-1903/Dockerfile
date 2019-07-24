# escape=`

# Installer image
FROM mcr.microsoft.com/windows/servercore:1903 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve .NET Core SDK
ENV DOTNET_SDK_VERSION 2.2.301

RUN Invoke-WebRequest -OutFile dotnet.zip https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$Env:DOTNET_SDK_VERSION/dotnet-sdk-$Env:DOTNET_SDK_VERSION-win-x64.zip; `
    $dotnet_sha512 = '2f7baaa7ca994a0f6550879da66dab67b4799dc634354c2ce746f2e107f35fb931536e8b19c85620a1a400a33e71b6b1b03bf373632a1d338c6b737a2a9cc81b'; `
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
    HOST_COMMIT=3dcce2915295202095d46cdd6e83db3496a33f6d `
    BUILD_NUMBER=12590

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -OutFile host.zip https://github.com/Azure/azure-functions-host/archive/$Env:HOST_COMMIT.zip; `
    Expand-Archive host.zip .; `
    cd azure-functions-host-$Env:HOST_COMMIT; `
    /dotnet/dotnet publish /p:BuildNumber=$Env:BUILD_NUMBER /p:CommitHash=$Env:HOST_COMMIT src\WebJobs.Script.WebHost\WebJobs.Script.WebHost.csproj --output C:\runtime


# Runtime image
FROM mcr.microsoft.com/dotnet/core/aspnet:2.2.6-nanoserver-1903

COPY --from=installer-env ["C:\\runtime", "C:\\runtime"]

ENV AzureWebJobsScriptRoot=C:\approot `
    WEBSITE_HOSTNAME=localhost:80

CMD ["dotnet", "C:\\runtime\\Microsoft.Azure.WebJobs.Script.WebHost.dll"]
