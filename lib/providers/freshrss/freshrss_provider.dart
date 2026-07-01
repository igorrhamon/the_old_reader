import 'dart:convert';
import 'package:http/http.dart' as http;
import '../feed_provider.dart';
import '../auth/auth_config.dart';
import '../../models/feed.dart';
import '../../models/article.dart';
import '../../models/category.dart';

class FreshRssProvider implements FeedProvider {
  String? _username;
  String? _password;
  String? _baseUrl;
  BasicAuthConfig? _config;

  FreshRssProvider();

  String get _baseUrlResolved => _baseUrl ?? 'https://freshrss.example.com/api/greader.php';

  Map<String, String> get _headers {
    final credentials = base64Encode(utf8.encode('$_username:$_password'));
    return {
      'Authorization': 'Basic $credentials',
      'Accept': 'application/json',
    };
  }

  @override
  String get providerId => 'freshrss';

  @override
  String get displayName => 'FreshRSS';

  @override
  String get defaultBaseUrl => 'https://freshrss.example.com/api/greader.php';

  @override
  bool get supportsWebProxy => true;

  @override
  List<AuthType> get supportedAuthTypes => [AuthType.basicAuth];

  @override
  Future<AuthResult> authenticate(Object config) async {
    try {
      final basicConfig = config as BasicAuthConfig;
      final baseUrl = basicConfig.baseUrl ?? defaultBaseUrl;
      final testUrl = Uri.parse('$baseUrl/user-info?n=1');
      final credentials = base64Encode(utf8.encode('${basicConfig.username}:${basicConfig.password}'));
      final response = await http.get(
        testUrl,
        headers: {
          'Authorization': 'Basic $credentials',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _username = basicConfig.username;
        _password = basicConfig.password;
        _baseUrl = baseUrl;
        _config = BasicAuthConfig(
          providerId: providerId,
          username: basicConfig.username,
          password: basicConfig.password,
          baseUrl: baseUrl,
        );
        return AuthResult(
          success: true,
          config: _config,
          userId: basicConfig.username,
        );
      }
      return AuthResult(success: false, error: 'Credenciais inválidas ou URL incorreta');
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    _username = null;
    _password = null;
    _baseUrl = null;
    _config = null;
  }

  @override
  Future<bool> validateToken() async {
    if (_username == null) return false;
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/user-info?n=1'),
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
        Uri.parse('$_baseUrlResolved/subscription/list?n=1000'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final data = _parseResponse(response.body);
      final subscriptions = data['subscriptions'] as List<dynamic>? ?? [];

      return subscriptions.map((sub) {
        final categories = (sub['categories'] as List<dynamic>? ?? [])
            .whereType<Map>()
            .where((c) => c['label'] is String)
            .map((c) => (c['label'] as String).replaceFirst('user/-/label/', ''))
            .where((n) => n.isNotEmpty)
            .toList();

        return Feed(
          id: sub['id'] as String? ?? '',
          title: sub['title'] as String? ?? 'Sem título',
          url: sub['url'] as String?,
          siteUrl: sub['htmlUrl'] as String?,
          categories: categories,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<FeedResult> addFeed(String feedUrl, {String? category}) async {
    try {
      final url = category != null
          ? '$_baseUrlResolved/subscription/quickadd?quickadd=${Uri.encodeComponent(feedUrl)}&s=user/-/label/${Uri.encodeComponent(category)}'
          : '$_baseUrlResolved/subscription/quickadd?quickadd=${Uri.encodeComponent(feedUrl)}';

      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = _parseResponse(response.body);
        return FeedResult(
          success: data['status'] == 'ok',
          feedId: data['streamId'] as String?,
          error: data['status'] != 'ok' ? data['status'] as String? : null,
        );
      }
      return FeedResult(success: false, error: 'Erro ao adicionar feed');
    } catch (e) {
      return FeedResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> removeFeed(String feedId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/subscription/edit?i=${Uri.encodeComponent(feedId)}&ac=unsubscribe'),
      headers: _headers,
    );
  }

  @override
  Future<void> renameFeed(String feedId, String newTitle) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/subscription/edit?i=${Uri.encodeComponent(feedId)}&ac=edit&t=${Uri.encodeComponent(newTitle)}'),
      headers: _headers,
    );
  }

  @override
  Future<void> moveFeed(String feedId, String? categoryId) async {
    if (categoryId != null) {
      await http.post(
        Uri.parse('$_baseUrlResolved/subscription/edit?i=${Uri.encodeComponent(feedId)}&ac=edit&a=${Uri.encodeComponent('user/-/label/$categoryId')}'),
        headers: _headers,
      );
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/tag/list'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final data = _parseResponse(response.body);
      final tags = data['tags'] as List<dynamic>? ?? [];

      return tags
          .where((tag) => tag['id'].toString().contains('user/-/label/'))
          .map((tag) {
        final id = tag['id'] as String;
        final name = id.replaceFirst('user/-/label/', '');
        return Category(id: id, name: name);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CategoryResult> createCategory(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrlResolved/edit-tag?a=${Uri.encodeComponent('user/-/label/$name')}&i=user/-/state/com.google/reading-list'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return CategoryResult(
          success: true,
          categoryId: 'user/-/label/$name',
          category: Category(id: 'user/-/label/$name', name: name),
        );
      }
      return CategoryResult(success: false, error: 'Erro ao criar categoria');
    } catch (e) {
      return CategoryResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> renameCategory(String categoryId, String newName) async {
    final oldName = categoryId.replaceFirst('user/-/label/', '');
    await http.post(
      Uri.parse('$_baseUrlResolved/rename-tag?s=${Uri.encodeComponent('user/-/label/$oldName')}&dest=${Uri.encodeComponent('user/-/label/$newName')}'),
      headers: _headers,
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/disable-tag?i=${Uri.encodeComponent(categoryId)}'),
      headers: _headers,
    );
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
      var url = '$_baseUrlResolved/stream/contents/${Uri.encodeComponent(streamId)}?n=$limit';
      if (continuation != null) url += '&c=$continuation';
      if (excludeRead) url += '&xt=user/-/state/com.google/read';

      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) {
        return ArticleListResult(articles: []);
      }

      final data = _parseResponse(response.body);
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final cont = data['continuation'] as String?;

      final articles = rawItems.map((item) => _parseArticle(item, streamId)).toList();
      return ArticleListResult(articles: articles, continuation: cont);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<Article?> getArticle(String articleId) async {
    try {
      final articles = await getArticlesByIds([articleId]);
      return articles.isNotEmpty ? articles.first : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Article>> getArticlesByIds(List<String> ids) async {
    try {
      final itemIds = ids.map((id) => 'i=$id').join('&');
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/stream/contents?$itemIds'),
        headers: _headers,
      );
      if (response.statusCode != 200) return [];

      final data = _parseResponse(response.body);
      final rawItems = data['items'] as List<dynamic>? ?? [];
      return rawItems.map((item) => _parseArticle(item, '')).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markAsRead(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/edit-tag?a=${Uri.encodeComponent('user/-/state/com.google/read')}&i=${Uri.encodeComponent(articleId)}'),
      headers: _headers,
    );
  }

  @override
  Future<void> markAsUnread(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/edit-tag?r=${Uri.encodeComponent('user/-/state/com.google/read')}&i=${Uri.encodeComponent(articleId)}'),
      headers: _headers,
    );
  }

  @override
  Future<void> markAllAsRead(String streamId, {DateTime? before}) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/mark-all-as-read?ts=0&s=${Uri.encodeComponent(streamId)}'),
      headers: _headers,
    );
  }

  @override
  Future<void> starArticle(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/edit-tag?a=${Uri.encodeComponent('user/-/state/com.google/starred')}&i=${Uri.encodeComponent(articleId)}'),
      headers: _headers,
    );
  }

  @override
  Future<void> unstarArticle(String articleId) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/edit-tag?r=${Uri.encodeComponent('user/-/state/com.google/starred')}&i=${Uri.encodeComponent(articleId)}'),
      headers: _headers,
    );
  }

  @override
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/unread-count?n=1000'),
        headers: _headers,
      );
      if (response.statusCode != 200) return {};

      final data = _parseResponse(response.body);
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
  Future<ArticleListResult> search(String query, {int limit = 20, String? continuation}) async {
    try {
      var url = '$_baseUrlResolved/search/contents?q=${Uri.encodeComponent(query)}&n=$limit';
      if (continuation != null) url += '&c=$continuation';

      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = _parseResponse(response.body);
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final articles = rawItems.map((item) => _parseArticle(item, '')).toList();
      return ArticleListResult(articles: articles, continuation: data['continuation'] as String?);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<ArticleListResult> getStarredArticles({int limit = 20, String? continuation}) async {
    try {
      var url = '$_baseUrlResolved/stream/contents/user/-/state/com.google/starred?n=$limit';
      if (continuation != null) url += '&c=$continuation';

      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode != 200) return ArticleListResult(articles: []);

      final data = _parseResponse(response.body);
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final articles = rawItems.map((item) => _parseArticle(item, 'user/-/state/com.google/starred')).toList();
      return ArticleListResult(articles: articles, continuation: data['continuation'] as String?);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<String> exportOpml() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/subscription/export'),
        headers: _headers,
      );
      return response.statusCode == 200 ? response.body : '';
    } catch (e) {
      return '';
    }
  }

  @override
  Future<OpmlImportResult> importOpml(String opmlContent) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrlResolved/subscription/import'),
      );
      final credentials = base64Encode(utf8.encode('$_username:$_password'));
      request.headers['Authorization'] = 'Basic $credentials';
      request.files.add(
        http.MultipartFile.fromString(
          'opml',
          opmlContent,
          filename: 'subscriptions.opml',
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        return OpmlImportResult(success: true);
      }
      return OpmlImportResult(success: false, errors: ['Erro ao importar OPML']);
    } catch (e) {
      return OpmlImportResult(success: false, errors: [e.toString()]);
    }
  }

  @override
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrlResolved/preference/list'),
        headers: _headers,
      );
      if (response.statusCode != 200) return {};
      final data = _parseResponse(response.body);
      return data['prefs'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> setPreference(String key, String value) async {
    await http.post(
      Uri.parse('$_baseUrlResolved/preference/set?key=$key&value=$value'),
      headers: _headers,
    );
  }

  Map<String, dynamic> _parseResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }

  Article _parseArticle(dynamic item, String streamId) {
    final m = item as Map<String, dynamic>;
    final categories = (m['categories'] as List<dynamic>? ?? [])
        .map((c) => c.toString())
        .toList();
    final alternates = m['alternate'] as List<dynamic>?;
    final canonicals = m['canonical'] as List<dynamic>?;
    final urlList = (alternates?.isNotEmpty == true ? alternates : canonicals) ?? [];
    final url = urlList.isNotEmpty
        ? (urlList[0] as Map<dynamic, dynamic>)['href'] as String? ?? ''
        : '';

    return Article(
      id: m['id'] as String? ?? '',
      feedId: streamId,
      title: _extractText(m['title']),
      author: m['author'] as String? ?? '',
      summary: _extractText(m['summary']),
      content: _extractText(m['content']),
      url: url,
      published: m['published'] != null ? DateTime.tryParse(m['published'].toString()) : null,
      categories: categories,
      isRead: categories.contains('user/-/state/com.google/read'),
      isStarred: categories.contains('user/-/state/com.google/starred'),
    );
  }

  String _extractText(dynamic obj) {
    if (obj == null) return '';
    if (obj is String) return obj;
    if (obj is Map) return (obj['content'] as String?) ?? '';
    return '';
  }
}
