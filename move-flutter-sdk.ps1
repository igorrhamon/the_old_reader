# Script para mover o Flutter SDK para o drive D:

# Parar todos os processos Flutter que possam estar rodando
taskkill /F /IM dart.exe /IM flutter.exe /IM pub.exe 2>$null

# Criar diretório de destino no drive D:
$destDir = "D:\sdk\flutter"
New-Item -ItemType Directory -Force -Path $destDir

# Copiar Flutter SDK para o novo local
Write-Host "Copiando Flutter SDK para $destDir..."
Copy-Item -Path "C:\Users\igor-\sdk\flutter\*" -Destination $destDir -Recurse -Force

# Atualizar a variável de ambiente PATH
$oldPath = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = $oldPath -replace "C:\\Users\\igor-\\sdk\\flutter\\bin", "D:\sdk\flutter\bin"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

# Criar arquivo .bat para atualizar PATH na sessão atual
@"
@echo off
set PATH=%PATH:C:\Users\igor-\sdk\flutter\bin=D:\sdk\flutter\bin%
"@ | Out-File -FilePath "update-path.bat" -Encoding ASCII

Write-Host "Flutter SDK foi movido para $destDir"
Write-Host "Execute 'update-path.bat' para atualizar o PATH na sessão atual do terminal"

# Remover o SDK antigo após confirmação
$response = Read-Host "Deseja remover o SDK antigo do drive C:? (S/N)"
if ($response -eq "S") {
    Remove-Item -Path "C:\Users\igor-\sdk\flutter" -Recurse -Force
    Write-Host "SDK antigo removido com sucesso"
}
