# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**The Old Reader** is a Flutter client application for the [Old Reader API](https://github.com/theoldreader/api), a lightweight RSS reader. The app supports multiple platforms (web, Android, iOS, Windows, Linux, macOS).

**Upcoming**: See **ARCHITECTURE.md** for planned multi-provider support (Feedly, Inoreader, FreshRSS, Miniflux, etc.). Currently only The Old Reader is fully implemented (Phase 1 foundation complete).

## Architecture

### Layers

- **Pages/UI** (`lib/pages/`): Material Design 3 UI components for login, feed viewing, article reading, and subscription management
- **Services** (`lib/services/`): `OldReaderApi` class handles all HTTP communication with The Old Reader API
- **Managers** (`lib/managers/`): State management for features like favorites
- **Proxy** (`proxy/`): Optional Node.js Express server — only needed for web builds (CORS)

### Key Architectural Patterns

1. **Platform-aware API access**: 
   - Native platforms (Android/iOS/Windows/Linux/macOS): call `https://theoldreader.com/reader/api/0` directly
   - Web: uses local proxy `http://localhost:3000/proxy` (CORS bypass)
   - Auto-detected via `kIsWeb` in `OldReaderApi.baseUrl`
   - Override with `OldReaderApi.setOverrideBaseUrl(url)` or `--dart-define=PROXY_URL=...`

2. **Token-based authentication**: Users authenticate via `POST /accounts/ClientLogin` (Email/Passwd). Token is stored via `flutter_secure_storage` and sent as `Authorization: GoogleLogin auth=<token>` on every request.

3. **UI-driven architecture**: No persistent state management framework (no Riverpod/GetX). State is managed at the page/scaffold level. The `MainScaffold` in `main.dart` holds the `OldReaderApi` instance and passes it to child pages. Future work: migrate to Provider-based state management.

4. **Feed identifiers**: Use `feed/<ObjectId>` format (e.g., `feed/00157a17b192950b65be3791`), not URLs. Categories/folders use label IDs like `user/-/label/FolderName` — extract name by stripping the prefix.

## Common Commands

### Setup & Dependencies

```bash
# Install Dart/Flutter dependencies
flutter pub get

# Install Node.js dependencies (for proxy)
npm install

# Generate code (Freezed, JSON serialization)
flutter pub run build_runner build

# Clean generated files if needed
flutter pub run build_runner clean
```

### Running the App

```bash
# Run on Android emulator/device
flutter run

# Run on web with proxy (separate terminals needed)
flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1
# In another terminal:
node proxy/proxy.js

# Run web and proxy together (automated startup)
# Windows:
.\direct-launcher.bat
# or (PowerShell):
pwsh .\start-web-app.ps1
# or (macOS/Linux):
./direct-launcher.sh
```

### Proxy (Web Only)

Only needed for web builds (bypasses CORS restrictions).

```bash
# Start proxy on localhost:3000
node proxy/proxy.js

# Debug mode with verbose logging
node proxy/proxy-debug.js

# Test feed addition endpoint
node proxy/test-quickadd.js
```

### Building for Production

```bash
# Android (split APKs for different architectures)
# On Windows, set JAVA_HOME first:
$env:JAVA_HOME = "$env:USERPROFILE\Android\jdk17-extracted\jdk17"
flutter build apk --release --split-per-abi

# Or debug APKs (faster to build):
flutter build apk --debug --split-per-abi

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release

# macOS
flutter build macos --release
```

### Testing

```bash
# Run all Flutter widget tests
flutter test

# Run a single widget test file
flutter test test/path/to/test_file.dart

# Run widget tests with verbose output
flutter test --verbose

# Run Playwright E2E tests (web only)
# Prerequisites: proxy running, environment variables set
export the_old_reader_email="your@email.com"
export the_old_reader_password="your_password"
npx playwright test

# Run specific Playwright test
npx playwright test login.spec.ts

# Or skip Playwright tests if env vars not set
npx playwright test --grep "@skip"

# Run Playwright in debug mode
npx playwright test --debug
```

### Code Quality & Analysis

```bash
# Analyze Dart code for issues (no typecheck)
flutter analyze

# Full lint + analysis
flutter pub get && flutter analyze

# Check for outdated dependencies
flutter pub outdated
```

## Project Structure

```
lib/
  ├── main.dart                    # App entry point, MainScaffold navigation
  ├── services/
  │   └── old_reader_api.dart      # HTTP client, all API methods
  ├── managers/
  │   └── favorites_manager.dart   # Favorites state
  └── pages/
      ├── login_screen.dart        # Login UI
      ├── home_page.dart           # Feed list
      ├── feed_articles_page.dart   # Articles for a feed
      ├── article_page.dart        # Single article view
      ├── favorites_page.dart      # Starred/bookmarked articles
      ├── add_feed_page.dart       # Add new subscription
      └── subscriptions_page.dart  # Manage feeds

proxy/
  ├── proxy.js                     # Main proxy server
  ├── proxy-debug.js               # Debug version with extra logging
  ├── config.json                  # Proxy configuration
  ├── logs/                        # Proxy logs directory
  └── test-quickadd.js             # Feed addition test script

test/
  └── widget_test.dart             # Flutter widget tests

tests/
  └── login.spec.ts                # Playwright E2E test
```

## Critical Implementation Details

### API Token Handling

- Auth token obtained from `POST /accounts/ClientLogin` with Email/Passwd parameters
- Sent as `Authorization: GoogleLogin auth=<token>` on every request
- Stored via `flutter_secure_storage` (not just in memory)

### Proxy Query String Handling (Web Only)

The proxy has special logic for `subscription/quickadd`:
- This endpoint requires `quickadd` as a **query parameter**, NOT in request body
- The proxy extracts `quickadd` from request body and moves it to the query string
- See `proxy/proxy.js` around line 100+ for implementation

### API Quirks

- **Feed identifiers**: Use `feed/<ObjectId>` format (e.g., `feed/00157a17b192950b65be3791`), not URLs
- **Category/Label IDs**: Format like `user/-/label/FolderName` — extract name by stripping `user/-/label/` prefix
- **Pagination**: `stream/items/ids` and `stream/contents` support pagination via `n` (limit, max 1000/10000), `c` (continuation), `nt`/`ot` (timestamps)
- **No pagination endpoints**: `tag/list`, `subscription/list`, `unread-count` return all data at once
- **Article content**: Can be JSON or Atom XML — `feed_articles_page.dart` tries JSON first, falls back to XML parsing
- **Batch fetches**: `getItemsContentsApi` batches item content fetches in groups of 250

### Web-Specific Concerns

- Web version requires proxy running on `localhost:3000` to bypass CORS
- Web builds served from `http://127.0.0.1:8000`
- Android emulator also uses `localhost:3000` by default

### Dead Code

- Duplicate old files exist at `lib/` root level (e.g., `lib/home_page.dart`, `lib/favorites_page.dart`) that coexist with active versions in `lib/pages/`
- These are dead code but still analyzed — avoid modifying them

### Navigation

- 3 bottom tabs (Feeds, Favoritos, Config.) mapped via `_selectedIndex` (0-2)
- "Pastas" (drawer) opens via `Navigator.push` (not IndexedStack) — adding to IndexedStack causes NavigationBar assertion failure
- `AddFeedPage` opens via FAB on "Feeds" tab; returns `true` if feed was added

## Dependencies

### Dart/Flutter

- **Flutter SDK**: ^3.7.0
- **http**: ^1.2.1 (HTTP client)
- **provider**: ^6.1.2 (state management — not deeply integrated yet)
- **freezed_annotation**: ^2.4.4 & **freezed**: ^2.5.7 (code generation for immutable models)
- **json_annotation**: ^4.9.0 & **json_serializable**: ^6.9.0 (JSON serialization)
- **xml**: ^6.3.0 (RSS/XML parsing)
- **flutter_html**: ^3.0.0 (HTML rendering in articles)
- **flutter_secure_storage**: ^9.2.4 (encrypted credential storage)
- **shared_preferences**: ^2.2.2 (lightweight local persistence)
- **flutter_lints**: ^5.0.0 (linting rules)

### Node.js (Proxy — Web Only)

- **express**: ^5.1.0 (web server)
- **cors**: ^2.8.5 (CORS header support)
- **node-fetch**: ^3.3.2 (HTTP requests from proxy to API)
- **playwright**: ^1.52.0 (E2E testing)

### Build Tools

- **build_runner**: ^2.4.13 (code generation)
- **Android JDK**: jdk17 (required for Android builds on Windows; set `$env:JAVA_HOME` before build)

## Testing Notes

- **Widget tests**: Run locally with `flutter test`, no special setup needed
- **Playwright E2E tests**: Run against web version only (port 8000)
  - Requires proxy running on port 3000
  - Requires environment variables: `the_old_reader_email`, `the_old_reader_password`
  - Skip tests with `@skip` tag if env vars not available
  - Debug mode: `npx playwright test --debug`

## Linting & Analysis

- Flutter lints enabled via `flutter_lints: ^5.0.0`
- Config in `analysis_options.yaml`
- Run `flutter analyze` for static analysis (no type checking step)
- No custom lint rules configured — uses Flutter defaults

## Work in Progress & Future Roadmap

### Architecture Evolution (See ARCHITECTURE.md)

- **Phase 1** ✅ Complete: Domain models (Feed, Article, Category), FeedProvider interface, ProviderRegistry, TheOldReaderProvider wrapper
- **Phase 2** In Progress: Migrate MainScaffold and pages to use FeedProvider abstraction
- **Phase 3** Planned: Add support for Inoreader, FreshRSS (Google Reader API compatible), Feedly (OAuth2), and other providers
- **Phase 4** Planned: Provider selection UI in Settings

### Immediate Improvements

- Migrate from raw `setState` in `MainScaffold` to Provider-based state management
- Implement Freezed models for Articles, Feeds, Categories to ensure immutability
- Move token storage to `flutter_secure_storage` (currently imported but not fully utilized)
- Implement article caching/pagination for better performance
- Add local search/filtering support

### Not Yet Implemented

- OAuth2 integration (planned for multi-provider support)
- Offline article viewing
- Push notifications
- Dark mode (Material Design 3 supports it but not integrated)
- Keyboard shortcuts for web version

## Cross-References

- See **AGENTS.md** for detailed technical notes (API quirks, navigation patterns, file structure)
- See **ARCHITECTURE.md** for multi-provider design and implementation roadmap
