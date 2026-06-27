# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**The Old Reader** is a Flutter client application for the [Old Reader API](https://github.com/theoldreader/api), a lightweight RSS reader. The app supports multiple platforms (web, Android, iOS, Windows, Linux, macOS).

## Architecture

### Layers

- **Pages/UI** (`lib/pages/`): Material Design 3 UI components for login, feed viewing, article reading, and subscription management
- **Services** (`lib/services/`): `OldReaderApi` class handles all HTTP communication with The Old Reader API
- **Managers** (`lib/managers/`): State management for features like favorites
- **Proxy** (`proxy/`): Optional Node.js Express server — only needed for web builds (CORS)

### Key Architectural Patterns

1. **Platform-aware API access**: On native platforms (Android, iOS, Windows, Linux, macOS), the app calls `https://theoldreader.com/reader/api/0` directly. On web, it uses a local proxy (`http://localhost:3000/proxy`) to bypass CORS restrictions — detected automatically via `kIsWeb`.

2. **Token-based authentication**: Users authenticate once; the auth token is stored and used for all subsequent API calls. The app sends the `Authorization: GoogleLogin auth=<token>` header with every request.

3. **UI-driven architecture**: No persistent state management framework (no Riverpod/GetX). State is managed at the page/scaffold level. The `MainScaffold` in `main.dart` holds the `OldReaderApi` instance and passes it to child pages.

## Common Commands

### Running the App

```bash
# Install dependencies
flutter pub get

# Run on Android emulator/device
flutter run

# Run on web (requires proxy running separately)
flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1

# Run web and proxy together (Windows)
.\direct-launcher.bat
# or (PowerShell)
pwsh .\start-web-app.ps1
# or (macOS/Linux)
./direct-launcher.sh
```

### Running the Proxy Separately

Only needed when testing web builds (CORS).

```bash
# Install Node.js dependencies (if not already done)
npm install

# Start the proxy (listens on http://localhost:3000)
node proxy.js

# For debugging with detailed logs
node proxy-debug.js
```

### Testing

```bash
# Run Flutter widget tests
flutter test

# Run Playwright integration tests (requires env vars)
export the_old_reader_email="your@email.com"
export the_old_reader_password="your_password"
npx playwright test

# Or skip tests if env vars not set
npx playwright test --grep "@skip"
```

### Code Quality

```bash
# Analyze Dart code for issues
flutter analyze

# Run all lints and checks
flutter pub get && flutter analyze
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

- Auth token is obtained from `POST /accounts/ClientLogin` on login
- The app sends the `Authorization: GoogleLogin auth=<token>` header with every API request
- Tokens are stored in memory; consider adding secure storage for production

### Proxy Query String Handling

The proxy has special logic for `subscription/quickadd`:
- This endpoint requires `quickadd` as a **query parameter**, not in the body
- The proxy extracts `quickadd` from the request body and moves it to the query string when forwarding to the API
- See `proxy.js` around line 100+ for the implementation

### Web-Specific Concerns

- The web version requires the proxy to run on localhost:3000 to bypass CORS
- Web builds are served from `http://127.0.0.1:8000`
- Android emulator also uses localhost:3000 by default

### Feed URLs

Many operations work with feed identifiers that look like `feed/123456789` (not just `https://...`). The API returns these IDs; store them for later API calls.

## Dependencies

- **Flutter SDK**: ^3.7.0
- **Provider**: ^6.1.2 (future state management upgrade candidate)
- **http**: ^1.2.1 (HTTP client)
- **xml**: ^6.3.0 (RSS/XML parsing)
- **flutter_html**: ^3.0.0 (HTML rendering in articles)
- **flutter_secure_storage**: ^9.2.4 (secure token storage — not yet integrated)
- **shared_preferences**: ^2.2.2 (lightweight persistence)
- **Node.js** (for proxy, web only): Express, CORS, node-fetch

## Testing Notes

- Playwright tests run against the **web version** only (port 8000)
- Tests skip if `the_old_reader_email` / `the_old_reader_password` env vars are not set
- Tests expect the proxy to be running before starting
- See `TESTING-INSTRUCTIONS.md` for detailed test setup

## Linting & Analysis

- Flutter lints enabled via `flutter_lints: ^5.0.0`
- Config in `analysis_options.yaml`
- Run `flutter analyze` to check for issues

## Recent Changes (Git Context)

The latest commits show:
- Proxy eliminado para plataformas nativas (usa API direta), mantido só para web (CORS)
- Articles now marked as read when opened in feed pages
- Android emulator compatibility fixes
- Environment variable checks for login tests

## Notes for Future Contributors

- No persistent state management yet (Provider is imported but not deeply integrated)
- Consider migrating from raw `setState` in `MainScaffold` to Provider or similar
- `flutter_secure_storage` is imported but not used; should store tokens securely
- Article caching/offline support not yet implemented
- OAuth integration planned but not yet started
