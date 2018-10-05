# escape=`

# Installer image
FROM mcr.microsoft.com/windows/servercore:1809 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve .NET Core SDK
ENV DOTNET_SDK_VERSION=2.1.403

RUN Invoke-WebRequest -OutFile dotnet.zip https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$Env:DOTNET_SDK_VERSION/dotnet-sdk-$Env:DOTNET_SDK_VERSION-win-x64.zip; `
    $dotnet_sha512 = '52bb1117f170587eaceec1f78cdc41a41d4272154b5535bf61c86bfb75287323cac248434b05eabe4bc7716facabdb0f6475015cbb63f38d91af662618a06720'; `
    if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $dotnet_sha512) { `
    Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
    exit 1; `
    }; `
    `
    Expand-Archive dotnet.zip -DestinationPath $Env:ProgramFiles\dotnet; `
    Remove-Item -Force dotnet.zip; `
    setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '\dotnet')

ENV PublishWithAspNetCoreTargetManifest=false `
    NUGET_XMLDOC_MODE=skip `
    HOST_COMMIT=dev `
    BUILD_NUMBER=12134

RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    Invoke-WebRequest -OutFile host.zip https://github.com/Azure/azure-functions-host/archive/$Env:HOST_COMMIT.zip; `
    Expand-Archive host.zip .; `
    cd azure-functions-host-$Env:HOST_COMMIT; `
    dotnet publish /p:BuildNumber=$Env:BUILD_NUMBER /p:CommitHash=$Env:HOST_COMMIT src\WebJobs.Script.WebHost\WebJobs.Script.WebHost.csproj --output C:\runtime

# Runtime image
FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1809

COPY --from=installer-env ["C:\\runtime", "C:\\runtime"]

ENV AzureWebJobsScriptRoot=C:\approot

ENV WEBSITE_HOSTNAME=localhost:80

CMD ["dotnet", "C:\\runtime\\Microsoft.Azure.WebJobs.Script.WebHost.dll"]
