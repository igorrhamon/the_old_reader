@echo off
echo ==========================================================
echo         THE OLD READER - DIRECT FLUTTER LAUNCHER
echo ==========================================================
echo.

set FLUTTER_PATH="C:\Users\igor-\sdk\flutter\bin\flutter.bat"

echo Executando Flutter diretamente...
%FLUTTER_PATH% run -d web-server --web-port 8000 --web-hostname 127.0.0.1

if %ERRORLEVEL% neq 0 (
    echo Ocorreu um erro ao executar o Flutter.
    echo Verifique se o Flutter esta corretamente instalado e configurado.
)

pause
