#!/bin/bash

# Cores para saída colorida
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================================="
echo "             GERENCIADOR DE LOGS PARA THE OLD READER"
echo -e "==========================================================${NC}"
echo

LOGS_DIR="proxy/logs"

# Criar diretório de logs se não existir
if [ ! -d "$LOGS_DIR" ]; then
  echo "Criando diretório de logs..."
  mkdir -p "$LOGS_DIR"
fi

# Função para mostrar o menu
show_menu() {
  echo "Menu de Gerenciamento de Logs:"
  echo
  echo "1. Visualizar logs do proxy"
  echo "2. Limpar logs do proxy"
  echo "3. Arquivar logs (salvar em ZIP)"
  echo "4. Sair"
  echo
  echo -n "Escolha uma opção [1-4]: "
  read option
  
  case $option in
    1) view_logs ;;
    2) clear_logs ;;
    3) archive_logs ;;
    4) exit 0 ;;
    *) echo -e "${RED}Opção inválida${NC}"; sleep 2; clear; show_menu ;;
  esac
}

# Função para visualizar logs
view_logs() {
  clear
  echo -e "${BLUE}=========================================================="
  echo "                   VISUALIZANDO LOGS"
  echo -e "==========================================================${NC}"
  echo
  
  if [ -f "$LOGS_DIR/proxy.log" ]; then
    echo "Conteúdo de proxy.log:"
    echo
    cat "$LOGS_DIR/proxy.log"
  else
    echo -e "${YELLOW}Arquivo de log não encontrado.${NC}"
  fi
  
  echo
  echo -n "Pressione ENTER para continuar..."
  read
  clear
  show_menu
}

# Função para limpar logs
clear_logs() {
  clear
  echo -e "${BLUE}=========================================================="
  echo "                   LIMPANDO LOGS"
  echo -e "==========================================================${NC}"
  echo
  
  echo -n "Tem certeza que deseja limpar os logs? (S/N): "
  read confirm
  
  if [[ "$confirm" == "S" || "$confirm" == "s" ]]; then
    echo "Limpando logs..."
    rm -f "$LOGS_DIR"/*.log
    echo -e "${GREEN}Logs foram limpos.${NC}"
  else
    echo "Operação cancelada."
  fi
  
  echo
  echo -n "Pressione ENTER para continuar..."
  read
  clear
  show_menu
}

# Função para arquivar logs
archive_logs() {
  clear
  echo -e "${BLUE}=========================================================="
  echo "                  ARQUIVANDO LOGS"
  echo -e "==========================================================${NC}"
  echo
  
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  ARCHIVE_NAME="proxy-logs-$TIMESTAMP.zip"
  
  echo "Criando arquivo $ARCHIVE_NAME..."
  
  if command -v zip > /dev/null; then
    zip -r "$ARCHIVE_NAME" "$LOGS_DIR"/*.log
    SUCCESS=$?
  else
    # Tenta usar outros métodos se zip não estiver disponível
    if command -v 7z > /dev/null; then
      7z a "$ARCHIVE_NAME" "$LOGS_DIR"/*.log
      SUCCESS=$?
    else
      tar -czf "${ARCHIVE_NAME/.zip/.tar.gz}" "$LOGS_DIR"/*.log
      SUCCESS=$?
      ARCHIVE_NAME="${ARCHIVE_NAME/.zip/.tar.gz}"
    fi
  fi
  
  if [ $SUCCESS -eq 0 ]; then
    echo -e "${GREEN}Logs foram arquivados com sucesso em $ARCHIVE_NAME${NC}"
  else
    echo -e "${RED}Ocorreu um erro ao arquivar os logs.${NC}"
  fi
  
  echo
  echo -n "Pressione ENTER para continuar..."
  read
  clear
  show_menu
}

# Iniciar programa
clear
show_menu
