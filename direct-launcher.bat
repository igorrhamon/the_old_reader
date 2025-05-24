@echo off
echo ==========================================================
echo          THE OLD READER - DIRECT LAUNCHER
echo ==========================================================
echo.

node direct-launcher.js

if %ERRORLEVEL% neq 0 (
    echo Ocorreu um erro ao executar a aplicacao.
    echo Verifique se o Flutter esta corretamente instalado e configurado.
    pause
    exit /b %ERRORLEVEL%
)

pause
