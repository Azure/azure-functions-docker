#ENTRY POINT MAIN()
Param(
    [Parameter(Mandatory=$True)]
    [String]
    $MajorVersion,

    [Parameter(Mandatory=$True)]
    [String]
    $FullVersion
)

if ($MajorVersion -ne "2.0" -And $MajorVersion -ne "3.0") {
    Write-Error "MajorVersion can only be 2.0 or 3.0. Got $MajorVersion" -ErrorAction Stop
}

$dockerFiles = Get-ChildItem  ./$MajorVersion/*DockerFile -rec
foreach ($f in $dockerFiles)
{
    $content = Get-Content $f.PSPath
    Write-Host "Updating version in $($f.PSPath) to $FullVersion"
    $content = $content -replace "HOST_VERSION=$MajorVersion\.(\d+)", "HOST_VERSION=$FullVersion"
    Set-Content -Path $f.PSPath -Value $content
}