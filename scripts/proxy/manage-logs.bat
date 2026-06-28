@echo off
echo ==========================================================
echo             GERENCIADOR DE LOGS PARA THE OLD READER
echo ==========================================================
echo.

set LOGS_DIR=proxy\logs

if not exist %LOGS_DIR% (
  echo Criando diretório de logs...
  mkdir %LOGS_DIR%
)

echo Menu de Gerenciamento de Logs:
echo.
echo 1. Visualizar logs do proxy
echo 2. Limpar logs do proxy
echo 3. Arquivar logs (salvar em ZIP)
echo 4. Sair
echo.

choice /C 1234 /M "Escolha uma opção"

if %ERRORLEVEL% == 1 (
  cls
  echo ==========================================================
  echo                   VISUALIZANDO LOGS
  echo ==========================================================
  echo.
  
  if exist %LOGS_DIR%\proxy.log (
    echo Conteúdo de proxy.log:
    echo.
    type %LOGS_DIR%\proxy.log
  ) else (
    echo Arquivo de log não encontrado.
  )
  
  echo.
  pause
  %0
)

if %ERRORLEVEL% == 2 (
  cls
  echo ==========================================================
  echo                   LIMPANDO LOGS
  echo ==========================================================
  echo.
  
  choice /C SN /M "Tem certeza que deseja limpar os logs? (S/N)"
  if %ERRORLEVEL% == 1 (
    echo Limpando logs...
    del /Q %LOGS_DIR%\*.log
    echo Logs foram limpos.
  ) else (
    echo Operação cancelada.
  )
  
  echo.
  pause
  %0
)

if %ERRORLEVEL% == 3 (
  cls
  echo ==========================================================
  echo                  ARQUIVANDO LOGS
  echo ==========================================================
  echo.
  
  set TIMESTAMP=%date:~6,4%-%date:~3,2%-%date:~0,2%_%time:~0,2%-%time:~3,2%
  set TIMESTAMP=%TIMESTAMP: =0%
  set ARCHIVE_NAME=proxy-logs-%TIMESTAMP%.zip
  
  echo Criando arquivo %ARCHIVE_NAME%...
  
  if exist "C:\Program Files\7-Zip\7z.exe" (
    "C:\Program Files\7-Zip\7z.exe" a -tzip %ARCHIVE_NAME% %LOGS_DIR%\*.log
  ) else (
    powershell -Command "Compress-Archive -Path %LOGS_DIR%\*.log -DestinationPath %ARCHIVE_NAME% -Force"
  )
  
  if %ERRORLEVEL% == 0 (
    echo Logs foram arquivados com sucesso em %ARCHIVE_NAME%
  ) else (
    echo Ocorreu um erro ao arquivar os logs.
  )
  
  echo.
  pause
  %0
)

if %ERRORLEVEL% == 4 (
  exit /b
)
