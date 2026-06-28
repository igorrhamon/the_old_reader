import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;

class OldReaderApi {
  final String authToken;

  OldReaderApi(this.authToken);

  // ---------------------------------------------------------------------------
  // Base URL - native usa API direta, web usa proxy por causa de CORS
  // ---------------------------------------------------------------------------

  static int _proxyPort = 3000;
  static final String _nativeBase = 'https://theoldreader.com/reader/api/0';
  static String _webBase = 'http://localhost:$_proxyPort/proxy';
  static String? _overrideBaseUrl;

  static String get baseUrl => _overrideBaseUrl ?? (kIsWeb ? _webBase : _nativeBase);

  static void setProxyPort(int port) {
    _proxyPort = port;
    if (kIsWeb) _webBase = 'http://localhost:$port/proxy';
    debugPrint('Proxy URL atualizada para: $port');
  }

  static void setOverrideBaseUrl(String url) {
    _overrideBaseUrl = url;
    debugPrint('Base URL sobrescrita para: $url');
  }

  static void clearOverrideBaseUrl() {
    _overrideBaseUrl = null;
  }

  static String get authBaseUrl {
    if (_overrideBaseUrl != null) return _overrideBaseUrl!;
    return kIsWeb ? 'http://localhost:$_proxyPort/proxy' : 'https://theoldreader.com';
  }

  // ---------------------------------------------------------------------------
  // Headers
  // ---------------------------------------------------------------------------

  Map<String, String> _headers() => {
    'Authorization': 'GoogleLogin auth=$authToken',
  };

  Map<String, String> _headersWithContentType() => {
    ..._headers(),
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  // ---------------------------------------------------------------------------
  // User & preferences
  // ---------------------------------------------------------------------------

  Future<http.Response> getUserInfo() async {
    final url = Uri.parse('$baseUrl/user-info?output=json');
    return http.get(url, headers: _headers());
  }

  Future<http.Response> getPreferences() async {
    final url = Uri.parse('$baseUrl/preference/list?output=json');
    return http.get(url, headers: _headers());
  }

  // ---------------------------------------------------------------------------
  // Subscriptions
  // ---------------------------------------------------------------------------

  Future<http.Response> getSubscriptions() async {
    final url = Uri.parse('$baseUrl/subscription/list?output=json');
    return http.get(url, headers: _headers());
  }

  Future<http.Response> addSubscription(String feedUrl) async {
    final encodedFeedUrl = Uri.encodeComponent(feedUrl);
    final url = Uri.parse(
      '$baseUrl/subscription/quickadd?quickadd=$encodedFeedUrl',
    );
    return http.post(url, headers: _headersWithContentType());
  }

  Future<http.Response> editSubscription({
    required String streamId,
    String? title,
    String? addLabel,
    String? removeLabel,
  }) async {
    final url = Uri.parse('$baseUrl/subscription/edit');
    final params = <String, String>{'ac': 'edit', 's': streamId};
    if (title != null) params['t'] = title;
    if (addLabel != null) params['a'] = addLabel;
    if (removeLabel != null) params['r'] = removeLabel;
    final body = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  Future<http.Response> removeSubscription(String streamId) async {
    final url = Uri.parse('$baseUrl/subscription/edit');
    final body = 'ac=unsubscribe&s=${Uri.encodeComponent(streamId)}';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  // ---------------------------------------------------------------------------
  // Unread counts
  // ---------------------------------------------------------------------------

  Future<http.Response> getUnreadCounts() async {
    final url = Uri.parse('$baseUrl/unread-count?output=json');
    return http.get(url, headers: _headers());
  }

  // ---------------------------------------------------------------------------
  // Tags / categories
  // ---------------------------------------------------------------------------

  Future<http.Response> getTags() async {
    final url = Uri.parse('$baseUrl/tag/list?output=json');
    return http.get(url, headers: _headers());
  }

  Future<http.Response> renameTag({
    required String from,
    required String to,
  }) async {
    final url = Uri.parse('$baseUrl/rename-tag');
    final body = 's=${Uri.encodeComponent(from)}&dest=${Uri.encodeComponent(to)}';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  Future<http.Response> removeTag(String tag) async {
    final url = Uri.parse('$baseUrl/disable-tag');
    final body = 's=${Uri.encodeComponent(tag)}';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  List<String> extractCategoriesFromTagsResponse(http.Response response) {
    if (response.statusCode != 200) return [];
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic>? tags = data['tags'];
      if (tags == null) return [];
      return tags
          .whereType<Map>()
          .where((t) => (t['id'] as String?)?.startsWith('user/-/label/') == true)
          .map((t) => (t['id'] as String).replaceFirst('user/-/label/', ''))
          .where((n) => n.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Erro ao extrair categorias: $e');
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final response = await getTags();
      return extractCategoriesFromTagsResponse(response);
    } catch (e) {
      debugPrint('Erro ao buscar categorias: $e');
      return [];
    }
  }

  Future<http.Response> addFeedToCategory({
    required String streamId,
    required String categoryName,
  }) async {
    return editSubscription(
      streamId: streamId,
      addLabel: 'user/-/label/$categoryName',
    );
  }

  Future<Map<String, dynamic>> addFeedWithCategory({
    required String feedUrl,
    String? categoryName,
  }) async {
    try {
      final addResponse = await addSubscription(feedUrl);
      if (addResponse.statusCode != 200) {
        return {
          'success': false,
          'error': 'Erro ao adicionar feed: ${addResponse.statusCode}',
          'response': addResponse,
        };
      }
      final Map<String, dynamic> responseData = jsonDecode(addResponse.body);
      if (responseData.containsKey('error')) {
        return {
          'success': false,
          'error': responseData['error'],
          'response': addResponse,
        };
      }
      if (!responseData.containsKey('streamId')) {
        return {
          'success': true,
          'warning': 'Feed adicionado, mas não foi possível extrair o streamId',
          'response': addResponse,
        };
      }
      final String streamId = responseData['streamId'];
      if (categoryName == null || categoryName.isEmpty) {
        return {'success': true, 'streamId': streamId, 'response': addResponse};
      }
      final categoryResponse = await addFeedToCategory(
        streamId: streamId,
        categoryName: categoryName,
      );
      if (categoryResponse.statusCode != 200) {
        return {
          'success': true,
          'warning': 'Feed adicionado, mas não foi possível atribuir à categoria',
          'streamId': streamId,
          'response': addResponse,
          'categoryResponse': categoryResponse,
        };
      }
      return {
        'success': true,
        'streamId': streamId,
        'response': addResponse,
        'categoryResponse': categoryResponse,
      };
    } catch (e) {
      return {'success': false, 'error': 'Erro ao processar requisição: $e'};
    }
  }

  Future<http.Response> createCategory(String categoryName) async {
    final subsResponse = await getSubscriptions();
    if (subsResponse.statusCode != 200) {
      throw Exception('Não foi possível buscar assinaturas para criar categoria');
    }
    final Map<String, dynamic> subsData = jsonDecode(subsResponse.body);
    final List<dynamic>? subscriptions = subsData['subscriptions'];
    if (subscriptions == null || subscriptions.isEmpty) {
      throw Exception('Não há assinaturas disponíveis para criar categoria');
    }
    final String streamId = subscriptions[0]['id'];
    return addFeedToCategory(streamId: streamId, categoryName: categoryName);
  }

  // ---------------------------------------------------------------------------
  // Stream contents & item IDs
  // ---------------------------------------------------------------------------

  Future<http.Response> getStreamContents({
    required String stream,
    int? n,
    String? r,
    String? c,
    int? nt,
    int? ot,
    String? exclude,
  }) async {
    final params = <String, String>{'output': 'json', 's': stream};
    if (n != null) params['n'] = n.toString();
    if (r != null) params['r'] = r;
    if (c != null) params['c'] = c;
    if (nt != null) params['nt'] = nt.toString();
    if (ot != null) params['ot'] = ot.toString();
    if (exclude != null) params['xt'] = exclude;
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final url = Uri.parse('$baseUrl/stream/contents?$query');
    return http.get(url, headers: _headers());
  }

  Future<http.Response> getItemIds({
    required String stream,
    String? exclude,
    int? n,
    String? r,
    String? c,
    int? nt,
    int? ot,
  }) async {
    final params = <String, String>{'s': stream, 'output': 'json'};
    if (exclude != null) params['xt'] = exclude;
    if (n != null) params['n'] = n.toString();
    if (r != null) params['r'] = r;
    if (c != null) params['c'] = c;
    if (nt != null) params['nt'] = nt.toString();
    if (ot != null) params['ot'] = ot.toString();
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final url = Uri.parse('$baseUrl/stream/items/ids?$query');
    return http.get(url, headers: _headers());
  }

  /// Busca conteúdo de itens por ID, com batching de 250
  Future<List<dynamic>> getItemsContentsApi(List<String> itemIds) async {
    if (itemIds.isEmpty) return [];
    const batchSize = 250;
    final results = <dynamic>[];
    for (var i = 0; i < itemIds.length; i += batchSize) {
      final batch = itemIds.sublist(
        i,
        i + batchSize > itemIds.length ? itemIds.length : i + batchSize,
      );
      final url = Uri.parse('$baseUrl/stream/items/contents?output=json');
      final body = batch.map((id) => 'i=${Uri.encodeComponent(id)}').join('&');
      final resp = await http.post(
        url,
        headers: _headersWithContentType(),
        body: body,
      );
      if (resp.statusCode == 200) {
        final jsonData = jsonDecode(resp.body);
        results.addAll(jsonData['items'] ?? []);
      }
    }
    return results;
  }

  Future<http.Response> getFeedItems(String feedId) async {
    final url = Uri.parse('$baseUrl/stream/contents?output=json&s=$feedId&n=20');
    return http.get(url, headers: _headers());
  }

  Future<http.Response> getFeedItemsXml(String feedId) async {
    final url = Uri.parse('$baseUrl/stream/contents/$feedId?n=20&output=xml');
    return http.get(url, headers: _headers());
  }

  Future<List<String>> getStarredItemIds() async {
    final url = Uri.parse(
      '$baseUrl/stream/items/ids?output=json&s=user/-/state/com.google/starred',
    );
    final resp = await http.get(url, headers: _headers());
    if (resp.statusCode == 200) {
      try {
        final jsonData = jsonDecode(resp.body);
        final List<dynamic>? itemRefs = jsonData['itemRefs'];
        if (itemRefs != null) {
          return itemRefs.map((e) => e['id'] as String).toList();
        }
      } catch (_) {}
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Edit-tag operations
  // ---------------------------------------------------------------------------

  Future<http.Response> editTag({
    required List<String> itemIds,
    String? add,
    String? remove,
    String? annotation,
  }) async {
    final url = Uri.parse('$baseUrl/edit-tag');
    final params = <String>[];
    for (final id in itemIds) {
      params.add('i=${Uri.encodeComponent(id)}');
    }
    if (add != null) params.add('a=${Uri.encodeComponent(add)}');
    if (remove != null) params.add('r=${Uri.encodeComponent(remove)}');
    if (annotation != null) {
      params.add('annotation=${Uri.encodeComponent(annotation)}');
    }
    return http.post(
      url,
      headers: _headersWithContentType(),
      body: params.join('&'),
    );
  }

  Future<http.Response> markAsRead(String itemId) async {
    final url = Uri.parse('$baseUrl/edit-tag');
    final body = 'i=${Uri.encodeComponent(itemId)}&a=user/-/state/com.google/read';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  Future<http.Response> markAsUnread(String itemId) async {
    final url = Uri.parse('$baseUrl/edit-tag');
    final body = 'i=${Uri.encodeComponent(itemId)}&r=user/-/state/com.google/read';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  Future<http.Response> markAllAsRead({required String stream, int? ts}) async {
    final url = Uri.parse('$baseUrl/mark-all-as-read');
    final params = <String, String>{'output': 'json', 's': stream};
    if (ts != null) params['ts'] = ts.toString();
    final body = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  Future<http.Response> addFavorite(String itemId) async {
    final url = Uri.parse('$baseUrl/edit-tag');
    final body = 'i=${Uri.encodeComponent(itemId)}&a=user/-/state/com.google/starred';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  Future<http.Response> removeFavorite(String itemId) async {
    final url = Uri.parse('$baseUrl/edit-tag');
    final body = 'i=${Uri.encodeComponent(itemId)}&r=user/-/state/com.google/starred';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> searchItems(String query, {int n = 20, String? c}) async {
    final params = <String, String>{
      'output': 'json',
      'q': query,
      'n': n.toString(),
    };
    if (c != null) params['c'] = c;
    final q = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final idsResp = await http.get(
      Uri.parse('$baseUrl/search/items/ids?$q'),
      headers: _headers(),
    );
    if (idsResp.statusCode != 200) return [];
    try {
      final data = jsonDecode(idsResp.body);
      final List<dynamic>? refs = data['itemRefs'];
      if (refs == null || refs.isEmpty) return [];
      final ids = refs.map((e) => e['id'] as String).toList();
      return getItemsContentsApi(ids);
    } catch (_) {
      return [];
    }
  }

  // ---------------------------------------------------------------------------
  // OPML export (via proxy to avoid CORS)
  // ---------------------------------------------------------------------------

  Future<http.Response> exportOpml() async {
    final url = Uri.parse('$baseUrl/reader/subscriptions/export');
    return http.get(url, headers: _headers());
  }

  // ---------------------------------------------------------------------------
  // Folder/Stream preferences
  // ---------------------------------------------------------------------------

  Future<http.Response> getStreamPreferences() async {
    final url = Uri.parse('$baseUrl/preference/stream/list?output=json');
    return http.get(url, headers: _headers());
  }

  Future<http.Response> setStreamPreferences({
    required String streamId,
    required Map<String, String> prefs,
  }) async {
    final url = Uri.parse('$baseUrl/preference/stream/set');
    final body = 's=${Uri.encodeComponent(streamId)}&${prefs.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Parses stream preferences into a map: streamId -> {order: int, ...}
  Future<Map<String, Map<String, dynamic>>> getStreamPreferencesAsMap() async {
    try {
      final resp = await getStreamPreferences();
      if (resp.statusCode != 200) return {};
      final data = jsonDecode(resp.body);
      final List<dynamic>? prefs = data['streamprefs'];
      if (prefs == null) return {};
      final result = <String, Map<String, dynamic>>{};
      for (final entry in prefs) {
        final id = entry['id'] as String?;
        final pref = entry['pref'] as Map<String, dynamic>?;
        if (id != null && pref != null) {
          result[id] = pref;
        }
      }
      return result;
    } catch (e) {
      debugPrint('Erro ao parsear stream preferences: $e');
      return {};
    }
  }

  // ---------------------------------------------------------------------------
  // Friends
  // ---------------------------------------------------------------------------

  Future<http.Response> getFriends() async {
    final url = Uri.parse('$baseUrl/friend/list?output=json');
    return http.get(url, headers: _headers());
  }

  Future<http.Response> editFriend({
    required String action,
    required String u,
  }) async {
    final url = Uri.parse('$baseUrl/friend/edit');
    final body = 'action=${Uri.encodeComponent(action)}&u=${Uri.encodeComponent(u)}';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }

  // ---------------------------------------------------------------------------
  // Comments
  // ---------------------------------------------------------------------------

  Future<http.Response> addComment({
    required String itemId,
    required String comment,
  }) async {
    final url = Uri.parse('$baseUrl/comment/edit');
    final body =
        'action=addcomment&i=${Uri.encodeComponent(itemId)}&comment=${Uri.encodeComponent(comment)}';
    return http.post(url, headers: _headersWithContentType(), body: body);
  }
}







