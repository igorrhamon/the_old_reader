@echo off
echo ==========================================================
echo          THE OLD READER - INICIAR APLICATIVO WEB
echo ==========================================================
echo.

REM Verificar se o Node.js está instalado
where node >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo Erro: Node.js não encontrado. Por favor, instale o Node.js.
    echo Download: https://nodejs.org/
    pause
    exit /b 1
)

REM Verificar se o Flutter está configurado
if not exist flutter-config.js (
    echo Configuração do Flutter não encontrada.
    
    REM Verificar se o Flutter está no PATH
    where flutter >nul 2>nul
    if %ERRORLEVEL% neq 0 (
        echo Flutter não encontrado no PATH.
        echo Executando verificador do Flutter...
        call check-flutter.bat
    ) else (
        echo Flutter encontrado no PATH. Criando configuração...
        echo module.exports = { flutterPath: "flutter" }; > flutter-config.js
        echo Configuração criada com sucesso.
    )
)

REM Iniciar o aplicativo
echo.
echo Iniciando o aplicativo The Old Reader...
echo.

node start-web-app.js

if %ERRORLEVEL% neq 0 (
    echo.
    echo Ocorreu um erro ao iniciar o aplicativo.
    echo.
    echo Se o erro está relacionado ao Flutter, tente:
    echo   1. .\fix-flutter-path.bat - para corrigir o caminho do Flutter
    echo   2. .\check-flutter.bat - para verificar a instalação do Flutter
    echo.
    pause
    exit /b %ERRORLEVEL%
)

exit /b 0
