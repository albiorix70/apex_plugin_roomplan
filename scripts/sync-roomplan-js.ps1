param(
    [string]$SourceDir = (Join-Path $PSScriptRoot '..\apex_plugin_roomplan_js\dist'),
    [string]$DestinationFile = (Join-Path $PSScriptRoot '..\assets\roomplan.js')
)

$resolvedSourceDir = [System.IO.Path]::GetFullPath($SourceDir)

if (-not (Test-Path -LiteralPath $resolvedSourceDir)) {
    throw "Source directory not found: $resolvedSourceDir"
}

$sourceFile = Get-ChildItem -LiteralPath $resolvedSourceDir -Filter '*.js' -File |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $sourceFile) {
    throw "No JavaScript bundle found in: $resolvedSourceDir"
}

$destinationPath = [System.IO.Path]::GetFullPath($DestinationFile)
$destinationDirectory = Split-Path -Path $destinationPath -Parent

if (-not (Test-Path -LiteralPath $destinationDirectory)) {
    New-Item -ItemType Directory -Path $destinationDirectory | Out-Null
}

Copy-Item -LiteralPath $sourceFile.FullName -Destination $destinationPath -Force

Write-Host "Copied $($sourceFile.Name) to $destinationPath"