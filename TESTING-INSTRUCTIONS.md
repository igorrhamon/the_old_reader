# Instruções para testar o Proxy com a correção do quickadd

Este documento fornece instruções para testar a correção implementada no proxy para o endpoint `subscription/quickadd` da API do The Old Reader.

## Problema

O endpoint de adição de feeds da API do The Old Reader requer que o parâmetro `quickadd` seja enviado na URL como query string, não no corpo (body) da requisição. Isso é diferente do comportamento padrão de outros endpoints da API.

Exemplo correto: `POST https://theoldreader.com/reader/api/0/subscription/quickadd?quickadd=https://blog.theoldreader.com/rss`

O bug estava no proxy, que não estava passando corretamente este parâmetro ao encaminhar as requisições para a API.

## Solução Implementada

A correção implementada no `proxy.js` garante que:

1. O parâmetro `quickadd` seja preservado na URL ao encaminhar a requisição para a API
2. Se o parâmetro estiver no corpo da requisição, ele é movido para a URL
3. Logs detalhados são gerados para facilitar o diagnóstico

## Como Testar a Correção

### Passo 1: Iniciar o Proxy

```powershell
# Inicie o proxy em um terminal
node proxy.js
```

Você deverá ver a mensagem: `Proxy server running on http://localhost:3000`

### Passo 2: Executar o Script de Teste

```powershell
# Em outro terminal, execute o script de teste com seu token de autenticação
node test-quickadd.js SEU_TOKEN_AQUI https://blog.theoldreader.com/rss
```

Substitua `SEU_TOKEN_AQUI` pelo seu token de autenticação do The Old Reader.

### Passo 3: Verificar os Resultados

O script realizará três testes:

1. **Teste Direto**: Envia um request diretamente para a API oficial
2. **Teste via Proxy (URL)**: Envia o parâmetro `quickadd` via URL através do proxy
3. **Teste via Proxy (Body)**: Envia o parâmetro `quickadd` no corpo da requisição através do proxy

Se a correção funcionar:
- Os testes 1 e 2 devem ter sucesso
- O teste 3 também deve ter sucesso, pois o proxy agora extrai o parâmetro do corpo e o coloca na URL

### Passo 4: Testar com o App Flutter

Depois de verificar que o proxy está funcionando corretamente, você pode testar diretamente no aplicativo Flutter:

1. Inicie o proxy: `node proxy.js`
2. Execute o app Flutter
3. Faça login
4. Tente adicionar um feed (por exemplo: `https://blog.theoldreader.com/rss`)

## Diagnósticos Adicionais

Se você precisar de mais detalhes sobre como as requisições estão sendo processadas:

```powershell
# Execute o servidor de diagnóstico
node quickadd-diagnostics.js
```

Este servidor roda na porta 3001 e mostra detalhadamente como os parâmetros são recebidos.

## Solução de Problemas

Se você encontrar problemas:

1. Verifique se a porta 3000 está disponível: `node check-port.js`
2. Garanta que todas as dependências estão instaladas: `npm install express cors node-fetch`
3. Verifique os logs do proxy para mensagens de erro
4. Certifique-se de usar um token de autenticação válido
