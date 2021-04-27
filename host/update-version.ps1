#ENTRY POINT MAIN()
Param(
    [Parameter(Mandatory=$True)]
    [String]
    $MajorVersion,

    [Parameter(Mandatory=$True)]
    [String]
    $FullVersion
)

if ($MajorVersion -ne "2.0" -And $MajorVersion -ne "3.0" -AND $MajorVersion -ne "4.0") {
    Write-Error "MajorVersion can only be 2.0, 3.0, or 4.0. Got $MajorVersion" -ErrorAction Stop
}

function Update-HostVersion {
     param (
        $MajorVersion,
        $Directory
    )
    
    $dockerFiles = Get-ChildItem  ./$Directory/*DockerFile -rec
    foreach ($f in $dockerFiles)
    {
        $content = Get-Content $f.PSPath
        Write-Host "Updating version in $($f.PSPath) to $FullVersion"
        $newContent = ($content -replace "HOST_VERSION=$MajorVersion\.(\d+)", "HOST_VERSION=$FullVersion" -join "`n") + "`n"
        Set-Content -Path $f.PSPath -Value $newContent -NoNewline
    }
}

Update-HostVersion -MajorVersion $MajorVersion -Directory $MajorVersion

if ($MajorVersion -eq "3.0") {
    Write-Host "Updating auto-upgraded files"
    Update-HostVersion -MajorVersion $MajorVersion -Directory "2.0-upgrade"
}