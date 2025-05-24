# Rodando The Old Reader Client no Flutter Web

## Requisitos

- Flutter SDK instalado
- Node.js (para o servidor proxy)
- Navegador web (Chrome, Edge, Firefox, etc.)

## Método Recomendado: Inicialização Automática

A maneira mais fácil de executar o aplicativo web é usando nosso launcher automático, que:

1. Detecta e configura automaticamente o Flutter
2. Inicia o servidor proxy
3. Inicia o aplicativo Flutter Web com as configurações corretas

### Como usar:

```
.\auto-launcher.bat
```

Este script cuida de todo o processo, incluindo a verificação do Flutter e a configuração do ambiente.

## Métodos Alternativos

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

## Solução de Problemas

### Erro "spawn flutter ENOENT" ou "spawn C:\\Users\\...\\flutter\r ENOENT"

Este erro ocorre quando o Node.js não consegue encontrar o executável do Flutter ou há problemas com o caminho. Para resolver:

1. **Use a ferramenta de correção de caminho do Flutter**:
   ```
   .\fix-flutter-path.bat
   ```
   
   Esta ferramenta:
   - Localiza automaticamente o Flutter em seu sistema
   - Cria um arquivo de configuração específico para o seu ambiente
   - Atualiza os scripts para usar o caminho correto
   - Resolve problemas com caracteres especiais no caminho

2. **Depois de executar o corretor de caminho**, tente novamente executar o aplicativo:
   ```
   .\run-web-app.bat
   ```

3. **Se o problema persistir**, verifique se o Flutter está instalado corretamente e no PATH do sistema:
   ```
   .\check-flutter.bat
   ```

### Verificando a Instalação do Flutter

Se você está enfrentando problemas com o Flutter, execute a ferramenta de diagnóstico incluída:

```
.\check-flutter.bat
```

Ou diretamente via Node.js:

```
node check-flutter.js
```

Esta ferramenta irá:
1. Verificar se o Flutter está instalado e disponível no PATH
2. Procurar por instalações do Flutter em locais comuns
3. Verificar se o suporte para web está habilitado
4. Fornecer instruções para resolver problemas encontrados

### Erro "spawn flutter ENOENT"

Este erro ocorre quando o script não consegue encontrar o executável do Flutter. Para resolver:

1. **Verifique se o Flutter está instalado corretamente** - Execute `flutter doctor` em um terminal para verificar a instalação.

2. **Verifique se o Flutter está no PATH** - O launcher tentará localizar o Flutter em várias pastas comuns, mas se estiver em um local personalizado, você precisará adicionar o caminho do Flutter ao PATH do sistema ou especificar o caminho completo no script.

3. **Adicione o Flutter ao PATH** - Para adicionar o Flutter ao PATH do sistema:
   - Localize a pasta `bin` da sua instalação do Flutter (ex: `C:\flutter\bin`)
   - Adicione esta pasta às variáveis de ambiente do sistema:
     - Pressione Win+S, digite "variáveis de ambiente" e selecione "Editar as variáveis de ambiente do sistema"
     - Clique em "Variáveis de Ambiente"
     - Em "Variáveis do sistema", selecione a variável "Path" e clique em "Editar"
     - Clique em "Novo" e adicione o caminho para a pasta bin do Flutter
     - Clique em "OK" em todas as janelas
     - Reinicie os terminais abertos para que as mudanças tenham efeito

4. **Especifique o caminho completo** - Você pode editar o arquivo `start-web-app.js` para especificar o caminho completo para o executável do Flutter, alterando a linha que contém `spawn('flutter'` para algo como `spawn('C:\\caminho\\para\\flutter\\bin\\flutter.bat'`.

### Erro "Cannot find module..."

Se você encontrar um erro indicando que um módulo Node.js não pode ser encontrado:

1. Execute `npm install` para instalar todas as dependências necessárias
2. Em seguida, execute `npm install express cors node-fetch` para garantir que as dependências específicas do proxy estejam instaladas

### Portas já em uso

Se as portas 3000 (proxy) ou 8000 (web app) já estiverem em uso:
1. O launcher tentará encontrar portas alternativas automaticamente
2. Você pode modificar as constantes `DEFAULT_PROXY_PORT` e `DEFAULT_WEB_PORT` no arquivo `start-web-app.js` para usar outras portas

### Erros no Navegador

#### Erro "Failed to fetch" ou "Network Error"

Se o aplicativo iniciar, mas aparecer erros no console do navegador como "Failed to fetch" ou "Network Error":

1. **Verifique se o proxy está rodando** - Abra `http://localhost:3000` (ou a porta alternativa) no navegador. Você deve ver uma mensagem do proxy.
   
2. **Verifique as configurações CORS** - Se houver erros de CORS no console, verifique se o proxy está configurado corretamente com os headers CORS apropriados.

3. **Verifique a URL da API** - Certifique-se de que a URL da API no arquivo `lib/services/old_reader_api.dart` está apontando para o proxy correto:
   ```dart
   static const String baseUrl = 'http://localhost:3000/proxy';
   ```

4. **Erro de Mixed Content** - Se estiver executando o app HTTPS e o proxy em HTTP, o navegador pode bloquear as requisições. Nesse caso, use HTTP para ambos ou configure HTTPS para o proxy.

### Erros do Flutter Web

#### Erro "Failed to load resource: net::ERR_CONNECTION_REFUSED"

Este erro pode ocorrer quando:

1. O proxy não está rodando
2. A porta do proxy está incorreta no código
3. Um firewall está bloqueando a conexão

Soluções:
- Verifique se o proxy está rodando
- Confirme que a porta no código corresponde à porta em que o proxy está rodando
- Temporariamente desative o firewall para teste ou adicione uma exceção

#### Erro "RangeError (index): Invalid value: Valid value range is empty: 0"

Este erro geralmente ocorre quando:
1. O aplicativo está tentando acessar dados que ainda não foram carregados
2. Há um problema com a resposta da API

Soluções:
- Verifique a implementação de verificações null safety
- Adicione tratamento de erro nas chamadas da API
- Verifique se os dados estão sendo retornados corretamente pelo proxy

### Problemas com o Proxy

#### Erro "The Old Reader API respondeu com status: xxx"

Se o proxy estiver respondendo com erros de status HTTP:

1. **Autenticação inválida** - Verifique suas credenciais de login
2. **Limite de taxa excedido** - A API pode estar limitando suas requisições, espere um pouco e tente novamente
3. **Endpoint desativado** - Verifique se o endpoint que está tentando acessar ainda é suportado pela API

#### Erro "request to ... failed, reason: connect ETIMEDOUT"

Este erro ocorre quando o proxy não consegue se conectar à API do The Old Reader:

1. Verifique sua conexão com a internet
2. Verifique se a API do The Old Reader está online (visite https://theoldreader.com)
3. Considere adicionar um timeout maior para as requisições no proxy

## Ferramentas de Diagnóstico e Configuração

Se você encontrar problemas ao executar o aplicativo, temos ferramentas específicas para ajudar:

### 1. Corretor de Caminho do Flutter

Se você encontrar erros relacionados ao Flutter, como "spawn flutter ENOENT":

```
.\fix-flutter-path.bat
```

Esta ferramenta:
- Localiza automaticamente o Flutter em seu sistema
- Cria um arquivo de configuração com o caminho correto
- Corrige problemas com caracteres especiais no caminho do Flutter

### 2. Verificador da Instalação do Flutter

Para verificar se o Flutter está instalado corretamente:

```
.\check-flutter.bat
```

Esta ferramenta:
- Verifica se o Flutter está no PATH
- Testa se o Flutter pode ser executado
- Verifica se o suporte para web está habilitado
- Cria automaticamente um arquivo de configuração se necessário

## Launcher Tradicional

O método tradicional de inicialização continua disponível:

```
.\run-web-app.bat
```

Este launcher verifica se há configuração do Flutter e, se necessário, executa o corretor de caminho.

## Dicas Adicionais

### Desenvolvimento Eficiente

1. **Hot Reload** - O Flutter Web suporta hot reload. Quando fizer alterações no código, pressione `r` no terminal onde o Flutter está rodando para aplicar as mudanças sem reiniciar o aplicativo.

2. **Depuração** - Você pode usar as ferramentas de desenvolvedor do navegador (F12) para inspecionar requisições de rede, ver logs de console e depurar problemas.

3. **Logs do Proxy** - O proxy imprime logs úteis no terminal. Fique atento a eles para identificar problemas de comunicação com a API.

### Otimizações

1. **Modo de Produção** - Para melhor desempenho ao testar, você pode compilar o app em modo de produção:
   ```
   flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1 --release
   ```

2. **Compressão** - O proxy pode ser configurado para comprimir respostas e melhorar o desempenho. Adicione o middleware de compressão ao proxy.js se necessário.

3. **Cache** - Considere implementar cache no proxy para reduzir chamadas à API e melhorar o desempenho.

### Fluxo de Trabalho Recomendado

Para um fluxo de trabalho otimizado ao desenvolver e testar o aplicativo:

1. **Configure corretamente o caminho do Flutter** (apenas na primeira execução ou após mudanças):
   ```
   .\fix-flutter-path.bat
   ```

2. **Inicie o aplicativo**:
   ```
   .\run-web-app.bat
   ```

3. **Desenvolva e teste**:
   - Faça alterações no código
   - Use o hot reload pressionando `r` no terminal do Flutter
   - Verifique os logs do proxy para depurar problemas de API
   - Use as ferramentas do navegador (F12) para depuração adicional

4. **Finalize o aplicativo pressionando Ctrl+C** nos terminais do proxy e do Flutter

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

## Contribuindo para o Projeto

### Estrutura do Código

O aplicativo é organizado da seguinte forma:

- `/lib` - Código principal do Flutter
  - `/pages` - Telas do aplicativo
  - `/services` - Serviços e comunicação com a API
  - `/widgets` - Componentes reutilizáveis
  - `/managers` - Gerenciadores de estado e lógica de negócios
- `/proxy.js` - Servidor proxy para a API do The Old Reader
- Scripts de inicialização - Facilitam a execução do aplicativo web

### Como Adicionar Novos Recursos

1. **Implementar uma nova funcionalidade da API**:
   - Adicione novos métodos ao arquivo `lib/services/old_reader_api.dart`
   - Se necessário, adicione tratamento para esses endpoints no proxy.js

2. **Adicionar uma nova tela**:
   - Crie um novo arquivo na pasta `/lib/pages`
   - Adicione a navegação para a tela no scaffold principal

3. **Modificar o proxy**:
   - Edite o arquivo `proxy.js` para adicionar novos endpoints ou recursos
   - Teste cuidadosamente as mudanças com o aplicativo web

### Diretrizes de Qualidade

1. **Testes** - Adicione testes para novos recursos em `/test`
2. **Documentação** - Mantenha este documento atualizado com novas funcionalidades
3. **Tratamento de Erros** - Sempre inclua tratamento de erros apropriado
4. **Compatibilidade** - Certifique-se de que seu código funciona tanto na web quanto em dispositivos móveis

## Recursos Adicionais

- [Documentação da API do The Old Reader](https://github.com/theoldreader/api)
- [Documentação do Flutter Web](https://flutter.dev/docs/get-started/web)
- [Flutter DevTools](https://flutter.dev/docs/development/tools/devtools/overview)

---

*Última atualização: 24 de maio de 2025*
