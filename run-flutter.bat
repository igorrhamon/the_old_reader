@echo off
echo ==========================================================
echo          EXECUTANDO FLUTTER WEB
echo ==========================================================
echo.

node run-flutter.js

if %ERRORLEVEL% neq 0 (
    echo Ocorreu um erro ao executar o Flutter.
    pause
    exit /b 1
)

exit /b 0
