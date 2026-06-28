@echo off
echo ==========================================================
echo           ORGANIZANDO ARQUIVOS DE PROXY
echo ==========================================================
echo.

REM Verifica se a pasta proxy existe, se não, cria
if not exist proxy (
  echo Criando pasta proxy...
  mkdir proxy
)

REM Verifica se a pasta de logs existe, se não, cria
if not exist proxy\logs (
  echo Criando pasta de logs do proxy...
  mkdir proxy\logs
)

echo Movendo arquivos para a pasta proxy...

REM Lista de arquivos a serem movidos
set FILES_TO_MOVE=proxy.js proxy-debug.js proxy-test.js test-quickadd.js check-port.js quickadd-diagnostics.js

REM Verifica e move cada arquivo
for %%F in (%FILES_TO_MOVE%) do (
  if exist %%F (
    if not exist proxy\%%F (
      echo Movendo %%F para a pasta proxy...
      copy %%F proxy\%%F
      if %ERRORLEVEL% EQU 0 (
        echo Arquivo %%F copiado com sucesso.
        del %%F
        echo Arquivo original %%F removido.
      ) else (
        echo Falha ao copiar %%F.
      )
    ) else (
      echo Arquivo %%F já existe na pasta proxy.
    )
  ) else (
    echo Arquivo %%F não encontrado.
  )
)

REM Atualiza o arquivo package.json na pasta proxy
if exist package.json (
  echo Copiando package.json para a pasta proxy...
  copy package.json proxy\package.json
  echo Arquivo package.json copiado.
)

echo.
echo ==========================================================
echo          ORGANIZAÇÃO DE ARQUIVOS CONCLUÍDA
echo ==========================================================
echo.

echo Os seguintes arquivos foram organizados:
echo - proxy.js, proxy-debug.js, proxy-test.js
echo - test-quickadd.js, check-port.js, quickadd-diagnostics.js
echo.
echo Verifique se todos os arquivos estão funcionando corretamente.
echo.
pause
