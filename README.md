# CrudDesktop

Aplicação desktop de CRUD (Create, Read, Update, Delete) em **WinForms** com **.NET Framework 4.5**, compatível com **Windows Server 2012 R2**.

## Requisitos no Windows Server 2012 R2

- **.NET Framework 4.5** ou superior (já incluso no Server 2012 R2)
- Visual Studio 2019/2022 **ou** .NET SDK 6+ com MSBuild

> **Nota:** .NET 6/7/8+ **não** suporta Windows Server 2012 R2. Por isso este projeto usa .NET Framework 4.5.

## Funcionalidades

- Listagem de contatos em grade
- Criar, editar e excluir contatos
- Persistência em arquivo JSON em `%LocalAppData%\CrudDesktop\contatos.json`

## Compilar e executar (Windows)

```powershell
cd CrudDesktop
dotnet restore
dotnet build -c Release
dotnet run -c Release
```

Ou abra `CrudDesktop.sln` no Visual Studio e pressione F5.

O executável ficará em:

```
CrudDesktop\bin\Release\net45\CrudDesktop.exe
```

## Instalar na VM via Git (Windows Server 2012 R2)

Na VM você precisa apenas de **Git for Windows** e **.NET Framework 4.5** (já instalado).  
Não é necessário compilar na VM se a pasta `publish/net45/` estiver no repositório.

### 1. Preparar o repositório (no Mac/PC de desenvolvimento)

Gere os binários e envie para o Git:

```bash
./scripts/publish.sh
git add publish/net45
git commit -m "Publica binarios para deploy na VM"
git push
```

### 2. Na VM — instalação em um comando

Conecte via RDP e abra **PowerShell**:

```powershell
# Permitir execução de scripts (uma vez)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Clonar e instalar (substitua pela URL do seu repositório)
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/SEU-USUARIO/dotnet4-app-desktop/main/scripts/clone-and-install.ps1' -OutFile "$env:TEMP\clone-and-install.ps1"

& "$env:TEMP\clone-and-install.ps1" `
  -RepoUrl 'https://github.com/SEU-USUARIO/dotnet4-app-desktop.git' `
  -CreateShortcut
```

Ou, manualmente:

```powershell
git clone https://github.com/SEU-USUARIO/dotnet4-app-desktop.git C:\src\dotnet4-app-desktop
cd C:\src\dotnet4-app-desktop
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\scripts\install.ps1 -CreateShortcut
```

Isso copia os arquivos para `C:\Apps\CrudDesktop` e cria um atalho na área de trabalho.

### 3. Atualizar para uma versão nova

```powershell
cd C:\src\dotnet4-app-desktop
.\scripts\install.ps1 -CreateShortcut
```

O script faz `git pull` e reinstala automaticamente.

### Repositório privado

Para GitHub/GitLab privado, configure credenciais antes do clone:

```powershell
git config --global credential.helper wincred
git clone https://github.com/SEU-USUARIO/dotnet4-app-desktop.git
# Informe usuario + Personal Access Token quando solicitado
```

### Compilar na VM (opcional)

Só necessário se **não** usar `publish/net45/`. Instale [Visual Studio 2019 Build Tools](https://visualstudio.microsoft.com/downloads/) e rode:

```powershell
.\scripts\install.ps1 -ForceBuild -CreateShortcut
```

> O .NET SDK 6+ **não roda** no Windows Server 2012 R2. Por isso o fluxo recomendado é publicar os binários no Git a partir do Mac/PC.

## Estrutura do projeto

```
CrudDesktop/
├── Models/Contato.cs              # Entidade
├── Services/ContatoRepository.cs  # Persistência JSON
├── Forms/ContatoForm.cs           # Formulário de cadastro
├── MainForm.cs                    # Tela principal com grid
└── Program.cs                     # Ponto de entrada

scripts/
├── publish.sh / publish.ps1       # Gera publish/net45/ (dev)
├── install.ps1                    # Instala/atualiza na VM
└── clone-and-install.ps1          # Clone + install em um passo

publish/net45/                     # Binários prontos para a VM
```
