import 'dart:io';
import '../feed_provider.dart';
import '../auth/auth_config.dart';
import '../../models/feed.dart';
import '../../models/article.dart';
import '../../models/category.dart';

class LocalOpmlProvider implements FeedProvider {
  String? _filePath;
  LocalOpmlAuthConfig? _config;
  List<Feed> _feeds = [];

  LocalOpmlProvider();

  @override
  String get providerId => 'local_opml';

  @override
  String get displayName => 'Local OPML';

  @override
  String get defaultBaseUrl => '';

  @override
  bool get supportsWebProxy => false;

  @override
  List<AuthType> get supportedAuthTypes => [AuthType.localFile];

  @override
  Future<AuthResult> authenticate(Object config) async {
    try {
      final localConfig = config as LocalOpmlAuthConfig;
      final file = File(localConfig.filePath);
      if (!await file.exists()) {
        return AuthResult(success: false, error: 'Arquivo não encontrado');
      }

      final content = await file.readAsString();
      _feeds = _parseOpml(content);
      _filePath = localConfig.filePath;
        _config = LocalOpmlAuthConfig(
          providerId: providerId,
          filePath: localConfig.filePath,
        );
      return AuthResult(
        success: true,
        config: _config,
        userId: 'local',
      );
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    _filePath = null;
    _config = null;
    _feeds = [];
  }

  @override
  Future<bool> validateToken() async {
    return _filePath != null;
  }

  @override
  Object? getStoredAuth() => _config;

  @override
  Future<List<Feed>> getFeeds() async {
    return _feeds;
  }

  @override
  Future<FeedResult> addFeed(String feedUrl, {String? category}) async {
    return FeedResult(success: false, error: 'Não suportado em modo local');
  }

  @override
  Future<void> removeFeed(String feedId) async {
    _feeds.removeWhere((f) => f.id == feedId);
  }

  @override
  Future<void> renameFeed(String feedId, String newTitle) async {
    final index = _feeds.indexWhere((f) => f.id == feedId);
    if (index >= 0) {
      _feeds[index] = _feeds[index].copyWith(title: newTitle);
    }
  }

  @override
  Future<void> moveFeed(String feedId, String? categoryId) async {}

  @override
  Future<List<Category>> getCategories() async {
    final names = <String>{};
    for (final feed in _feeds) {
      names.addAll(feed.categories);
    }
    return names.map((name) => Category(id: name, name: name)).toList();
  }

  @override
  Future<CategoryResult> createCategory(String name) async {
    return CategoryResult(success: false, error: 'Não suportado em modo local');
  }

  @override
  Future<void> renameCategory(String categoryId, String newName) async {}

  @override
  Future<void> deleteCategory(String categoryId) async {}

  @override
  Future<ArticleListResult> getArticles({
    required String streamId,
    int limit = 20,
    String? continuation,
    DateTime? newerThan,
    DateTime? olderThan,
    bool excludeRead = false,
    bool includeOnlyRead = false,
  }) async {
    return ArticleListResult(articles: []);
  }

  @override
  Future<Article?> getArticle(String articleId) async {
    return null;
  }

  @override
  Future<List<Article>> getArticlesByIds(List<String> ids) async {
    return [];
  }

  @override
  Future<void> markAsRead(String articleId) async {}

  @override
  Future<void> markAsUnread(String articleId) async {}

  @override
  Future<void> markAllAsRead(String streamId, {DateTime? before}) async {}

  @override
  Future<void> starArticle(String articleId) async {}

  @override
  Future<void> unstarArticle(String articleId) async {}

  @override
  Future<Map<String, int>> getUnreadCounts() async {
    return {};
  }

  @override
  Future<ArticleListResult> search(String query, {int limit = 20, String? continuation}) async {
    return ArticleListResult(articles: []);
  }

  @override
  Future<ArticleListResult> getStarredArticles({int limit = 20, String? continuation}) async {
    return ArticleListResult(articles: []);
  }

  @override
  Future<String> exportOpml() async {
    if (_filePath == null) return '';
    try {
      return await File(_filePath!).readAsString();
    } catch (e) {
      return '';
    }
  }

  @override
  Future<OpmlImportResult> importOpml(String opmlContent) async {
    try {
      _feeds = _parseOpml(opmlContent);
      return OpmlImportResult(success: true, feeds: _feeds);
    } catch (e) {
      return OpmlImportResult(success: false, errors: [e.toString()]);
    }
  }

  @override
  Future<Map<String, dynamic>> getPreferences() async {
    return {};
  }

  @override
  Future<void> setPreference(String key, String value) async {}

  List<Feed> _parseOpml(String content) {
    final feeds = <Feed>[];
    final regex = RegExp(r'<outline[^>]+text="([^"]*)"[^>]*xmlUrl="([^"]*)"[^>]*/?>');
    for (final match in regex.allMatches(content)) {
      final title = match.group(1) ?? '';
      final url = match.group(2) ?? '';
      if (url.isNotEmpty) {
        feeds.add(Feed(
          id: url,
          title: title,
          url: url,
        ));
      }
    }
    return feeds;
  }
}
