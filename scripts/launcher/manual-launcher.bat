@echo off
echo ==========================================================
echo          THE OLD READER - INICIALIZAÇÃO MANUAL
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

REM Executar o launcher manual
node manual-launcher.js

REM Se o script saiu com erro, pausar para mostrar a mensagem
if %ERRORLEVEL% neq 0 (
    echo.
    echo Ocorreu um erro ao iniciar o aplicativo.
    pause
    exit /b %ERRORLEVEL%
)

exit /b 0
