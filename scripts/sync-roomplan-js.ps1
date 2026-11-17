param(
    [string]$SourceDir = (Join-Path $PSScriptRoot '..\..\apex_plugin_roomplan_js\dist'),
    [string]$DestinationDir = (Join-Path $PSScriptRoot '..\src\js')
)

$resolvedSourceDir = [System.IO.Path]::GetFullPath($SourceDir)
$excludedTypesDir = Join-Path $resolvedSourceDir 'types'

if (-not (Test-Path -LiteralPath $resolvedSourceDir)) {
    throw "Source directory not found: $resolvedSourceDir"
}

$sourceFiles = Get-ChildItem -LiteralPath $resolvedSourceDir -Recurse -File |
    Where-Object { $_.FullName -notlike "$excludedTypesDir\*" }

if (-not $sourceFiles) {
    throw "No distribution files found in: $resolvedSourceDir"
}

$resolvedDestinationDir = [System.IO.Path]::GetFullPath($DestinationDir)

if (Test-Path -LiteralPath $resolvedDestinationDir) {
    Get-ChildItem -LiteralPath $resolvedDestinationDir -Force | Remove-Item -Recurse -Force
}

New-Item -ItemType Directory -Path $resolvedDestinationDir -Force | Out-Null

foreach ($sourceFile in $sourceFiles) {
    $relativePath = $sourceFile.FullName.Substring($resolvedSourceDir.Length).TrimStart('\', '/')
    $destinationPath = Join-Path $resolvedDestinationDir $relativePath
    $destinationDirectory = Split-Path -Path $destinationPath -Parent

    if (-not (Test-Path -LiteralPath $destinationDirectory)) {
        New-Item -ItemType Directory -Path $destinationDirectory -Force | Out-Null
    }

    Copy-Item -LiteralPath $sourceFile.FullName -Destination $destinationPath -Force
}

Write-Host "Synced $($sourceFiles.Count) file(s) from $resolvedSourceDir to $resolvedDestinationDir"