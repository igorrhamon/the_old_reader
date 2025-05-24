#!/bin/bash

# Cores para saída colorida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================================="
echo "           ORGANIZANDO ARQUIVOS DE PROXY"
echo -e "==========================================================${NC}"
echo

# Verifica se a pasta proxy existe, se não, cria
if [ ! -d "proxy" ]; then
    echo -e "${YELLOW}Criando pasta proxy...${NC}"
    mkdir proxy
fi

# Verifica se a pasta de logs existe, se não, cria
if [ ! -d "proxy/logs" ]; then
    echo -e "${YELLOW}Criando pasta de logs do proxy...${NC}"
    mkdir -p proxy/logs
fi

echo -e "${CYAN}Movendo arquivos para a pasta proxy...${NC}"

# Lista de arquivos a serem movidos
FILES_TO_MOVE=("proxy.js" "proxy-debug.js" "proxy-test.js" "test-quickadd.js" "check-port.js" "quickadd-diagnostics.js")

# Verifica e move cada arquivo
for file in "${FILES_TO_MOVE[@]}"; do
    if [ -f "$file" ]; then
        if [ ! -f "proxy/$file" ]; then
            echo -e "${GREEN}Movendo $file para a pasta proxy...${NC}"
            cp "$file" "proxy/$file"
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Arquivo $file copiado com sucesso.${NC}"
                rm "$file"
                echo -e "${GREEN}Arquivo original $file removido.${NC}"
            else
                echo -e "${RED}Falha ao copiar $file.${NC}"
            fi
        else
            echo -e "${YELLOW}Arquivo $file já existe na pasta proxy.${NC}"
        fi
    else
        echo -e "${YELLOW}Arquivo $file não encontrado.${NC}"
    fi
done

# Atualiza o arquivo package.json na pasta proxy
if [ -f "package.json" ]; then
    echo -e "${GREEN}Copiando package.json para a pasta proxy...${NC}"
    cp "package.json" "proxy/package.json"
    echo -e "${GREEN}Arquivo package.json copiado.${NC}"
fi

echo
echo -e "${BLUE}=========================================================="
echo "          ORGANIZAÇÃO DE ARQUIVOS CONCLUÍDA"
echo -e "==========================================================${NC}"
echo

echo -e "${GREEN}Os seguintes arquivos foram organizados:${NC}"
echo -e "${GREEN}- proxy.js, proxy-debug.js, proxy-test.js${NC}"
echo -e "${GREEN}- test-quickadd.js, check-port.js, quickadd-diagnostics.js${NC}"
echo
echo -e "${YELLOW}Verifique se todos os arquivos estão funcionando corretamente.${NC}"
echo

read -p "Pressione ENTER para continuar..."
