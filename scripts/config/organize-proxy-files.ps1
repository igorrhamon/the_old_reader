# Organizar arquivos de proxy
Write-Host "==========================================================" -ForegroundColor Blue
Write-Host "           ORGANIZANDO ARQUIVOS DE PROXY" -ForegroundColor Blue
Write-Host "==========================================================" -ForegroundColor Blue
Write-Host ""

# Verifica se a pasta proxy existe, se não, cria
if (-not (Test-Path -Path "proxy")) {
    Write-Host "Criando pasta proxy..." -ForegroundColor Yellow
    New-Item -Path "proxy" -ItemType Directory
}

# Verifica se a pasta de logs existe, se não, cria
if (-not (Test-Path -Path "proxy\logs")) {
    Write-Host "Criando pasta de logs do proxy..." -ForegroundColor Yellow
    New-Item -Path "proxy\logs" -ItemType Directory
}

Write-Host "Movendo arquivos para a pasta proxy..." -ForegroundColor Cyan

# Lista de arquivos a serem movidos
$filesToMove = @("proxy.js", "proxy-debug.js", "proxy-test.js", "test-quickadd.js", "check-port.js", "quickadd-diagnostics.js")

# Verifica e move cada arquivo
foreach ($file in $filesToMove) {
    if (Test-Path -Path $file) {
        if (-not (Test-Path -Path "proxy\$file")) {
            Write-Host "Movendo $file para a pasta proxy..." -ForegroundColor Green
            Copy-Item -Path $file -Destination "proxy\$file"
            if ($?) {
                Write-Host "Arquivo $file copiado com sucesso." -ForegroundColor Green
                Remove-Item -Path $file
                Write-Host "Arquivo original $file removido." -ForegroundColor Green
            } else {
                Write-Host "Falha ao copiar $file." -ForegroundColor Red
            }
        } else {
            Write-Host "Arquivo $file já existe na pasta proxy." -ForegroundColor Yellow
        }
    } else {
        Write-Host "Arquivo $file não encontrado." -ForegroundColor Yellow
    }
}

# Atualiza o arquivo package.json na pasta proxy
if (Test-Path -Path "package.json") {
    Write-Host "Copiando package.json para a pasta proxy..." -ForegroundColor Green
    Copy-Item -Path "package.json" -Destination "proxy\package.json"
    Write-Host "Arquivo package.json copiado." -ForegroundColor Green
}

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Blue
Write-Host "          ORGANIZAÇÃO DE ARQUIVOS CONCLUÍDA" -ForegroundColor Blue
Write-Host "==========================================================" -ForegroundColor Blue
Write-Host ""

Write-Host "Os seguintes arquivos foram organizados:" -ForegroundColor Green
Write-Host "- proxy.js, proxy-debug.js, proxy-test.js" -ForegroundColor Green
Write-Host "- test-quickadd.js, check-port.js, quickadd-diagnostics.js" -ForegroundColor Green
Write-Host ""
Write-Host "Verifique se todos os arquivos estão funcionando corretamente." -ForegroundColor Yellow
Write-Host ""

Write-Host "Pressione qualquer tecla para continuar..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
