@echo off
echo Corrigindo o caminho do Flutter para The Old Reader...
node flutter-path-fixer.js
if %ERRORLEVEL% neq 0 (
    echo Ocorreu um erro ao corrigir o caminho do Flutter.
    pause
    exit /b 1
)
echo.
echo O caminho do Flutter foi configurado com sucesso!
echo Agora você pode executar o app web com:
echo   .\run-web-app.bat
echo.
pause
