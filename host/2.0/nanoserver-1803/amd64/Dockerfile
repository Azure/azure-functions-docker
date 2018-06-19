# escape=`

# Installer image
FROM microsoft/windowsservercore:1803 AS installer-env

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Retrieve .NET Core SDK
ENV DOTNET_SDK_VERSION 2.1.301

RUN Invoke-WebRequest -OutFile dotnet.zip https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$Env:DOTNET_SDK_VERSION/dotnet-sdk-$Env:DOTNET_SDK_VERSION-win-x64.zip; `
    $dotnet_sha512 = 'f2f6cc020f89dc4d4f8064cc914cffabde0ce422715138778a6bcbbb6803ca66d6fd967097a0209c47c89b85dd9e93db48486ac86999bd3a533e45b789fcea89'; `
    if ((Get-FileHash dotnet.zip -Algorithm sha512).Hash -ne $dotnet_sha512) { `
        Write-Host 'CHECKSUM VERIFICATION FAILED!'; `
        exit 1; `
    }; `
    `
    Expand-Archive dotnet.zip -DestinationPath $Env:ProgramFiles\dotnet; `
    Remove-Item -Force dotnet.zip; `
    setx /M PATH $($Env:PATH + ';' + $Env:ProgramFiles + '\dotnet')


RUN New-Item -Type Directory warmup;; `
    cd warmup; `
    dotnet new; `
    cd .. ;`
    Remove-Item -Force -Recurse warmup

ENV PublishWithAspNetCoreTargetManifest false
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; `
    iwr https://github.com/Azure/azure-webjobs-sdk-script/archive/dev.zip -OutFile dev.zip; `
    Expand-Archive dev.zip .; `
    cd azure-functions-host-dev; `
    dotnet restore WebJobs.Script.sln; `
    mkdir src\WebJobs.Script.Grpc\Messages\DotNet; `
    pwd; `
    cd src\WebJobs.Script.Grpc; `
    Invoke-Command -ScriptBlock {cmd /c '%UserProfile%\.nuget\packages\grpc.tools\1.12.0\tools\windows_x64\protoc.exe Proto\FunctionRpc.proto --csharp_out Messages\DotNet --grpc_out=Messages\DotNet --plugin=protoc-gen-grpc="%UserProfile%\.nuget\packages\grpc.tools\1.4.1\tools\windows_x64\grpc_csharp_plugin.exe" --proto_path=Proto'}; `
    cd ..\.. ; `
    dotnet build WebJobs.Script.sln; `
    dotnet publish src\WebJobs.Script.WebHost\WebJobs.Script.WebHost.csproj --output C:\runtime

# Runtime image
FROM microsoft/dotnet:2.1-aspnetcore-runtime-nanoserver-1803

COPY --from=installer-env ["c:\\runtime", "C:\\runtime"]

ENV AzureWebJobsScriptRoot=C:\approot

ENV WEBSITE_HOSTNAME=localhost:80

CMD ["dotnet", "C:\\runtime\\Microsoft.Azure.WebJobs.Script.WebHost.dll"]
