# Documentação do Servidor Proxy para The Old Reader

Este servidor proxy foi desenvolvido para facilitar o acesso à API do The Old Reader a partir de aplicativos Flutter, especialmente na versão web, onde restrições de CORS podem impedir requisições diretas.

## Estrutura de Arquivos

Os arquivos do proxy estão organizados na pasta `proxy/`:

- `proxy.js` - Servidor proxy principal
- `proxy-debug.js` - Versão com logs detalhados para depuração
- `proxy-test.js` - Versão simplificada para testes
- `test-quickadd.js` - Script para testar a funcionalidade de adicionar feeds
- `check-port.js` - Utilitário para verificar disponibilidade de portas
- `quickadd-diagnostics.js` - Ferramenta de diagnóstico para o endpoint quickadd
- `config.json` - Arquivo de configuração do proxy
- `logs/` - Diretório onde os logs são armazenados

## Configuração

As configurações do proxy estão no arquivo `config.json`:

```json
{
  "proxyPort": 3000,
  "logLevel": "info",
  "logDirectory": "logs",
  "enableCors": true,
  "enableCompression": true,
  "oldReaderUrl": "https://theoldreader.com/reader/api/0",
  "requestTimeout": 30000
}
```

Parâmetros disponíveis:

| Parâmetro | Descrição | Valor Padrão |
|-----------|-----------|--------------|
| proxyPort | Porta onde o servidor proxy vai rodar | 3000 |
| logLevel | Nível de detalhamento dos logs (error, warn, info, debug) | info |
| logDirectory | Diretório onde os logs serão salvos | logs |
| enableCors | Habilita suporte a CORS | true |
| enableCompression | Habilita compressão de respostas | true |
| oldReaderUrl | URL base da API do The Old Reader | https://theoldreader.com/reader/api/0 |
| requestTimeout | Timeout das requisições em milissegundos | 30000 |

## Endpoints Suportados

O proxy suporta todos os endpoints da API do The Old Reader, encaminhando as requisições para a API oficial e retornando as respostas para o cliente.

### Endpoints Principais

- **Autenticação**: `/reader/api/0/accounts/ClientLogin`
- **Informações do Usuário**: `/reader/api/0/user-info`
- **Lista de Assinaturas**: `/reader/api/0/subscription/list`
- **Contagem de Não Lidos**: `/reader/api/0/unread-count`
- **Adicionar Assinatura**: `/reader/api/0/subscription/quickadd`
- **Conteúdo de Feeds**: `/reader/api/0/stream/contents/...`
- **Itens Favoritos**: `/reader/api/0/stream/contents/user/-/state/com.google/starred`

## Funcionalidades Especiais

O proxy implementa algumas melhorias em relação à API original:

1. **Correção de CORS**: Adiciona os headers necessários para permitir requisições de diferentes origens.
2. **Correção do Endpoint Quickadd**: Garante que o parâmetro `quickadd` seja enviado corretamente na URL.
3. **Logs Detalhados**: Registra todas as requisições e respostas para facilitar depuração.
4. **Tratamento de Erros**: Captura e registra erros, fornecendo mensagens claras ao cliente.

## Scripts de Execução

Para iniciar o servidor proxy, você pode usar:

- **Windows**: `start-proxy.bat` ou `start-proxy.ps1`
- **Linux/Mac**: Execute `node proxy/proxy.js` diretamente

## Gerenciamento de Logs

Para gerenciar os logs do proxy, use:

- **Windows**: `manage-logs.bat`
- **Linux/Mac**: `./manage-logs.sh`

Este script permite visualizar, limpar e arquivar os logs do servidor proxy.

## Solução de Problemas

Se você encontrar problemas com o proxy:

1. **Verifique os logs**: Os arquivos de log na pasta `proxy/logs` contêm informações detalhadas.
2. **Teste a conexão**: Verifique se consegue acessar `http://localhost:3000` diretamente.
3. **Conflitos de porta**: Se a porta 3000 já estiver em uso, o proxy tentará uma porta alternativa.
4. **Verifique as dependências**: Execute `npm install` na pasta `proxy` para garantir que todas as dependências estejam instaladas.
