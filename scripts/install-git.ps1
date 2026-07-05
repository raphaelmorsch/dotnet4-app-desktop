# Instala Git for Windows via PowerShell (Windows Server 2012 R2+).
# Execute como Administrador:
#   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
#   .\scripts\install-git.ps1

param(
    [string]$Version = '2.47.1.windows.1',
    [string]$InstallerName = 'Git-2.47.1-64-bit.exe'
)

$ErrorActionPreference = 'Stop'

function Write-Step($Message) {
    Write-Host "==> $Message" -ForegroundColor Cyan
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning 'Recomendado executar como Administrador para instalar para todos os usuarios.'
}

Write-Step 'Habilitando TLS 1.2 (necessario no Server 2012 R2)...'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$downloadUrl = "https://github.com/git-for-windows/git/releases/download/v$Version/$InstallerName"
$installerPath = Join-Path $env:TEMP $InstallerName

Write-Step "Baixando Git de $downloadUrl ..."
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($downloadUrl, $installerPath)

Write-Step 'Instalando Git (modo silencioso)...'
$arguments = @(
    '/VERYSILENT'
    '/NORESTART'
    '/NOCancel'
    '/SP-'
    '/CLOSEAPPLICATIONS'
    '/RESTARTAPPLICATIONS'
    '/COMPONENTS=icons,ext\reg\shellhere,assoc,assoc_sh'
)

$process = Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    throw "Instalador do Git retornou codigo $($process.ExitCode)."
}

$gitExe = "${env:ProgramFiles}\Git\bin\git.exe"
if (-not (Test-Path $gitExe)) {
    throw "Git nao encontrado em $gitExe apos instalacao."
}

Write-Step 'Adicionando Git ao PATH da sessao atual...'
$gitBin = "${env:ProgramFiles}\Git\bin"
$gitCmd = "${env:ProgramFiles}\Git\cmd"
$env:Path = "$gitBin;$gitCmd;" + $env:Path

Write-Host ''
Write-Host 'Git instalado com sucesso.' -ForegroundColor Green
& $gitExe --version
Write-Host ''
Write-Host 'Feche e abra um novo PowerShell para o PATH permanente, ou execute:'
Write-Host "  `$env:Path = `"$gitBin;$gitCmd;`" + `$env:Path"
Write-Host ''
Write-Host 'Proximo passo (instalar CrudDesktop):'
Write-Host "  git clone https://github.com/SEU-USUARIO/dotnet4-app-desktop.git C:\src\dotnet4-app-desktop"
Write-Host '  cd C:\src\dotnet4-app-desktop'
Write-Host '  .\scripts\install.ps1 -CreateShortcut'
