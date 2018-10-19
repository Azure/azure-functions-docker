<#
    Installs node in a Docker image
#>

param (
    [Parameter(Mandatory = $true)]
    [String] $Version
)

$TempDir  = "$($env:temp)\\"
$NodeUrl = "https://nodejs.org/dist/v$($Version)/node-v$($Version)-win-x64.zip"
$NodeZipPath = "$($TempDir)node.zip"

Invoke-WebRequest -Uri $NodeUrl -OutFile $NodeZipPath

Write-Host "Installing node $($Version) "
try {
    Expand-Archive $NodeZipPath $TempDir -Force
    Copy-Item "$($TempDir)node-v$($Version)-win-x64" "C:\\Program Files\\nodejs" -Force -Recurse
}
finally {
    Remove-Item $NodeZipPath -Force -ErrorAction "SilentlyContinue"
    Remove-Item "$($TempDir)node-v$($Version)-win-x64" -Force -ErrorAction "SilentlyContinue" -Recurse
}
