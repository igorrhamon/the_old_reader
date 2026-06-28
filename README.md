<div align="center">

# 📰 Multi RSS Reader

**Cliente Flutter multi-provider para leitura de RSS — 8 providers com interface unificada**

> Suporta: The Old Reader, Inoreader, FreshRSS, Miniflux, TT-RSS, Feedbin, NewsBlur e OPML local.

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![License](https://img.shields.io/badge/license-MIT-green?style=for-the-badge)](LICENSE)

[![Android](https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white)](https://flutter.dev)
[![iOS](https://img.shields.io/badge/iOS-000000?style=flat-square&logo=apple&logoColor=white)](https://flutter.dev)
[![Web](https://img.shields.io/badge/Web-4285F4?style=flat-square&logo=google-chrome&logoColor=white)](https://flutter.dev)
[![Windows](https://img.shields.io/badge/Windows-0078D6?style=flat-square&logo=windows&logoColor=white)](https://flutter.dev)
[![Linux](https://img.shields.io/badge/Linux-FCC624?style=flat-square&logo=linux&logoColor=black)](https://flutter.dev)
[![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)](https://flutter.dev)

</div>

---

## ✨ Sobre

Acompanhe seus feeds RSS favoritos com uma interface limpa, rápida e responsiva. O app suporta **8 providers RSS** através de uma interface comum, permitindo conectar-se à sua conta preferida com uma única interface.

> 📖 Documentação técnica completa em [ARCHITECTURE.md](ARCHITECTURE.md).

### Providers Suportados

| Provider | Tipo | Self-hosted | Auth |
|----------|------|-------------|------|
| **The Old Reader** | Google Reader API | ❌ | Email/Senha |
| **Inoreader** | Google Reader API | ❌ | API Key |
| **FreshRSS** | Google Reader API | ✅ | Email/Senha |
| **Miniflux** | REST API | ✅ | API Key |
| **Tiny Tiny RSS** | Custom API | ✅ | Email/Senha |
| **Feedbin** | REST API | ❌ | Email/Senha |
| **NewsBlur** | Custom API | ✅ | Email/Senha |
| **Local OPML** | File-based | N/A | Nenhum |

### Funcionalidades

- 🔐 Login multi-provider com seleção dinâmica
- 📱 Interface responsiva com Material Design 3
- ✅ Visualização de feeds e artigos
- ⭐ Marcação de leitura / não lida
- 🔖 Favoritos (starred) com sincronização
- 📂 Gerenciamento de assinaturas (adicionar/remover feeds)
- 📁 Navegação por pastas e categorias
- 🔍 Busca de artigos
- 🌐 Proxy Node.js embutido para CORS na web
- 🔒 Credenciais criptografadas via flutter_secure_storage

---

## 🚀 Começando

### Pré-requisitos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) ^3.7.0
- [Node.js](https://nodejs.org) ^18 (apenas para web/CORS)
- Conta em um dos providers suportados (The Old Reader, Inoreader, FreshRSS, Miniflux, TT-RSS, Feedbin, NewsBlur ou OPML local)

### Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/the_old_reader.git
cd the_old_reader

# Instale as dependências Flutter
flutter pub get

# Instale as dependências do proxy
npm install
```

### Executando

**Desktop / Android / iOS:**
```bash
flutter run
```

**Web** (requer proxy para CORS):
```bash
# Terminal 1: proxy
node proxy/proxy.js

# Terminal 2: Flutter
flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1
```

**Tudo em um comando:**
```bash
# Windows
.\direct-launcher.bat

# macOS / Linux
./direct-launcher.sh

# PowerShell
pwsh .\start-web-app.ps1
```

### Proxy (debug)
```bash
node proxy/proxy-debug.js
```

---

## 🧪 Testes

```bash
# Testes de widget Flutter
flutter test --reporter expanded

# Análise estática
flutter analyze

# Testes E2E com Playwright (requer proxy e variáveis de ambiente)
export the_old_reader_email="seu@email.com"
export the_old_reader_password="sua_senha"
npx playwright test
```

---

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                          # Entry point + Login + MainScaffold
├── models/
│   ├── feed.dart                      # Freezed Feed model
│   ├── article.dart                   # Freezed Article + ArticleListResult
│   └── category.dart                  # Freezed Category + UnreadCount
├── providers/
│   ├── feed_provider.dart             # Abstract FeedProvider interface
│   ├── provider_registry.dart         # Provider factory/registry
│   ├── provider_init.dart             # Provider registration (all 8)
│   ├── auth/
│   │   └── auth_config.dart           # Freezed auth config classes
│   ├── theoldreader/
│   │   └── theoldreader_provider.dart
│   ├── inoreader/
│   │   └── inoreader_provider.dart
│   ├── freshrss/
│   │   └── freshrss_provider.dart
│   ├── miniflux/
│   │   └── miniflux_provider.dart
│   ├── ttrss/
│   │   └── ttrss_provider.dart
│   ├── feedbin/
│   │   └── feedbin_provider.dart
│   ├── newsblur/
│   │   └── newsblur_provider.dart
│   └── local_opml/
│       └── local_opml_provider.dart
├── services/
│   ├── provider_settings.dart         # Credential/settings storage
│   └── old_reader_api.dart            # Legacy API (TheOldReaderProvider)
├── managers/
│   └── favorites_manager.dart         # Estado de favoritos (SharedPreferences)
└── pages/
    ├── login_screen.dart              # Login multi-provider
    ├── home_page.dart                 # Lista de feeds
    ├── feed_articles_page.dart        # Artigos de um feed
    ├── feed_articles_page_xml.dart    # Artigos (fallback XML)
    ├── article_page.dart              # Leitura de artigo
    ├── favorites_page.dart            # Itens favoritados
    ├── folders_page.dart              # Pastas/categorias
    ├── folder_feeds_page.dart         # Feeds de uma pasta
    ├── add_feed_page.dart             # Adicionar assinatura
    ├── subscriptions_page.dart        # Gerenciar assinaturas
    ├── search_page.dart               # Busca de artigos
    └── settings_page.dart             # Configurações

proxy/
├── proxy.js                           # Servidor Express principal
├── proxy-debug.js                     # Versão com logs detalhados
├── proxy-test.js                      # Testes do proxy
├── health-check.js                    # Health-check da API
├── check-port.js                      # Verificação de porta
├── config.json                        # Configurações
└── test-quickadd.js                   # Teste de adição de feeds

tests/
└── login.spec.ts                      # Teste E2E Playwright
```

---

## 🛠️ Stack

| Camada | Tecnologia |
|--------|-----------|
| **Frontend** | Flutter + Dart 3.7 |
| **Modelos** | Freezed + json_serializable |
| **HTTP Client** | `http` ^1.2.1 |
| **Parsing RSS** | `xml` ^6.3.0 |
| **Renderização HTML** | `flutter_html` ^3.0.0 |
| **Credenciais** | `flutter_secure_storage` |
| **Persistência** | `shared_preferences` |
| **Proxy** | Node.js + Express |
| **Testes E2E** | Playwright |

---

## 🔧 Build

```bash
# Android APK (split-per-abi)
$env:JAVA_HOME = "$env:USERPROFILE\Android\jdk17-extracted\jdk17"
flutter build apk --debug --split-per-abi

# Web
flutter build web
```

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

<p align="center">
  <a href="ARCHITECTURE.md">📘 Documentação Técnica</a>
</p>
