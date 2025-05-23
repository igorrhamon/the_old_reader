@echo off
echo ==========================================================
echo             INICIANDO PROXY PARA THE OLD READER
echo ==========================================================
echo.

echo Verificando se o proxy já está em execução...
FOR /F "tokens=5" %%P IN ('netstat -ano ^| findstr :3000 ^| findstr LISTENING') DO (
  echo Encontrado processo usando a porta 3000: %%P
  
  choice /C SN /M "Deseja encerrar este processo? (S/N)"
  IF ERRORLEVEL 2 (
    echo Operação cancelada pelo usuário.
    exit /b 1
  )
  
  echo Terminando processo %%P...
  taskkill /F /PID %%P
  IF %ERRORLEVEL% EQU 0 (
    echo Processo terminado com sucesso.
  ) ELSE (
    echo Falha ao terminar processo.
    echo Por favor, encerre o processo manualmente ou escolha outra porta.
    exit /b 1
  )
)

echo.
echo Verificando dependências...
call npm list express >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
  echo Instalando express...
  call npm install express
)

call npm list cors >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
  echo Instalando cors...
  call npm install cors
)

call npm list node-fetch >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
  echo Instalando node-fetch...
  call npm install node-fetch
)

echo.
echo ==========================================================
echo               PROXY INICIADO NA PORTA 3000
echo ==========================================================
echo.
echo Use este proxy com o aplicativo Flutter para The Old Reader
echo O servidor está configurado para contornar restrições CORS
echo e corrigir problemas específicos com a API.
echo.
echo Para testar o endpoint quickadd, use:
echo   node test-quickadd.js SEU_TOKEN_AQUI URL_DO_FEED
echo.
echo Pressione Ctrl+C para encerrar o servidor.
echo.

node proxy.js

echo.
echo Servidor encerrado.
