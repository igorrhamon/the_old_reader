import '../feed_provider.dart';
import '../../services/old_reader_api.dart';
import '../../models/feed.dart';
import '../../models/article.dart';
import '../../models/category.dart';
import '../auth/auth_config.dart';
import 'package:xml/xml.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TheOldReaderProvider implements FeedProvider {
  OldReaderApi? _api;
  GoogleLoginAuthConfig? _config;

  TheOldReaderProvider();

  OldReaderApi get api => _api ?? OldReaderApi('');
  
  @override
  String get providerId => 'theoldreader';
  
  @override
  String get displayName => 'The Old Reader';
  
  @override
  String get defaultBaseUrl => 'https://theoldreader.com/reader/api/0';
  
  @override
  bool get supportsWebProxy => true;
  
  @override
  List<AuthType> get supportedAuthTypes => [AuthType.googleLogin];

  @override
  Future<AuthResult> authenticate(Object config) async {
    try {
      final googleConfig = config as GoogleLoginAuthConfig;
      final url = Uri.parse('${OldReaderApi.authBaseUrl}/accounts/ClientLogin');
      final body = 'client=theoldreader_flutter_app&accountType=HOSTED_OR_GOOGLE&service=reader&Email=${Uri.encodeComponent(googleConfig.email)}&Passwd=${Uri.encodeComponent(googleConfig.password ?? '')}&output=json';
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = response.body;
        String? token;
        try {
          final json = data.startsWith('{') ? jsonDecode(data) : null;
          if (json != null && json['Auth'] != null) {
            token = json['Auth'];
          }
        } catch (_) {
          final match = RegExp(r'Auth=(.+)').firstMatch(data);
          if (match != null) token = match.group(1);
        }

        if (token != null && token.isNotEmpty) {
          final api = OldReaderApi(token);
          final userInfo = await api.getUserInfo();
          if (userInfo.statusCode == 200) {
            _api = api;
            _config = GoogleLoginAuthConfig(
              providerId: providerId,
              email: googleConfig.email,
              authToken: token,
            );
            return AuthResult(
              success: true,
              config: _config,
              userId: token,
            );
          }
        }
      }
      return AuthResult(success: false, error: 'Credenciais inválidas');
    } catch (e) {
      return AuthResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    _api = null;
    _config = null;
  }

  @override
  Future<bool> validateToken() async {
    if (_config == null) return false;
    try {
      final response = await api.getUserInfo();
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
      final response = await api.getSubscriptions();
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
      final result = await api.addFeedWithCategory(
        feedUrl: feedUrl,
        categoryName: category,
      );
      
      if (result['success'] == true) {
        return FeedResult(
          success: true,
          feedId: result['streamId'] as String?,
        );
      } else {
        return FeedResult(
          success: false,
          error: result['error'] as String?,
        );
      }
    } catch (e) {
      return FeedResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> removeFeed(String feedId) async {
    await api.removeSubscription(feedId);
  }

  @override
  Future<void> renameFeed(String feedId, String newTitle) async {
    await api.editSubscription(streamId: feedId, title: newTitle);
  }

  @override
  Future<void> moveFeed(String feedId, String? categoryId) async {
    if (categoryId != null) {
      await api.editSubscription(streamId: feedId, addLabel: 'user/-/label/$categoryId');
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final names = await api.getCategories();
      return names.map((name) => Category(
        id: 'user/-/label/$name',
        name: name,
      )).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<CategoryResult> createCategory(String name) async {
    try {
      await api.createCategory(name);
      return CategoryResult(
        success: true,
        categoryId: 'user/-/label/$name',
        category: Category(id: 'user/-/label/$name', name: name),
      );
    } catch (e) {
      return CategoryResult(success: false, error: e.toString());
    }
  }

  @override
  Future<void> renameCategory(String categoryId, String newName) async {
    final oldName = categoryId.replaceFirst('user/-/label/', '');
    await api.renameTag(from: 'user/-/label/$oldName', to: 'user/-/label/$newName');
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await api.removeTag(categoryId);
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
      final response = await api.getStreamContents(
        stream: streamId,
        n: limit,
        c: continuation,
        exclude: excludeRead ? 'user/-/state/com.google/read' : null,
        include: includeOnlyRead ? 'user/-/state/com.google/read' : null,
      );

      if (response.statusCode != 200) {
        return ArticleListResult(articles: []);
      }

      final (items, cont) = _parseAtom(response.body);
      final articles = items.map((item) => Article(
        id: item['id'] as String? ?? '',
        feedId: streamId,
        title: item['title'] as String? ?? '',
        author: item['author'] as String? ?? '',
        summary: item['summary'] as String? ?? '',
        content: item['content'] as String? ?? '',
        url: item['url'] as String? ?? '',
        published: item['published'] != null ? DateTime.tryParse(item['published'].toString()) : null,
        categories: (item['categories'] as List<dynamic>? ?? []).cast<String>(),
        isRead: (item['categories'] as List<dynamic>? ?? []).contains('user/-/state/com.google/read'),
        isStarred: (item['categories'] as List<dynamic>? ?? []).contains('user/-/state/com.google/starred'),
      )).toList();
      return ArticleListResult(
        articles: articles,
        continuation: cont,
      );
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
      final items = await api.getItemsContentsApi(ids);
      return items.map((item) {
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
          feedId: '',
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
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> markAsRead(String articleId) async {
    await api.markAsRead(articleId);
  }

  @override
  Future<void> markAsUnread(String articleId) async {
    await api.markAsUnread(articleId);
  }

  @override
  Future<void> markAllAsRead(String streamId, {DateTime? before}) async {
    await api.markAllAsRead(stream: streamId);
  }

  @override
  Future<void> starArticle(String articleId) async {
    await api.addFavorite(articleId);
  }

  @override
  Future<void> unstarArticle(String articleId) async {
    await api.removeFavorite(articleId);
  }

  @override
  Future<Map<String, int>> getUnreadCounts() async {
    try {
      final response = await api.getUnreadCounts();
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
      final items = await api.searchItems(query, n: limit, c: continuation);
      final articles = items.map((item) {
        final m = item as Map<String, dynamic>;
        final categories = (m['categories'] as List<dynamic>? ?? [])
            .map((c) => c.toString())
            .toList();
        return Article(
          id: m['id'] as String? ?? '',
          feedId: '',
          title: _extractText(m['title']),
          author: m['author'] as String? ?? '',
          summary: _extractText(m['summary']),
          content: _extractText(m['content']),
          categories: categories,
          isRead: categories.contains('user/-/state/com.google/read'),
          isStarred: categories.contains('user/-/state/com.google/starred'),
        );
      }).toList();
      return ArticleListResult(articles: articles);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<ArticleListResult> getStarredArticles({int limit = 20, String? continuation}) async {
    try {
      final ids = await api.getStarredItemIds();
      final articles = await getArticlesByIds(ids.take(limit).toList());
      return ArticleListResult(articles: articles);
    } catch (e) {
      return ArticleListResult(articles: []);
    }
  }

  @override
  Future<String> exportOpml() async {
    try {
      final response = await api.exportOpml();
      return response.body;
    } catch (e) {
      return '';
    }
  }

  @override
  Future<OpmlImportResult> importOpml(String opmlContent) async {
    return OpmlImportResult(success: false, errors: ['Import não suportado']);
  }

  @override
  Future<Map<String, dynamic>> getPreferences() async {
    try {
      final response = await api.getPreferences();
      if (response.statusCode != 200) return {};
      final data = _parseResponse(response.body);
      return data['prefs'] as Map<String, dynamic>? ?? {};
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> setPreference(String key, String value) async {
    await api.setStreamPreferences(streamId: key, prefs: {key: value});
  }

  Map<String, dynamic> _parseResponse(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    final doc = XmlDocument.parse(body);
    return _xmlObjectToMap(doc.rootElement);
  }

  Map<String, dynamic> _xmlObjectToMap(XmlElement element) {
    final map = <String, dynamic>{};
    for (final child in element.childElements) {
      final name = child.getAttribute('name') ?? '';
      if (child.name.local == 'string') {
        map[name] = child.innerText;
      } else if (child.name.local == 'number') {
        map[name] = num.tryParse(child.innerText) ?? 0;
      } else if (child.name.local == 'boolean') {
        map[name] = child.innerText == 'true';
      } else if (child.name.local == 'list') {
        map[name] = child.childElements.map((e) => _xmlObjectToMap(e)).toList();
      } else if (child.name.local == 'object') {
        map[name] = _xmlObjectToMap(child);
      }
    }
    return map;
  }

  (List<Map<String, dynamic>>, String?) _parseAtom(String body) {
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final continuation = data['continuation'] as String?;
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = rawItems.map((item) {
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
        return <String, dynamic>{
          'id': m['id'] as String? ?? '',
          'title': _extractText(m['title']),
          'author': m['author'] as String? ?? '',
          'summary': _extractText(m['summary']),
          'content': _extractText(m['content']),
          'published': m['published'],
          'categories': categories,
          'url': url,
        };
      }).toList();
      return (items, continuation);
    } catch (_) {}
    
    final doc = XmlDocument.parse(body);
    final continuation = doc.findAllElements('continuation').firstOrNull?.innerText;
    final items = doc.findAllElements('entry').map((entry) {
      final categories = entry
          .findElements('category')
          .map((c) => c.getAttribute('term') ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
      final link = entry
          .findElements('link')
          .where((l) => l.getAttribute('rel') == 'alternate')
          .firstOrNull
          ?.getAttribute('href') ?? '';
      return <String, dynamic>{
        'id': entry.findElements('id').firstOrNull?.innerText ?? '',
        'title': entry.findElements('title').firstOrNull?.innerText ?? '',
        'author': entry.findElements('author').firstOrNull
            ?.findElements('name').firstOrNull?.innerText ?? '',
        'summary': entry.findElements('summary').firstOrNull?.innerText ?? '',
        'content': entry.findElements('content').firstOrNull?.innerText ?? '',
        'published': entry.findElements('published').firstOrNull?.innerText,
        'categories': categories,
        'url': link,
      };
    }).toList();
    return (items, continuation);
  }

  String _extractText(dynamic obj) {
    if (obj == null) return '';
    if (obj is String) return obj;
    if (obj is Map) return (obj['content'] as String?) ?? '';
    return '';
  }
}