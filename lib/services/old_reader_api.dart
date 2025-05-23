

import 'package:http/http.dart' as http;
import 'dart:convert';

class OldReaderApi {
    /// Busca favoritos (starred) via HTML web
  Future<String> getStarredItemsHtml({String? cookies}) async {
    final url = Uri.parse('http://localhost:3000/proxy/posts/starred');
    final headers = <String, String>{};
    if (cookies != null) headers['Cookie'] = cookies;
    final resp = await http.get(url, headers: headers);
    if (resp.statusCode == 200) {
      return resp.body;
    }
    throw Exception('Erro ao buscar favoritos em HTML: ${resp.statusCode}');
  }

  /// Busca informações do usuário autenticado
  Future<http.Response> getUserInfoApi() async {
    final url = Uri.parse('$baseUrl/user-info?output=json');
    return await http.get(url, headers: _headers());
  }

  /// Lista de preferências do usuário
  Future<http.Response> getPreferences() async {
    final url = Uri.parse('$baseUrl/preference/list?output=json');
    return await http.get(url, headers: _headers());
  }

  /// Lista de tags (pastas)
  Future<http.Response> getTags() async {
    final url = Uri.parse('$baseUrl/tag/list?output=json');
    return await http.get(url, headers: _headers());
  }

  /// Lista de amigos
  Future<http.Response> getFriends() async {
    final url = Uri.parse('$baseUrl/friend/list?output=json');
    return await http.get(url, headers: _headers());
  }

  /// Adiciona/Remove amigo
  Future<http.Response> editFriend({required String action, required String u}) async {
    final url = Uri.parse('$baseUrl/friend/edit');
    final body = 'action=$action&u=$u';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Adiciona comentário a um item
  Future<http.Response> addComment({required String itemId, required String comment}) async {
    final url = Uri.parse('$baseUrl/comment/edit');
    final body = 'action=addcomment&i=$itemId&comment=${Uri.encodeComponent(comment)}';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Renomeia uma pasta/tag
  Future<http.Response> renameTag({required String from, required String to}) async {
    final url = Uri.parse('$baseUrl/rename-tag');
    final body = 's=$from&dest=$to';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Remove uma pasta/tag
  Future<http.Response> removeTag(String tag) async {
    final url = Uri.parse('$baseUrl/disable-tag');
    final body = 's=$tag';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Exporta assinaturas em OPML
  Future<http.Response> exportOpml() async {
    final url = Uri.parse('https://theoldreader.com/reader/subscriptions/export');
    return await http.get(url, headers: _headers());
  }  /// Adiciona uma assinatura/feed
  Future<http.Response> addSubscription(String feedUrl) async {
    // IMPORTANTE: O parâmetro quickadd DEVE estar na query string da URL e NÃO no body
    
    // Garantimos que a URL do feed seja codificada corretamente
    final encodedFeedUrl = Uri.encodeComponent(feedUrl);
    
    // Constrói a URL com o parâmetro na query string
    final url = Uri.parse('$baseUrl/subscription/quickadd?quickadd=$encodedFeedUrl');
    
    print('URL para adicionar feed: ${url.toString()}');
    
    // POST sem body, pois o parâmetro quickadd já está na URL
    return await http.post(
      url,
      headers: _headersWithContentType(),
      // Importante: NÃO incluir body aqui, a API espera o parâmetro na URL
    );
  }

  /// Edita uma assinatura (título, pasta, etc)
  Future<http.Response> editSubscription({required String streamId, String? title, String? addLabel, String? removeLabel}) async {
    final url = Uri.parse('$baseUrl/subscription/edit');
    final params = <String, String>{'ac': 'edit', 's': streamId};
    if (title != null) params['t'] = title;
    if (addLabel != null) params['a'] = addLabel;
    if (removeLabel != null) params['r'] = removeLabel;
    final body = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Remove uma assinatura/feed
  Future<http.Response> removeSubscription(String streamId) async {
    final url = Uri.parse('$baseUrl/subscription/edit');
    final body = 'ac=unsubscribe&s=$streamId';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Busca IDs de itens de qualquer stream
  Future<http.Response> getItemIds({required String stream, String? exclude, int? n, String? r, String? c, int? nt, int? ot}) async {
    final params = <String, String>{'s': stream, 'output': 'json'};
    if (exclude != null) params['xt'] = exclude;
    if (n != null) params['n'] = n.toString();
    if (r != null) params['r'] = r;
    if (c != null) params['c'] = c;
    if (nt != null) params['nt'] = nt.toString();
    if (ot != null) params['ot'] = ot.toString();
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final url = Uri.parse('$baseUrl/stream/items/ids?$query');
    return await http.get(url, headers: _headers());
  }

  /// Busca conteúdo de stream (feed, pasta, etc)
  Future<http.Response> getStreamContents({required String stream, int? n, String? r, String? c, int? nt, int? ot}) async {
    final params = <String, String>{'output': 'json', 's': stream};
    if (n != null) params['n'] = n.toString();
    if (r != null) params['r'] = r;
    if (c != null) params['c'] = c;
    if (nt != null) params['nt'] = nt.toString();
    if (ot != null) params['ot'] = ot.toString();
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    final url = Uri.parse('$baseUrl/stream/contents?$query');
    return await http.get(url, headers: _headers());
  }

  /// Marca todos como lido
  Future<http.Response> markAllAsRead({required String stream, int? ts}) async {
    final url = Uri.parse('$baseUrl/mark-all-as-read');
    final params = <String, String>{'s': stream};
    if (ts != null) params['ts'] = ts.toString();
    final body = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Edita tags de itens (marcar como lido, favorito, etc)
  Future<http.Response> editTag({required List<String> itemIds, String? add, String? remove, String? annotation}) async {
    final url = Uri.parse('$baseUrl/edit-tag');
    final params = <String>[];
    for (final id in itemIds) {
      params.add('i=${Uri.encodeComponent(id)}');
    }
    if (add != null) params.add('a=$add');
    if (remove != null) params.add('r=$remove');
    if (annotation != null) params.add('annotation=${Uri.encodeComponent(annotation)}');
    final body = params.join('&');
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Busca os itens favoritos (starred) do usuário
  Future<http.Response> getStarredItems() async {
    // s=user/-/state/com.google/starred retorna os itens favoritos
    final url = Uri.parse('$baseUrl/stream/contents/user/-/state/com.google/starred?output=json');
    return await http.get(url, headers: _headers());
  }

  /// Marca um artigo como favorito (starred) na Old Reader API
  Future<http.Response> addFavorite(String itemId) async {
    final url = Uri.parse('$baseUrl/edit-tag');
    final body = 'i=$itemId&a=user/-/state/com.google/starred';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Remove o favorito (starred) de um artigo na Old Reader API
  Future<http.Response> removeFavorite(String itemId) async {
    final url = Uri.parse('$baseUrl/edit-tag');
    final body = 'i=$itemId&r=user/-/state/com.google/starred';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  Map<String, String> _headersWithContentType() => {
    ..._headers(),
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  Future<http.Response> getFeedItems(String feedId) async {
    // O endpoint correto para buscar itens de um feed é /stream/contents/{feedId}
    final url = Uri.parse('$baseUrl/stream/contents/$feedId?n=20');
    return await http.get(url, headers: _headers());
  }

  /// Busca itens do feed em formato XML (força output=xml)
  Future<http.Response> getFeedItemsXml(String feedId) async {
    final url = Uri.parse('$baseUrl/stream/contents/$feedId?n=20&output=xml');
    return await http.get(url, headers: _headers());
  }
  // Use o proxy local para evitar CORS no Flutter Web
  static const String baseUrl = 'http://localhost:3000/proxy';

  final String authToken;

  OldReaderApi(this.authToken);


  Future<http.Response> getUserInfo() async {
    final url = Uri.parse('$baseUrl/user-info');
    return await http.get(url, headers: _headers());
  }

  Future<http.Response> getSubscriptions() async {
    final url = Uri.parse('$baseUrl/subscription/list');
    return await http.get(url, headers: _headers());
  }

  Future<http.Response> getUnreadCounts() async {
    final url = Uri.parse('$baseUrl/unread-count');
    return await http.get(url, headers: _headers());
  }

  /// Retorna as IDs dos itens favoritados (starred) usando o endpoint oficial
  Future<List<String>> getStarredItemIdsApi() async {
    final urlJson = Uri.parse('$baseUrl/stream/items/ids?output=json&s=user/-/state/com.google/starred');
    final urlXml = Uri.parse('$baseUrl/stream/items/ids?s=user/-/state/com.google/starred');
    final resp = await http.get(urlJson, headers: _headers());
    if (resp.statusCode == 200) {
      try {
        final jsonData = jsonDecode(resp.body);
        final List<dynamic>? itemRefs = jsonData['itemRefs'];
        if (itemRefs == null) return [];
        return itemRefs.map((e) => e['id'] as String).toList();
      } catch (e) {
        // Se não for JSON válido, tenta XML
      }
    }
    // Tenta XML se JSON falhar
    final respXml = await http.get(urlXml, headers: _headers());
    if (respXml.statusCode == 200) {
      // Aqui você pode fazer um parse simples do XML para extrair os IDs, se necessário
      // Exemplo: extrair todos os <id>...</id> usando regex
      final xml = respXml.body;
      final regex = RegExp(r'<id>([^<]+)</id>');
      final matches = regex.allMatches(xml);
      return matches.map((m) => m.group(1) ?? '').where((id) => id.isNotEmpty).toList();
    }
    return [];
  }

  /// Retorna o conteúdo (artigos) de uma lista de item IDs
  Future<List<dynamic>> getItemsContentsApi(List<String> itemIds) async {
    if (itemIds.isEmpty) return [];
    final url = Uri.parse('$baseUrl/stream/items/contents?output=json');
    // Monta o body com todos os parâmetros "i=<itemId>"
    final body = itemIds.map((id) => 'i=${Uri.encodeComponent(id)}').join('&');
    final resp = await http.post(url, headers: _headersWithContentType(), body: body);
    if (resp.statusCode == 200) {
      final jsonData = jsonDecode(resp.body);
      // A propriedade "items" contém os artigos
      return jsonData['items'] ?? [];
    }
    return [];
  }

  Map<String, String> _headers() => {
        'Authorization': 'GoogleLogin auth=$authToken',
      };
}
