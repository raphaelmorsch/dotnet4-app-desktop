#!/usr/bin/env bash
# Gera publish/net45/ com os binarios prontos para deploy na VM (sem compilar la).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$ROOT/CrudDesktop"
OUTPUT="$ROOT/CrudDesktop/bin/Release/net45"
PUBLISH="$ROOT/publish/net45"

echo "==> Compilando Release..."
cd "$PROJECT"
dotnet restore
dotnet build -c Release --no-restore

echo "==> Copiando para publish/net45..."
mkdir -p "$PUBLISH"
cp "$OUTPUT/CrudDesktop.exe" "$PUBLISH/"
cp "$OUTPUT/CrudDesktop.exe.config" "$PUBLISH/"
cp "$OUTPUT/Newtonsoft.Json.dll" "$PUBLISH/"

echo ""
echo "Binarios publicados em: $PUBLISH"
echo "Commit e push para a VM instalar via git clone + install.ps1"
