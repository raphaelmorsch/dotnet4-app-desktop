# Gera publish/net45/ com os binarios prontos para deploy na VM.
param(
    [string]$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$projectDir = Join-Path $RepoRoot 'CrudDesktop'
$outputDir = Join-Path $RepoRoot 'CrudDesktop\bin\Release\net45'
$publishDir = Join-Path $RepoRoot 'publish\net45'

Write-Host '==> Compilando Release...' -ForegroundColor Cyan
Push-Location $projectDir
try {
    dotnet restore
    dotnet build -c Release --no-restore
}
finally {
    Pop-Location
}

Write-Host '==> Copiando para publish/net45...' -ForegroundColor Cyan
New-Item -ItemType Directory -Path $publishDir -Force | Out-Null

$files = @('CrudDesktop.exe', 'CrudDesktop.exe.config', 'Newtonsoft.Json.dll')
foreach ($file in $files) {
    Copy-Item (Join-Path $outputDir $file) (Join-Path $publishDir $file) -Force
}

Write-Host ''
Write-Host "Binarios publicados em: $publishDir" -ForegroundColor Green
Write-Host 'Faca commit e push para a VM instalar via git clone + install.ps1'
