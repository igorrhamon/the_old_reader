@echo off
echo ==========================================================
echo      INICIANDO THE OLD READER APP (WEB + PROXY)
echo ==========================================================
echo.

echo Verificando se as portas necessárias estão disponíveis...

REM Verifica a porta 3000 (proxy)
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

REM Verifica a porta 8000 (Flutter web)
FOR /F "tokens=5" %%P IN ('netstat -ano ^| findstr :8000 ^| findstr LISTENING') DO (
  echo Encontrado processo usando a porta 8000: %%P
  
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
echo Verificando dependências do proxy...
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
echo Iniciando o proxy em uma nova janela...
start "The Old Reader Proxy" cmd /c "node proxy.js"

echo.
echo Aguardando o proxy iniciar (3 segundos)...
timeout /t 3 /nobreak > nul

echo.
echo ==========================================================
echo      INICIANDO FLUTTER WEB NO MODO WEB-SERVER
echo ==========================================================
echo.
echo O aplicativo web estará disponível em:
echo   http://127.0.0.1:8000
echo.
echo Você pode acessar este endereço no seu navegador.
echo.
echo Pressione Ctrl+C para encerrar o servidor.
echo.

flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1

echo.
echo Encerrando o proxy...
taskkill /FI "WINDOWTITLE eq The Old Reader Proxy" /T /F > nul 2>&1
echo Aplicação encerrada.
