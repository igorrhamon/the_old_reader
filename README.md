# the_old_reader

Este projeto é um app Flutter que implementa um cliente para a Old Reader API ([documentação oficial](https://github.com/theoldreader/api)).

## Funcionalidades planejadas
- Login com conta do Old Reader
- Visualização dos feeds do usuário
- Leitura de artigos
- Gerenciamento de assinaturas (adicionar/remover feeds)

## Estrutura do Projeto

### Proxy para API
Todos os arquivos relacionados ao proxy estão na pasta `proxy/`:
- `proxy.js` - Servidor proxy principal
- `proxy-debug.js` - Versão com mais logs para depuração
- `test-quickadd.js` - Script para testar a adição de feeds
- `config.json` - Configurações do proxy
- `logs/` - Diretório onde os logs são armazenados

### Scripts de Execução
- `start-proxy.bat` / `start-proxy.ps1` / `start-proxy.sh` - Inicia o servidor proxy
- `direct-launcher.bat` / `direct-launcher.js` / `direct-launcher.sh` - Inicia o proxy e o app Flutter
- `manage-logs.bat` / `manage-logs.sh` - Gerencia os arquivos de log
- `organize-proxy-files.bat` / `organize-proxy-files.ps1` / `organize-proxy-files.sh` - Organiza os arquivos do proxy

## Como rodar
1. Instale as dependências:
   ```sh
   flutter pub get
   ```

2. Organize os arquivos do proxy (se ainda não estiverem organizados):
   ```sh
   .\organize-proxy-files.bat
   ```
   ou
   ```sh
   pwsh .\organize-proxy-files.ps1
   ```

3. Inicie o proxy (necessário para execução web):
   ```sh
   .\start-proxy.bat
   ```

4. Execute o app:
   ```sh
   flutter run
   ```

## Versão Web
Para executar a versão web, você precisa do proxy em execução para evitar erros de CORS:

1. Iniciar manualmente o proxy e depois o app Flutter:
   ```sh
   .\start-proxy.bat
   flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1
   ```

2. Usar o lançador direto (inicia proxy e Flutter juntos):
   ```sh
   .\direct-launcher.bat
   ```

## Gerenciamento de Logs
Para gerenciar os logs do proxy, use:
```sh
.\manage-logs.bat
```

Este script permite visualizar, limpar e arquivar os logs do servidor proxy.

## Testes

Este repositório inclui testes automatizados de login utilizando o [Playwright](https://playwright.dev).
Para executá-los, é necessário definir as variáveis de ambiente `the_old_reader_email` e `the_old_reader_password`
com as credenciais da sua conta:

```sh
export the_old_reader_email="SEU_EMAIL"
export the_old_reader_password="SUA_SENHA"
npx playwright test
```

Se as variáveis não estiverem definidas, o teste será ignorado.

## Próximos passos
- Implementar autenticação OAuth
- Listar feeds e artigos
- Interface para leitura e gerenciamento

---

Abaixo segue o conteúdo padrão do Flutter:

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
