# Rodando The Old Reader Client no Flutter Web

## Requisitos

- Flutter SDK instalado
- Node.js (para o servidor proxy)
- Navegador web (Chrome, Edge, Firefox, etc.)

## Método Recomendado: Usando o Launcher Automatizado

A maneira mais fácil de executar o aplicativo web é usando nosso launcher automatizado, que cuida de iniciar o proxy e o aplicativo Flutter Web com as configurações corretas.

### Windows

Execute o arquivo `run-web-app.bat` clicando nele ou através do terminal:

```
.\run-web-app.bat
```

Ou execute diretamente o script Node.js:

```
node start-web-app.js
```

Este launcher:
1. Verifica portas disponíveis e escolhe portas alternativas, se necessário
2. Instala as dependências do proxy automaticamente
3. Configura o aplicativo Flutter para usar a porta correta do proxy
4. Inicia o proxy e o aplicativo Flutter Web
5. Limpa os arquivos temporários quando o aplicativo é encerrado

## Executando com os scripts individuais

Se preferir, você também pode usar os scripts mais simples:

### Windows

#### Usando o Batch Script

Execute o arquivo `start-web-app.bat`:

```
.\start-web-app.bat
```

#### Usando o PowerShell Script

Execute o arquivo `start-web-app.ps1` através do PowerShell:

```powershell
.\start-web-app.ps1
```

## Executando manualmente

Se preferir executar manualmente, siga estes passos:

### 1. Inicie o servidor proxy

Abra um terminal e execute:

```
node proxy.js
```

O proxy será iniciado na porta 3000 (ou uma porta alternativa se 3000 estiver em uso).

### 2. Inicie o aplicativo Flutter Web

Em outro terminal, execute:

```
flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1
```

## Usando o VS Code

No VS Code, você pode iniciar o aplicativo usando uma das seguintes opções:

1. **Opção Recomendada**: Use a configuração "Web App Launcher (Node.js)" que inicia tanto o proxy quanto o aplicativo Flutter Web automaticamente.

2. **Manualmente**: 
   - Primeiro inicie o proxy usando a configuração "Proxy"
   - Depois inicie o aplicativo web usando a configuração "Flutter Web (web-server)"

Para usar estas configurações:
1. Abra o painel de Debug (Ctrl+Shift+D)
2. Selecione a configuração desejada no menu suspenso
3. Clique no botão de play ou pressione F5

## Acessando o aplicativo

Após iniciar o servidor, acesse o aplicativo em:

```
http://127.0.0.1:8000
```

Ou no endereço exibido no terminal, caso uma porta alternativa tenha sido escolhida.

## Solução de problemas

### Erro ao iniciar o navegador

Se você receber o erro:

```
Failed to launch browser. Make sure you are using an up-to-date Chrome or Edge. Otherwise, consider using -d web-server instead
```

Use o launcher automatizado (`run-web-app.bat` ou `start-web-app.js`) ou execute manualmente com a opção `-d web-server` conforme descrito acima.

### Erros CORS no console do navegador

Se você ver erros de CORS no console do navegador, certifique-se de que:

1. O proxy está rodando corretamente 
2. A URL base na aplicação está configurada para usar a porta correta do proxy

### O proxy não inicia devido a "address already in use"

Nosso launcher automatizado (`start-web-app.js`) irá:
1. Detectar que a porta está em uso
2. Oferecer a opção de encerrar o processo que está usando a porta
3. Ou escolher automaticamente uma porta alternativa
4. Configurar o aplicativo Flutter para usar a porta correta do proxy

Se você estiver executando manualmente, verifique se:
1. A porta 3000 não está sendo usada por outro aplicativo
2. Todas as dependências estão instaladas: `npm install express cors node-fetch`
3. Você está usando uma versão compatível do Node.js
