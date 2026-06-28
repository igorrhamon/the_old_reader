#!/bin/bash

# Cores para saída colorida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================================="
echo "             VERIFICANDO PROXY THE OLD READER"
echo -e "==========================================================${NC}"
echo

cd proxy
node health-check.js
cd ..

echo
echo -e "${GREEN}Verificação concluída. Consulte o log em proxy/logs/health-check.log${NC}"
echo

read -p "Pressione ENTER para continuar..."
