# Multi-Provider RSS Architecture

## Overview

This document describes the multi-provider RSS architecture for the Old Reader Flutter app, enabling support for multiple RSS providers through a common interface.

## Providers Supported

- **The Old Reader** (current) - GoogleLogin auth ✅ IMPLEMENTED
- **Feedly** - OAuth2
- **Inoreader** - Google Reader API compatible, OAuth2/API key
- **FreshRSS** - Self-hosted, Google Reader API compatible, API key/Basic Auth
- **Miniflux** - Self-hosted, REST API, API key
- **Tiny Tiny RSS** - Self-hosted, TT-RSS API, Session-based
- **Feedbin** - REST API, Basic Auth/API token
- **NewsBlur** - Custom API, Session/Cookie
- **Local OPML** - File-based, no auth

---

## Implementation Status

### Phase 1: Foundation ✅
- [x] Domain models (Feed, Article, Category, AuthConfig)
- [x] FeedProvider abstract interface
- [x] ProviderRegistry
- [x] ProviderSettings (credential storage)
- [x] TheOldReaderProvider (wraps existing OldReaderApi)

### Phase 2: Migration
- [ ] Update MainScaffold to use FeedProvider
- [ ] Update all pages
- [ ] Provider selection in Settings
- [ ] Login flow refactor

### Phase 3: Additional Providers
- [ ] Inoreader, FreshRSS (Google Reader API compatible)
- [ ] Feedly (OAuth2)
- [ ] Miniflux, Feedbin, TT-RSS, NewsBlur
- [ ] Local OPML

---

## Core Domain Models

### Feed (lib/models/feed.dart)
```dart
@freezed
class Feed with _$Feed {
  const factory Feed({
    required String id,
    required String title,
    String? url,
    String? siteUrl,
    String? iconUrl,
    @Default(0) int unreadCount,
    @Default([]) List<String> categories,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Feed;

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
}
```

### Article (lib/models/article.dart)
```dart
@freezed
class Article with _$Article {
  const factory Article({
    required String id,
    required String feedId,
    required String title,
    String? author,
    String? summary,
    String? content,
    String? url,
    DateTime? published,
    DateTime? updated,
    @Default([]) List<String> categories,
    @Default(false) bool isRead,
    @Default(false) bool isStarred,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Article;

  factory Article.fromJson(Map<String, dynamic> json) => _$ArticleFromJson(json);
}

@freezed
class ArticleListResult with _$ArticleListResult {
  const factory ArticleListResult({
    required List<Article> articles,
    String? continuation,
    int? totalCount,
  }) = _ArticleListResult;

  factory ArticleListResult.fromJson(Map<String, dynamic> json) => _$ArticleListResultFromJson(json);
}
```

### Category & UnreadCount (lib/models/category.dart)
```dart
@freezed
class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    @Default(0) int unreadCount,
    @Default([]) List<Feed> feeds,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
}

@freezed
class UnreadCount with _$UnreadCount {
  const factory UnreadCount({
    required String id,
    required int count,
    DateTime? updated,
  }) = _UnreadCount;

  factory UnreadCount.fromJson(Map<String, dynamic> json) => _$UnreadCountFromJson(json);
}
```

---

## FeedProvider Interface (lib/providers/feed_provider.dart)

```dart
abstract class FeedProvider {
  String get providerId;
  String get displayName;
  String get defaultBaseUrl;
  bool get supportsWebProxy;
  List<AuthType> get supportedAuthTypes;

  Future<AuthResult> authenticate(Object config);
  Future<void> logout();
  Future<bool> validateToken();
  Object? getStoredAuth();

  Future<List<Feed>> getFeeds();
  Future<FeedResult> addFeed(String feedUrl, {String? category});
  Future<void> removeFeed(String feedId);
  Future<void> renameFeed(String feedId, String newTitle);
  Future<void> moveFeed(String feedId, String? categoryId);

  Future<List<Category>> getCategories();
  Future<CategoryResult> createCategory(String name);
  Future<void> renameCategory(String categoryId, String newName);
  Future<void> deleteCategory(String categoryId);

  Future<ArticleListResult> getArticles({
    required String streamId,
    int limit = 20,
    String? continuation,
    DateTime? newerThan,
    DateTime? olderThan,
    bool excludeRead = false,
  });

  Future<Article?> getArticle(String articleId);
  Future<List<Article>> getArticlesByIds(List<String> ids);

  Future<void> markAsRead(String articleId);
  Future<void> markAsUnread(String articleId);
  Future<void> markAllAsRead(String streamId, {DateTime? before});
  Future<void> starArticle(String articleId);
  Future<void> unstarArticle(String articleId);

  Future<Map<String, int>> getUnreadCounts();

  Future<ArticleListResult> search(String query, {int limit = 20, String? continuation});

  Future<ArticleListResult> getStarredArticles({int limit = 20, String? continuation});

  Future<String> exportOpml();
  Future<OpmlImportResult> importOpml(String opmlContent);

  Future<Map<String, dynamic>> getPreferences();
  Future<void> setPreference(String key, String value);
}

enum AuthType { googleLogin, oauth2, apiKey, basicAuth, localFile }
```

---

## Authentication Abstraction (lib/providers/auth/auth_config.dart)

### Provider-Specific Configs (Freezed classes)
- `GoogleLoginAuthConfig` - The Old Reader (email/password → token)
- `OAuth2AuthConfig` - Feedly, Inoreader (client_id, secret, tokens)
- `ApiKeyAuthConfig` - FreshRSS, Miniflux, Feedbin
- `BasicAuthConfig` - Feedbin, self-hosted
- `LocalOpmlAuthConfig` - Local OPML (file path)

### Result Classes
```dart
@freezed
class AuthResult with _$AuthResult {
  const factory AuthResult({
    required bool success,
    GoogleLoginAuthConfig? config,
    String? error,
    String? userId,
    String? userName,
  }) = _AuthResult;
}

@freezed
class FeedResult with _$FeedResult {
  const factory FeedResult({
    required bool success,
    String? feedId,
    String? error,
    Feed? feed,
  }) = _FeedResult;
}

@freezed
class CategoryResult with _$CategoryResult {
  const factory CategoryResult({
    required bool success,
    String? categoryId,
    String? error,
    Category? category,
  }) = _CategoryResult;
}

@freezed
class OpmlImportResult with _$OpmlImportResult {
  const factory OpmlImportResult({
    required bool success,
    @Default([]) List<Feed> feeds,
    @Default([]) List<String> errors,
  }) = _OpmlImportResult;
}
```

---

## Provider Registry (lib/providers/provider_registry.dart)

```dart
class ProviderInfo {
  final String id;
  final String name;
  final bool supportsWebProxy;
  final List<AuthType> authTypes;
}

class ProviderRegistry {
  static void register(String providerId, FeedProvider Function() factory, ProviderInfo info);
  static FeedProvider? create(String providerId);
  static List<ProviderInfo> getAvailableProviders();
  static ProviderInfo? getProviderInfo(String providerId);
  static bool isRegistered(String providerId);
}
```

### Initialization (lib/providers/provider_init.dart)
```dart
void initializeProviders() {
  ProviderRegistry.register(
    'theoldreader',
    () => TheOldReaderProvider(),
    const ProviderInfo(
      id: 'theoldreader',
      name: 'The Old Reader',
      supportsWebProxy: true,
      authTypes: [AuthType.googleLogin],
    ),
  );
}
```

---

## Settings Storage (lib/services/provider_settings.dart)

`ProviderSettings` using `flutter_secure_storage`:
- Per-provider credentials (encrypted)
- Active provider tracking
- Provider-specific settings (custom base URLs)

```dart
class ProviderSettings {
  static Future<void> saveAuthConfig(String providerId, Object config);
  static Future<Object?> loadAuthConfig(String providerId);
  static Future<void> clearAuthConfig(String providerId);
  static Future<void> setActiveProvider(String providerId);
  static Future<String?> getActiveProvider();
  static Future<void> saveProviderSetting(String providerId, String key, String value);
  static Future<String?> getProviderSetting(String providerId, String key);
  static Future<Map<String, bool>> getConnectedProviders();
}
```

---

## TheOldReaderProvider (lib/providers/theoldreader/theoldreader_provider.dart)

Wraps the existing `OldReaderApi` and implements the `FeedProvider` interface. This is the reference implementation showing how to adapt an existing API to the new architecture.

Key features:
- Converts between OldReaderApi responses and domain models
- Handles XML/JSON response parsing
- Maps Google Reader API states (read/starred) to boolean flags

---

## Security Considerations

1. **Credential Storage**: All auth tokens stored via `flutter_secure_storage` (encrypted at rest)
2. **No Hardcoded Secrets**: Client IDs, secrets are entered by users
3. **Token Validation**: Providers validate tokens before storing
4. **Secure Transmission**: HTTPS for all API calls
5. **Web Proxy**: CORS bypass via local proxy, no credentials sent to third parties

---

## File Structure

```
lib/
├── models/
│   ├── feed.dart                    # Freezed Feed model
│   ├── feed.freezed.dart            # Generated
│   ├── feed.g.dart                  # Generated
│   ├── article.dart                 # Freezed Article + ArticleListResult
│   ├── article.freezed.dart
│   ├── article.g.dart
│   ├── category.dart                # Freezed Category + UnreadCount
│   ├── category.freezed.dart
│   └── category.g.dart
├── providers/
│   ├── feed_provider.dart           # Abstract FeedProvider interface
│   ├── provider_registry.dart       # Provider factory/registry
│   ├── provider_init.dart           # Provider registration
│   ├── auth/
│   │   ├── auth_config.dart         # Freezed auth config classes
│   │   ├── auth_config.freezed.dart
│   │   └── auth_config.g.dart
│   ├── theoldreader/
│   │   └── theoldreader_provider.dart  # TheOldReader implementation
│   ├── feedly/                      # Future
│   ├── inoreader/                   # Future
│   ├── freshrss/                    # Future
│   ├── miniflux/                    # Future
│   ├── ttrss/                       # Future
│   ├── feedbin/                     # Future
│   ├── newsblur/                    # Future
│   └── local_opml/                  # Future
├── services/
│   ├── provider_settings.dart       # Credential/settings storage
│   ├── old_reader_api.dart          # Legacy (to be wrapped by TheOldReaderProvider)
│   └── auth_service.dart            # Legacy (to be replaced by ProviderSettings)
└── pages/                           # Updated to use FeedProvider
```

---

## Migration Guide

### For existing code using OldReaderApi directly:

1. Import the provider registry
2. Get the active provider: `ProviderRegistry.create(activeProviderId)`
3. Use the provider interface methods instead of OldReaderApi methods

### For adding a new provider:

1. Create directory `lib/providers/{provider_name}/`
2. Create `{provider_name}_provider.dart` implementing `FeedProvider`
3. Add auth config class in `lib/providers/auth/auth_config.dart` if needed
4. Register in `lib/providers/provider_init.dart`
5. Test all interface methods

---

## Next Steps

1. **Phase 2**: Update MainScaffold and pages to use FeedProvider
2. **Phase 3**: Implement Inoreader (closest to Google Reader API)
3. **Phase 4**: Add provider selection UI in Settings
4. **Phase 5**: Implement remaining providers