# Clona o repositorio Git e instala o CrudDesktop.
# Execute na VM via PowerShell (como Administrador, se instalar em C:\Apps).
#
# Uso:
#   .\clone-and-install.ps1 -RepoUrl 'https://github.com/SEU-USUARIO/dotnet4-app-desktop.git'
#   .\clone-and-install.ps1 -RepoUrl 'https://github.com/SEU-USUARIO/dotnet4-app-desktop.git' -ClonePath 'C:\src\CrudDesktop'

param(
    [Parameter(Mandatory = $true)]
    [string]$RepoUrl,

    [string]$ClonePath = 'C:\src\dotnet4-app-desktop',
    [string]$InstallPath = 'C:\Apps\CrudDesktop',
    [string]$Branch = 'main',
    [switch]$CreateShortcut
)

$ErrorActionPreference = 'Stop'

function Write-Step($Message) {
    Write-Host "==> $Message" -ForegroundColor Cyan
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw @"
Git nao encontrado.

Instale Git for Windows na VM:
  1. Baixe em https://git-scm.com/download/win
  2. Use as opcoes padrao do instalador
  3. Abra um novo PowerShell e execute este script novamente
"@
}

Write-Step "Preparando diretorio $ClonePath..."
$parent = Split-Path $ClonePath -Parent
if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
}

if (Test-Path $ClonePath) {
    Write-Step "Diretorio ja existe. Atualizando..."
    Set-Location $ClonePath
    git fetch origin
    git checkout $Branch
    git pull origin $Branch
}
else {
    Write-Step "Clonando $RepoUrl..."
    git clone --branch $Branch $RepoUrl $ClonePath
    Set-Location $ClonePath
}

$installScript = Join-Path $ClonePath 'scripts\install.ps1'
if (-not (Test-Path $installScript)) {
    throw "Script install.ps1 nao encontrado em $installScript"
}

Write-Step 'Executando instalacao...'
& $installScript -InstallPath $InstallPath -CreateShortcut:$CreateShortcut -SkipPull

Write-Host ''
Write-Host 'Pronto. Para atualizar depois:' -ForegroundColor Green
Write-Host "  cd $ClonePath"
Write-Host '  .\scripts\install.ps1 -CreateShortcut'
