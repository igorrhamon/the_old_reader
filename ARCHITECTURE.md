# Arquitetura

Visão estrutural do projeto extraída do grafo de conhecimento
(codebase-memory-mcp: **686 nós, 1448 arestas**, 6 linguagens).

---

## Camadas

```
entry (proxy, start-web-app, launcher)
  │
  ▼
api   (proxy routes, flutter routes)
  │
  ▼
core  (health-check — high fan-in, 12 callers)
```

## Módulos

| Módulo | Nós | Responsabilidade |
|--------|-----|------------------|
| `lib/pages/` | 79 | UI com Material Design 3 |
| `lib/services/` | 41 | HTTP client (`OldReaderApi`, ~37 métodos) |
| `lib/main.dart` + `main_scaffold` | 32 | Entry point + navegação |
| `proxy/` | 9 | Servidor Express (forwarding, CORS) |
| `start-web-app.js` | 14 | Launcher do app web |
| `lib/managers/` | 4 | Estado de favoritos |
| `health-check.js` | 4 | Health-check do proxy e da API |
| `manage-logs.sh` | 4 | Gerenciamento de logs |

## Entry points

1. `lib/main.dart` (`main()`) — arranque do Flutter
2. `start-web-app.js` (`main()`) — launcher que inicia proxy + Flutter web

## Hotspots (funções mais chamadas)

| Função | Módulo | Fan-in |
|--------|--------|--------|
| `log` | `health-check.js` | 28 |
| `show_menu` | `manage-logs.sh` | 4 |
| `isPortAvailable` | `start-web-app.js` | 3 |
| `log` | `proxy.js` | 3 |
| `isPortAvailable` | `proxy.js` | 2 |
| `checkApiAccess` | `health-check.js` | 2 |
| `checkProxyStatus` | `health-check.js` | 2 |
| `getCommandPath` | `start-web-app.js` | 2 |
| `getProcessUsingPort` | `start-web-app.js` | 2 |

## Clusters (comunidades)

| Cluster | Membros | Coesão | Nós principais |
|---------|---------|--------|----------------|
| test-quickadd | 9 | 63% | log, main, runTests, cleanup, testAddFeed |
| start-web-app | 8 | 69% | startFlutterWeb, startProxyServer, isPortAvailable |
| proxy (x3) | 5+5+4 | 80-100% | startServer, log, isPortAvailable |
| manage-logs | 4 | 100% | show_menu, view_logs, clear_logs, archive_logs |

## Limites entre módulos

| De → Para | Chamadas |
|-----------|----------|
| start-web-app → health-check | 5 |
| test-quickadd → health-check | 4 |
| check-port → health-check | 2 |
| proxy → health-check | 1 |

---

## Superfície da API (`OldReaderApi`)

Todas as chamadas passam pelo proxy em `http://localhost:PORTA/proxy/...`.

### Proxy config
- `setProxyPort(int)` — altera porta do proxy em runtime
- `initializeProxy()` — define URL base
- `getProxyBaseUrl()` → `http://localhost:$_proxyPort`

### Headers
- `_headers()` → `Authorization: GoogleLogin auth=<token>`
- `_headersWithContentType()` → + `Content-Type: application/x-www-form-urlencoded`

### User & preferences
- `GET /user-info?output=json`
- `GET /preference/list?output=json`

### Subscriptions
- `GET /subscription/list`
- `POST /subscription/quickadd?quickadd=<feedUrl>` (query param)
- `POST /subscription/edit` (ac=edit / ac=unsubscribe)

### Stream contents
- `GET /stream/contents?output=json&s=<streamId>`
- `GET /stream/items/ids?output=json&s=<streamId>`
- `POST /stream/items/contents?output=json` (batching de 250 IDs)
- `GET /stream/contents/<feedId>?n=20&output=xml`

### Read state
- `POST /edit-tag` com `a=user/-/state/com.google/read`
- `POST /edit-tag` com `r=user/-/state/com.google/read`
- `POST /mark-all-as-read?s=<stream>`

### Favorites (starred)
- `POST /edit-tag` com `a=user/-/state/com.google/starred`
- `POST /edit-tag` com `r=user/-/state/com.google/starred`
- `GET /stream/items/ids?output=json&s=user/-/state/com.google/starred`

### Tags / categories
- `GET /tag/list?output=json`
- `POST /rename-tag`
- `POST /disable-tag`
- Labels extraídas de tags com prefixo `user/-/label/`

### Search
- `GET /search/items/ids?output=json&q=<query>` + batching via `getItemsContentsApi`

### Outros
- `GET /reader/subscriptions/export` (OPML)
- `GET /friend/list?output=json`
- `POST /friend/edit`
- `POST /comment/edit` (addcomment)
- `GET /unread-count`

---

## Rotas do proxy (Node.js Express)

| Método | Path | Descrição |
|--------|------|-----------|
| GET | `/` | Raiz |
| GET | `/proxy/posts/starred` | Itens favoritados |
| GET | `/proxy/*` | Forwarding genérico GET |
| POST | `/proxy/*` | Forwarding genérico POST |
| POST | `/proxy/subscription/quickadd` | Adicionar feed (query param) |
| GET | `/proxy/reader/subscriptions/export` | Exportar OPML |

---

## Fluxo de execução

```
start-web-app.js
  ├── isPortAvailable / findAvailablePort
  ├── startProxyServer → proxy.js
  │     ├── POST /proxy/subscription/quickadd (query param special handling)
  │     └── GET/POST /proxy/* → forwarding para theoldreader.com
  └── startFlutterWeb → flutter run -d web-server

lib/main.dart (MainScaffold)
  ├── OldReaderApi (injetado nos filhos)
  ├── login_screen.dart → POST /accounts/ClientLogin
  ├── home_page.dart → lista de feeds
  ├── feed_articles_page.dart / feed_articles_page_xml.dart
  ├── article_page.dart
  ├── favorites_page.dart (via FavoritesManager)
  ├── subscriptions_page.dart
  ├── search_page.dart
  └── settings_page.dart
```

---

## Dependências

| Pacote | Uso |
|--------|-----|
| Flutter SDK ^3.7.0 | Framework |
| http ^1.2.1 | HTTP client |
| xml ^6.3.0 | Parsing RSS |
| flutter_html ^3.0.0 | Renderização HTML |
| shared_preferences ^2.2.2 | Persistência leve |
| flutter_secure_storage ^9.2.4 | (importado, não integrado) |
| Provider ^6.1.2 | (importado, não integrado) |
| Express, node-fetch, cors | Proxy Node.js |

---

## Notas de implementação

- **Auth**: token obtido via `POST /accounts/ClientLogin`, armazenado em memória
- **Proxy**: injeta `Authorization: GoogleLogin auth=<token>` em todas as requisições
- **quickadd**: endpoint especial — o `quickadd` deve ir como query param, não no body
- **Feed IDs**: muitos endpoints usam IDs no formato `feed/123456789`
- **Porta**: configurada em `lib/proxy_config.dart` (padrão 3000), alterável em runtime
- **Estado**: gerenciado via `setState` no `MainScaffold`; sem Provider/Riverpod ainda
- **Índice**: repositório indexado com 686 nós e 1448 arestas no grafo de conhecimento
