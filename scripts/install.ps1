# Instala ou atualiza CrudDesktop a partir de um clone Git local.
# Uso:
#   .\scripts\install.ps1
#   .\scripts\install.ps1 -InstallPath 'D:\Apps\CrudDesktop' -CreateShortcut

param(
    [string]$InstallPath = 'C:\Apps\CrudDesktop',
    [switch]$CreateShortcut,
    [switch]$ForceBuild,
    [switch]$SkipPull
)

$ErrorActionPreference = 'Stop'

function Write-Step($Message) {
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Get-RepoRoot {
    $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    return (Resolve-Path (Join-Path $scriptDir '..')).Path
}

function Find-MsBuild {
    $paths = @(
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Professional\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\Enterprise\MSBuild\Current\Bin\MSBuild.exe",
        "${env:ProgramFiles(x86)}\MSBuild\14.0\Bin\MSBuild.exe"
    )

    foreach ($path in $paths) {
        if (Test-Path $path) { return $path }
    }

    return $null
}

function Find-DotNet {
    $cmd = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

function Invoke-BuildProject {
    param(
        [string]$RepoRoot
    )

    $project = Join-Path $RepoRoot 'CrudDesktop\CrudDesktop.csproj'
    $output = Join-Path $RepoRoot 'CrudDesktop\bin\Release\net45'

    $dotnet = Find-DotNet
    if ($dotnet) {
        Write-Step "Compilando com dotnet..."
        Push-Location (Join-Path $RepoRoot 'CrudDesktop')
        try {
            & $dotnet restore
            & $dotnet build -c Release --no-restore
        }
        finally {
            Pop-Location
        }
        return $output
    }

    $msbuild = Find-MsBuild
    if ($msbuild) {
        Write-Step "Compilando com MSBuild..."
        & $msbuild $project /p:Configuration=Release /t:Restore,Build /v:minimal
        return $output
    }

    return $null
}

function Get-PublishSource {
    param(
        [string]$RepoRoot
    )

    $publishDir = Join-Path $RepoRoot 'publish\net45'
    if (Test-Path (Join-Path $publishDir 'CrudDesktop.exe')) {
        return $publishDir
    }

    return $null
}

function Install-FromSource {
    param(
        [string]$SourceDir,
        [string]$TargetDir
    )

    $files = @('CrudDesktop.exe', 'CrudDesktop.exe.config', 'Newtonsoft.Json.dll')
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

    foreach ($file in $files) {
        $source = Join-Path $SourceDir $file
        if (-not (Test-Path $source)) {
            throw "Arquivo obrigatorio nao encontrado: $source"
        }
        Copy-Item $source (Join-Path $TargetDir $file) -Force
    }
}

function New-DesktopShortcut {
    param(
        [string]$TargetExe
    )

    $shortcutPath = Join-Path $env:Public 'Desktop\CrudDesktop.lnk'
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $TargetExe
    $shortcut.WorkingDirectory = Split-Path $TargetExe -Parent
    $shortcut.Save()
    Write-Step "Atalho criado: $shortcutPath"
}

Write-Step 'CrudDesktop - instalacao via Git'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git nao encontrado. Instale Git for Windows: https://git-scm.com/download/win'
}

$repoRoot = Get-RepoRoot
Set-Location $repoRoot

if (-not $SkipPull) {
    if (Test-Path (Join-Path $repoRoot '.git')) {
        Write-Step "Atualizando repositorio (git pull)..."
        git pull
    }
}

$sourceDir = $null

if ($ForceBuild) {
    $sourceDir = Invoke-BuildProject -RepoRoot $repoRoot
    if (-not $sourceDir -or -not (Test-Path (Join-Path $sourceDir 'CrudDesktop.exe'))) {
        throw 'Falha ao compilar. Instale Visual Studio 2019 Build Tools ou use publish/net45 no repositorio.'
    }
}
else {
    $sourceDir = Invoke-BuildProject -RepoRoot $repoRoot
    if (-not $sourceDir -or -not (Test-Path (Join-Path $sourceDir 'CrudDesktop.exe'))) {
        Write-Host 'Compilacao local indisponivel ou falhou. Usando publish/net45...' -ForegroundColor Yellow
        $sourceDir = Get-PublishSource -RepoRoot $repoRoot
    }
}

if (-not $sourceDir) {
    throw @"
Nao foi possivel obter os binarios.

Opcoes:
  1. No seu Mac/PC de desenvolvimento, rode scripts/publish.sh e faca commit da pasta publish/net45
  2. Na VM, instale Visual Studio 2019 Build Tools e rode: .\scripts\install.ps1 -ForceBuild
  3. Instale .NET SDK (se compativel) e rode: .\scripts\install.ps1 -ForceBuild
"@
}

Write-Step "Instalando em $InstallPath..."
Install-FromSource -SourceDir $sourceDir -TargetDir $InstallPath

if ($CreateShortcut) {
    New-DesktopShortcut -TargetExe (Join-Path $InstallPath 'CrudDesktop.exe')
}

Write-Host ''
Write-Host 'Instalacao concluida.' -ForegroundColor Green
Write-Host "Executavel: $(Join-Path $InstallPath 'CrudDesktop.exe')"
Write-Host ''
Write-Host 'Para atualizar no futuro:'
Write-Host "  cd $repoRoot"
Write-Host '  .\scripts\install.ps1 -CreateShortcut'
