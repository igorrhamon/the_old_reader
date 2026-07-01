import 'dart:convert';
import 'package:http/http.dart' as http;
import '../feed_provider.dart';
import '../auth/auth_config.dart';
import '../feedly/feedly_auth.dart';
import '../../models/feed.dart';
import '../../models/article.dart';
import '../../models/category.dart';
import '../../services/provider_settings.dart';

class FeedlyProvider implements FeedProvider {
  OAuth2AuthConfig? _config;
  String _userId = '';
  static const String _baseUrl = 'https://cloud.feedly.com';

  FeedlyProvider();

  Map<String, String> get _headers => {
        'Authorization': 'Bearer ${_config?.accessToken ?? ''}',
        'Content-Type': 'application/json',
      };

  @override
  String get providerId => 'feedly';

  @override
  String get displayName => 'Feedly';

  @override
  String get defaultBaseUrl => _baseUrl;

  @override
  bool get supportsWebProxy => false;

  @override
  List<AuthType> get supportedAuthTypes => [AuthType.oauth2];

  @override
  Future<AuthResult> authenticate(Object config) async {
    try {
      _config = config as OAuth2AuthConfig;

      var profileResponse = await http.get(
        Uri.parse('$_baseUrl/v3/profile'),
        headers: _headers,
      );

      if (profileResponse.statusCode == 401 &&
          (_config?.refreshToken ?? '').isNotEmpty) {
        final newConfig = await FeedlyAuth.refresh(_config!);
        _config = newConfig;
        await ProviderSettings.saveAuthConfig('feedly', newConfig);
        profileResponse = await http.get(
          Uri.parse('$_baseUrl/v3/profile'),
          headers: _headers,
        );
      }

      if (profileResponse.statusCode != 200) {
        return AuthResult(
          success: false,
          error: 'Falha ao validar token: ${profileResponse.statusCode}',
        );
      }

      final profile =
          jsonDecode(profileResponse.body) as Map<String, dynamic>;
      _userId = profile['id'] as String? ?? '';
      await ProviderSettings.saveProviderSetting('feedly', 'userId', _userId);

      return AuthResult(success: true, userId: _userId, config: _config);
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    _config = null;
    _userId = '';
    await ProviderSettings.clearAuthConfig('feedly');
  }

  @override
  Future<bool> validateToken() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v3/profile'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Object? getStoredAuth() => _config;

  @override
  Future<List<Feed>> getFeeds() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v3/subscriptions'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((sub) {
        final s = sub as Map<String, dynamic>;
        return Feed(
          id: s['id'] as String? ?? '',
          title: s['title'] as String? ?? '',
          siteUrl: s['website'] as String?,
          iconUrl: s['iconUrl'] as String?,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v3/categories'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final list = jsonDecode(response.body) as List<dynamic>;
      return list.map((cat) {
        final c = cat as Map<String, dynamic>;
        final id = c['id'] as String? ?? '';
        return Category(
          id: id,
          name: c['label'] as String? ?? id,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

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
    try {
      var url =
          '$_baseUrl/v3/streams/contents?streamId=${Uri.encodeComponent(streamId)}&count=$limit';
      if (continuation != null) url += '&continuation=$continuation';

      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) {
        return ArticleListResult(articles: []);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];
      final cont = data['continuation'] as String?;

      final articles = items.map((item) => _parseArticle(item)).toList();
      return ArticleListResult(articles: articles, continuation: cont);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/v3/markers/counts'),
        headers: _headers,
      );
      if (response.statusCode != 200) return {};

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final counts = data['unreadcounts'] as List<dynamic>? ?? [];

      return {
        for (final item in counts)
          if (item['id'] != null && item['count'] != null)
            item['id'] as String: (item['count'] as num).toInt(),
      };
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> markAsRead(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrl/v3/markers'),
      headers: _headers,
      body: jsonEncode({
        'action': 'markAsRead',
        'type': 'entries',
        'entryIds': [articleId],
      }),
    );
  }

  @override
  Future<void> markAsUnread(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrl/v3/markers'),
      headers: _headers,
      body: jsonEncode({
        'action': 'keepUnread',
        'type': 'entries',
        'entryIds': [articleId],
      }),
    );
  }

  @override
  Future<void> starArticle(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrl/v3/markers'),
      headers: _headers,
      body: jsonEncode({
        'action': 'markAsSaved',
        'type': 'entries',
        'entryIds': [articleId],
      }),
    );
  }

  @override
  Future<void> unstarArticle(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrl/v3/markers'),
      headers: _headers,
      body: jsonEncode({
        'action': 'markAsUnsaved',
        'type': 'entries',
        'entryIds': [articleId],
      }),
    );
  }

  @override
  Future<ArticleListResult> getStarredArticles({
    int limit = 20,
    String? continuation,
  }) async {
    return getArticles(
      streamId: 'user/$_userId/tag/global.saved',
      limit: limit,
      continuation: continuation,
    );
  }

  @override
  Future<FeedResult> addFeed(String feedUrl, {String? category}) async =>
      FeedResult(success: false, error: 'Adicionar feed não disponível para Feedly nesta versão');

  @override
  Future<void> removeFeed(String feedId) =>
      throw UnsupportedError('Remover feed não suportado para Feedly');

  @override
  Future<void> renameFeed(String feedId, String newTitle) =>
      throw UnsupportedError('Renomear feed não suportado para Feedly');

  @override
  Future<void> moveFeed(String feedId, String? categoryId) =>
      throw UnsupportedError('Mover feed não suportado para Feedly');

  @override
  Future<CategoryResult> createCategory(String name) async =>
      CategoryResult(success: false, error: 'Criar categoria não disponível para Feedly nesta versão');

  @override
  Future<void> renameCategory(String categoryId, String newName) =>
      throw UnsupportedError('Renomear categoria não suportado para Feedly');

  @override
  Future<void> deleteCategory(String categoryId) =>
      throw UnsupportedError('Deletar categoria não suportado para Feedly');

  @override
  Future<Article?> getArticle(String articleId) async => null;

  @override
  Future<List<Article>> getArticlesByIds(List<String> ids) async => [];

  @override
  Future<void> markAllAsRead(String streamId, {DateTime? before}) async {}

  @override
  Future<ArticleListResult> search(
    String query, {
    int limit = 20,
    String? continuation,
  }) async =>
      ArticleListResult(articles: [], continuation: null);

  @override
  Future<String> exportOpml() async => '';

  @override
  Future<OpmlImportResult> importOpml(String opmlContent) async =>
      OpmlImportResult(success: false, errors: ['OPML não suportado para Feedly']);

  @override
  Future<Map<String, dynamic>> getPreferences() async => {};

  @override
  Future<void> setPreference(String key, String value) async {}

  // --- Private helpers ---

  Article _parseArticle(dynamic item) {
    final m = item as Map<String, dynamic>;
    final tags = (m['tags'] as List<dynamic>? ?? []);
    final isStarred = tags.any((t) {
      final tagId = t['id'] as String? ?? '';
      return tagId.contains('global.saved');
    });

    final canonical = m['canonical'] as List<dynamic>?;
    final url = canonical != null && canonical.isNotEmpty
        ? (canonical[0] as Map<String, dynamic>)['href'] as String? ?? ''
        : '';

    final content = (m['content'] as Map<String, dynamic>?)?['content'] as String? ??
        (m['summary'] as Map<String, dynamic>?)?['content'] as String? ??
        '';

    final published = m['published'] != null
        ? DateTime.fromMillisecondsSinceEpoch(m['published'] as int)
        : null;

    return Article(
      id: m['id'] as String? ?? '',
      feedId: (m['origin'] as Map<String, dynamic>?)?['streamId'] as String? ?? '',
      title: m['title'] as String? ?? '',
      author: m['author'] as String? ?? '',
      content: content,
      url: url,
      published: published,
      isRead: !(m['unread'] as bool? ?? false),
      isStarred: isStarred,
    );
  }
}
