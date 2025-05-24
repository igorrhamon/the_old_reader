#!/bin/bash

# Cores para saída colorida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================================="
echo "            INICIANDO PROXY PARA THE OLD READER"
echo -e "==========================================================${NC}"
echo

# Verifica se a pasta proxy existe
if [ ! -d "proxy" ]; then
  echo -e "${YELLOW}Pasta proxy não encontrada. Execute organize-proxy-files.sh primeiro.${NC}"
  exit 1
fi

# Verifica se o node está instalado
if ! command -v node &> /dev/null; then
  echo -e "${RED}Node.js não encontrado. Por favor, instale o Node.js: https://nodejs.org/${NC}"
  exit 1
fi

# Verifica se a porta 3000 está em uso
PORT_CHECK=$(lsof -i:3000 -t)
if [ ! -z "$PORT_CHECK" ]; then
  echo -e "${YELLOW}A porta 3000 já está em uso pelo processo $PORT_CHECK.${NC}"
  
  read -p "Deseja encerrar este processo? (s/n): " KILL_PROCESS
  if [[ "$KILL_PROCESS" == "s" || "$KILL_PROCESS" == "S" ]]; then
    echo "Encerrando processo $PORT_CHECK..."
    kill -9 $PORT_CHECK
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}Processo encerrado com sucesso.${NC}"
    else
      echo -e "${RED}Falha ao encerrar o processo.${NC}"
      echo "Por favor, encerre o processo manualmente ou escolha outra porta."
      exit 1
    fi
  else
    echo "Operação cancelada pelo usuário."
    exit 1
  fi
fi

# Entra na pasta proxy
cd proxy

# Verifica dependências
echo "Verificando dependências..."
npm list express &> /dev/null
if [ $? -ne 0 ]; then
  echo "Instalando express..."
  npm install express
fi

npm list cors &> /dev/null
if [ $? -ne 0 ]; then
  echo "Instalando cors..."
  npm install cors
fi

npm list node-fetch &> /dev/null
if [ $? -ne 0 ]; then
  echo "Instalando node-fetch..."
  npm install node-fetch
fi

# Verifica pasta de logs
if [ ! -d "logs" ]; then
  echo "Criando pasta de logs..."
  mkdir logs
fi

echo
echo -e "${BLUE}=========================================================="
echo "               PROXY INICIADO NA PORTA 3000"
echo -e "==========================================================${NC}"
echo
echo -e "${GREEN}Use este proxy com o aplicativo Flutter para The Old Reader${NC}"
echo "O servidor está configurado para contornar restrições CORS"
echo "e corrigir problemas específicos com a API."
echo
echo "Para testar o endpoint quickadd, use:"
echo "  node test-quickadd.js SEU_TOKEN_AQUI URL_DO_FEED"
echo
echo "Pressione Ctrl+C para encerrar o servidor."
echo

# Inicia o proxy
node proxy.js

# Retorna à pasta original
cd ..
