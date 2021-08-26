#ENTRY POINT MAIN()
Param(
    [Parameter(Mandatory=$False)]
    [String]
    $Suffix
)

$dockerFiles = Get-ChildItem -Path $PSScriptRoot -Filter ./*DockerFile -rec

$sdkSuffix = ""
$runtimeSuffix = ""

if ($Suffix)
{
    $sdkSuffix = ".100-$Suffix"
    $runtimeSuffix = ".0-$Suffix"
}

Write-Host "Updating all file 6.0 images with 'sdk:6.0$sdkSuffix' and 'runtime-deps:6.0$runtimeSuffix'"

foreach ($f in $dockerFiles)
{
    $content = Get-Content $f.PSPath
    Write-Host "  - updating $($f.Name)"
    $newContent = ($content -replace "sdk:6.(\S+)", "sdk:6.0$sdkSuffix" -replace "aspnet:6.(\S+)", "aspnet:6.0$runtimeSuffix" -replace "runtime:6.(\S+)", "runtime:6.0$runtimeSuffix"  -replace "runtime-deps:6.(\S+)", "runtime-deps:6.0$runtimeSuffix" -join "`n") + "`n"
    Set-Content -Path $f.PSPath -Value $newContent -NoNewline
}