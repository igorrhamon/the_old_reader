# Changelog

All notable changes to The Old Reader Flutter app will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- **Multi-provider RSS architecture foundation** (Phase 1 complete)
  - Abstract `FeedProvider` interface for plugin-based provider support
  - `ProviderRegistry` for dynamic provider discovery and instantiation
  - Domain models with Freezed: `Feed`, `Article`, `Category`, `UnreadCount`, `ArticleListResult`
  - Authentication abstraction with support for GoogleLogin, OAuth2, API keys, BasicAuth
  - `TheOldReaderProvider` reference implementation wrapping existing `OldReaderApi`
  - `ProviderSettings` service for encrypted credential storage

- **Developer documentation improvements**
  - Comprehensive CLAUDE.md with build commands for all platforms
  - Code generation guide (Freezed, JSON serialization)
  - Platform-specific build instructions (Android JDK setup, iOS, web, desktop)
  - Complete API quirks reference (feed IDs, category labels, pagination patterns)
  - Testing guide with single test and Playwright debugging
  - Architecture evolution roadmap with phase tracking

- **Folder management in feed subscriptions**
  - New `FolderFeedsPage` component for folder-specific article browsing
  - Improved `FoldersPage` with better folder listing and navigation
  - Folder integration in home page navigation

### Changed

- **Documentation structure**
  - CLAUDE.md now primary developer reference with links to ARCHITECTURE.md and AGENTS.md
  - ARCHITECTURE.md documents multi-provider design and implementation phases
  - AGENTS.md consolidates technical implementation details

- **Project layout**
  - New `lib/models/` directory with Freezed domain models (Feed, Article, Category, etc.)
  - New `lib/providers/` directory with provider infrastructure and implementations
  - New test fixtures in `test/models/` and `test/providers/`

### Deprecated

- Raw `OldReaderApi` direct usage (will be replaced by `FeedProvider` in Phase 2)
- Simple `setState` architecture (Plan to migrate to Provider-based state management)

### Not Yet Implemented

- OAuth2 integration (planned for multi-provider support)
- Provider selection UI in Settings
- Additional provider implementations: Feedly, Inoreader, FreshRSS, Miniflux, Feedbin, Tiny Tiny RSS, NewsBlur, Local OPML
- Offline article viewing
- Push notifications
- Dark mode integration
- Keyboard shortcuts for web version

## Development Notes

### Building & Running

**Setup & Dependencies:**
``````bash
flutter pub get                           # Install Dart dependencies
npm install                               # Install proxy dependencies
flutter pub run build_runner build        # Generate Freezed/JSON code
``````

**Running:**
``````bash
flutter run                               # Android/iOS/Desktop
flutter run -d web-server --web-port 8000 --web-hostname 127.0.0.1  # Web
pwsh .\start-web-app.ps1                 # Windows: web + proxy
./direct-launcher.sh                      # macOS/Linux: web + proxy
``````

**Building:**
``````bash
# Android (Windows: set JAVA_HOME first)
$env:JAVA_HOME = "$env:USERPROFILE\Android\jdk17-extracted\jdk17"
flutter build apk --release --split-per-abi

flutter build ios --release               # iOS
flutter build web --release               # Web
flutter build windows --release           # Windows
flutter build linux --release             # Linux
flutter build macos --release             # macOS
``````

### Testing

``````bash
flutter test                              # Widget tests
flutter test test/path/to/test_file.dart  # Single test file
npx playwright test                       # E2E tests (requires env vars)
npx playwright test --debug                # E2E debug mode
``````

## Historical Context

- **Initial implementation**: The Old Reader API client with native platform support
- **Web CORS handling**: Node.js Express proxy for development/web builds
- **Current focus**: Multi-provider architecture foundation to support Feedly, Inoreader, and self-hosted RSS services
