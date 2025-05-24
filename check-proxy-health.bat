@echo off
echo ==========================================================
echo             VERIFICANDO PROXY THE OLD READER
echo ==========================================================
echo.

cd proxy
node health-check.js
cd ..

echo.
echo Verificação concluída. Consulte o log em proxy\logs\health-check.log
echo.
pause
