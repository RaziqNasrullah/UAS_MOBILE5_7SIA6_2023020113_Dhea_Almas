# Membuat ZIP source code NeoLearn tanpa folder build & cache (Windows PowerShell).
# Pemakaian (di folder proyek):  powershell -ExecutionPolicy Bypass -File scripts\zip_source.ps1
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$out = Join-Path $root "NeoLearn_source_2023020113.zip"
if (Test-Path $out) { Remove-Item $out }

$excludeDirs = @("build", ".dart_tool", ".idea", ".gradle", ".git")
$excludeFiles = @("local.properties", "NeoLearn_source_2023020113.zip")

$files = Get-ChildItem -Path $root -Recurse -File -Force | Where-Object {
    $rel = $_.FullName.Substring($root.Length + 1)
    $parts = $rel -split '[\\/]'
    -not ($parts | Where-Object { $excludeDirs -contains $_ }) -and
    -not ($excludeFiles -contains $_.Name) -and
    -not ($_.Extension -eq ".iml")
}

$staging = Join-Path $env:TEMP ("neolearn_zip_" + [guid]::NewGuid())
foreach ($f in $files) {
    $rel = $f.FullName.Substring($root.Length + 1)
    $dest = Join-Path $staging $rel
    New-Item -ItemType Directory -Force -Path (Split-Path $dest) | Out-Null
    Copy-Item $f.FullName $dest
}
Compress-Archive -Path (Join-Path $staging "*") -DestinationPath $out
Remove-Item $staging -Recurse -Force
Write-Host "Selesai: $out"
