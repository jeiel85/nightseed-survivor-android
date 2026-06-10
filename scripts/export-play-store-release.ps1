# Export Play Store release artifacts to Desktop\Build\ (flat layout).
#
# Usage:
#   .\scripts\export-play-store-release.ps1 -Version 0.35.0 -VersionCode 40 `
#       [-AabPath <path>] [-MappingPath <path>]
#
# - Validates play_store/release_notes/v<Version>.txt against the Play Console
#   500-chars-per-locale hard limit BEFORE anything reaches the desktop.
# - When -AabPath / -MappingPath are omitted, downloads them from the GitHub
#   Release for tag v<Version> via `gh release download` (CI artifacts).
param(
    [Parameter(Mandatory = $true)][string]$Version,
    [Parameter(Mandatory = $true)][int]$VersionCode,
    [string]$AabPath = "",
    [string]$MappingPath = ""
)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$stem = "nightseed-survivor-v$Version-vc$VersionCode"

$notesFile = Join-Path $repoRoot "play_store\release_notes\v$Version.txt"
if (-not (Test-Path $notesFile)) { throw "Release notes not found: $notesFile" }
$notesContent = Get-Content $notesFile -Raw -Encoding UTF8

# Play Console hard limit: 500 Unicode chars per locale block (excluding tags).
# Over-limit text is silently truncated by Play Console — abort export instead
# of letting a bad file reach the desktop.
$localePattern = '<(ko-KR|en-US|ja-JP|zh-CN|zh-TW)>([\s\S]*?)</\1>'
$violations = @()
foreach ($match in [regex]::Matches($notesContent, $localePattern)) {
    $locale = $match.Groups[1].Value
    $body = $match.Groups[2].Value.Trim()
    $len = $body.Length
    $status = if ($len -gt 500) { 'OVER' } else { 'OK' }
    Write-Host ("  {0,-7}  {1,4} / 500  {2}" -f $locale, $len, $status)
    if ($len -gt 500) {
        $violations += "$locale ($len chars, $($len - 500) over)"
    }
}
if ($violations.Count -gt 0) {
    throw "Play Console release notes exceed the 500-character limit per locale: " +
        ($violations -join ', ') +
        ". Trim before exporting."
}

# Resolve AAB / mapping — download CI artifacts when paths not supplied.
$tmpDl = Join-Path $env:TEMP "nightseed-release-v$Version"
if ($AabPath -eq "" -or $MappingPath -eq "") {
    New-Item -ItemType Directory -Force -Path $tmpDl | Out-Null
    gh release download "v$Version" --repo jeiel85/nightseed-survivor `
        --pattern 'nightseed-survivor-release.aab' `
        --pattern 'nightseed-survivor-release.mapping.txt' `
        --dir $tmpDl --clobber
    if ($AabPath -eq "")     { $AabPath     = Join-Path $tmpDl 'nightseed-survivor-release.aab' }
    if ($MappingPath -eq "") { $MappingPath = Join-Path $tmpDl 'nightseed-survivor-release.mapping.txt' }
}
if (-not (Test-Path $AabPath)) { throw "AAB not found: $AabPath" }

$desktop  = [Environment]::GetFolderPath('Desktop')   # OneDrive-redirect aware
$buildDir = Join-Path $desktop 'Build'
New-Item -ItemType Directory -Force -Path $buildDir | Out-Null

Copy-Item $AabPath   (Join-Path $buildDir "$stem.aab") -Force
Copy-Item $notesFile (Join-Path $buildDir "$stem-release-notes.txt") -Force
if ($MappingPath -ne "" -and (Test-Path $MappingPath)) {
    # Play Console deobfuscation file — upload alongside the AAB (project CLAUDE.md, R8 section).
    Copy-Item $MappingPath (Join-Path $buildDir "$stem-mapping.txt") -Force
}

Get-ChildItem $buildDir -Filter "$stem*" | ForEach-Object {
    Write-Host ("  -> {0}  ({1:N0} bytes)" -f $_.Name, $_.Length)
}
Write-Host "Export complete: $buildDir"
