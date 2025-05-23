# Verifica se o npm está instalado
$npmExists = Get-Command npm -ErrorAction SilentlyContinue
if (-not $npmExists) {
    Write-Host "NPM não encontrado. Por favor, instale o Node.js: https://nodejs.org/"
    exit 1
}

# Verifica dependências
Write-Host "Verificando dependências..."
$packageJsonExists = Test-Path -Path "package.json"
if (-not $packageJsonExists) {
    Write-Host "Criando package.json..."
    "
{
  `"name`": `"the-old-reader-proxy`",
  `"version`": `"1.0.0`",
  `"description`": `"Proxy for The Old Reader API`",
  `"main`": `"proxy.js`",
  `"scripts`": {
    `"start`": `"node proxy.js`",
    `"check-port`": `"node check-port.js`",
    `"debug`": `"node proxy-debug.js`"
  },
  `"dependencies`": {
    `"cors`": `"^2.8.5`",
    `"express`": `"^4.18.2`",
    `"node-fetch`": `"^2.6.7`"
  }
}
" | Out-File -FilePath "package.json" -Encoding utf8
}

# Instala dependências
Write-Host "Instalando dependências..."
npm install

# Verifica se a porta está disponível
Write-Host "Verificando disponibilidade da porta 3000..."
node check-port.js

# Pergunta se o usuário deseja iniciar o proxy
$startProxy = Read-Host "Deseja iniciar o proxy agora? (S/N)"
if ($startProxy -eq "S" -or $startProxy -eq "s") {
    Write-Host "Iniciando proxy..."
    node proxy.js
} else {
    Write-Host "Para iniciar o proxy manualmente, execute: node proxy.js"
}
