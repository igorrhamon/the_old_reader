import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
// Import the proxy configuration

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
  Future<http.Response> editFriend({
    required String action,
    required String u,
  }) async {
    final url = Uri.parse('$baseUrl/friend/edit');
    final body = 'action=$action&u=$u';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Adiciona comentário a um item
  Future<http.Response> addComment({
    required String itemId,
    required String comment,
  }) async {
    final url = Uri.parse('$baseUrl/comment/edit');
    final body =
        'action=addcomment&i=$itemId&comment=${Uri.encodeComponent(comment)}';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Renomeia uma pasta/tag
  Future<http.Response> renameTag({
    required String from,
    required String to,
  }) async {
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
    final url = Uri.parse(
      'https://theoldreader.com/reader/subscriptions/export',
    );
    return await http.get(url, headers: _headers());
  }

  /// Adiciona uma assinatura/feed
  Future<http.Response> addSubscription(String feedUrl) async {
    // IMPORTANTE: O parâmetro quickadd DEVE estar na query string da URL e NÃO no body

    // Garantimos que a URL do feed seja codificada corretamente
    final encodedFeedUrl = Uri.encodeComponent(feedUrl);
    // Constrói a URL com o parâmetro na query string
    final url = Uri.parse(
      '$baseUrl/subscription/quickadd?quickadd=$encodedFeedUrl',
    );

    debugPrint('URL para adicionar feed: ${url.toString()}');

    // POST sem body, pois o parâmetro quickadd já está na URL
    return await http.post(
      url,
      headers: _headersWithContentType(),
      // Importante: NÃO incluir body aqui, a API espera o parâmetro na URL
    );
  }

  /// Edita uma assinatura (título, pasta, etc)
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
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Remove uma assinatura/feed
  Future<http.Response> removeSubscription(String streamId) async {
    final url = Uri.parse('$baseUrl/subscription/edit');
    final body = 'ac=unsubscribe&s=$streamId';
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Busca IDs de itens de qualquer stream
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
    return await http.get(url, headers: _headers());
  }

  /// Busca conteúdo de stream (feed, pasta, etc)
  Future<http.Response> getStreamContents({
    required String stream,
    int? n,
    String? r,
    String? c,
    int? nt,
    int? ot,
  }) async {
    final params = <String, String>{'output': 'json', 's': stream};
    if (n != null) params['n'] = n.toString();
    if (r != null) params['r'] = r;
    if (c != null) params['c'] = c;
    if (nt != null) params['nt'] = nt.toString();
    if (ot != null) params['ot'] = ot.toString();
    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    final url = Uri.parse('$baseUrl/stream/contents?$query');
    return await http.get(url, headers: _headers());
  }

  /// Marca todos como lido
  Future<http.Response> markAllAsRead({required String stream, int? ts}) async {
    final url = Uri.parse('$baseUrl/mark-all-as-read');
    final params = <String, String>{'s': stream};
    if (ts != null) params['ts'] = ts.toString();
    final body = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Edita tags de itens (marcar como lido, favorito, etc)
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
    if (add != null) params.add('a=$add');
    if (remove != null) params.add('r=$remove');
    if (annotation != null) {
      params.add('annotation=${Uri.encodeComponent(annotation)}');
    }
    final body = params.join('&');
    return await http.post(url, headers: _headersWithContentType(), body: body);
  }

  /// Busca os itens favoritos (starred) do usuário
  Future<http.Response> getStarredItems() async {
    // s=user/-/state/com.google/starred retorna os itens favoritos
    final url = Uri.parse(
      '$baseUrl/stream/contents/user/-/state/com.google/starred?output=json',
    );
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
  // A porta é configurada pelo proxy_config.dart
  static String baseUrl = '${getProxyBaseUrl()}/proxy';

  // Permite mudar a porta do proxy em tempo de execução
  static void setProxyPort(int port) {
    // Atualiza a porta do proxy e a baseUrl
    baseUrl = '${getProxyBaseUrl()}/proxy';
    debugPrint('Proxy URL atualizada para: $baseUrl');
  }

  // Inicializa a API usando a configuração de proxy atual
  static void initializeProxy() {
    baseUrl = '${getProxyBaseUrl()}/proxy';
    debugPrint('API inicializada com proxy URL: $baseUrl');
  }

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
    final urlJson = Uri.parse(
      '$baseUrl/stream/items/ids?output=json&s=user/-/state/com.google/starred',
    );
    final urlXml = Uri.parse(
      '$baseUrl/stream/items/ids?s=user/-/state/com.google/starred',
    );
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
      return matches
          .map((m) => m.group(1) ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
    }
    return [];
  }

  /// Retorna o conteúdo (artigos) de uma lista de item IDs
  Future<List<dynamic>> getItemsContentsApi(List<String> itemIds) async {
    if (itemIds.isEmpty) return [];
    final url = Uri.parse('$baseUrl/stream/items/contents?output=json');
    // Monta o body com todos os parâmetros "i=<itemId>"
    final body = itemIds.map((id) => 'i=${Uri.encodeComponent(id)}').join('&');
    final resp = await http.post(
      url,
      headers: _headersWithContentType(),
      body: body,
    );
    if (resp.statusCode == 200) {
      final jsonData = jsonDecode(resp.body);
      // A propriedade "items" contém os artigos
      return jsonData['items'] ?? [];
    }
    return [];
  }

  /// Extrai categorias (labels) de uma resposta da API de tags
  List<String> extractCategoriesFromTagsResponse(http.Response response) {
    if (response.statusCode != 200) {
      return [];
    }
    
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic>? tags = data['tags'];
      
      if (tags == null) {
        return [];
      }
      
      // Filtrar apenas tags que são categorias (começam com "user/-/label/")
      final List<String> categories = [];
      
      for (var tag in tags) {
        if (tag is Map && tag.containsKey('id')) {
          final String tagId = tag['id'];
          
          if (tagId.startsWith('user/-/label/')) {
            // Extrair o nome da categoria do ID da tag
            final String categoryName = tagId.replaceFirst('user/-/label/', '');
            if (categoryName.isNotEmpty) {
              categories.add(categoryName);
            }
          }
        }
      }
      
      return categories;
    } catch (e) {
      debugPrint('Erro ao extrair categorias: $e');
      return [];
    }
  }

  /// Busca todas as categorias
  Future<List<String>> getCategories() async {
    try {
      final response = await getTags();
      return extractCategoriesFromTagsResponse(response);
    } catch (e) {
      debugPrint('Erro ao buscar categorias: $e');
      return [];
    }
  }

  /// Adiciona um feed a uma categoria
  Future<http.Response> addFeedToCategory({
    required String streamId,
    required String categoryName,
  }) async {
    // Formatar o ID da categoria conforme esperado pela API
    final String categoryId = 'user/-/label/$categoryName';
    
    // Usar o método editSubscription para adicionar a categoria
    return await editSubscription(
      streamId: streamId,
      addLabel: categoryId,
    );
  }

  /// Adicionar um feed e opcionalmente atribuir a uma categoria
  Future<Map<String, dynamic>> addFeedWithCategory({
    required String feedUrl,
    String? categoryName,
  }) async {
    try {
      // Primeiro adicionar o feed
      final addResponse = await addSubscription(feedUrl);
      
      if (addResponse.statusCode != 200) {
        return {
          'success': false,
          'error': 'Erro ao adicionar feed: ${addResponse.statusCode}',
          'response': addResponse,
        };
      }
      
      // Tentar extrair o streamId da resposta
      final Map<String, dynamic> responseData = jsonDecode(addResponse.body);
      
      // Verificar se há erro na resposta
      if (responseData.containsKey('error')) {
        return {
          'success': false,
          'error': responseData['error'],
          'response': addResponse,
        };
      }
      
      // Verificar se temos o streamId
      if (!responseData.containsKey('streamId')) {
        return {
          'success': true,
          'warning': 'Feed adicionado, mas não foi possível extrair o streamId',
          'response': addResponse,
        };
      }
      
      final String streamId = responseData['streamId'];
      
      // Se não tiver categoria, retornar sucesso
      if (categoryName == null || categoryName.isEmpty) {
        return {
          'success': true,
          'streamId': streamId,
          'response': addResponse,
        };
      }
      
      // Adicionar o feed à categoria
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
      
      // Sucesso completo
      return {
        'success': true,
        'streamId': streamId,
        'response': addResponse,
        'categoryResponse': categoryResponse,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Erro ao processar requisição: $e',
      };
    }
  }

  /// Cria uma nova categoria
  Future<http.Response> createCategory(String categoryName) async {
    // A Old Reader API não tem um endpoint específico para criar categorias.
    // Categorias são criadas implicitamente quando um feed é atribuído a uma nova categoria.
    // Podemos usar um truque: editar um feed existente e adicionar a nova categoria.
    
    // Primeiro, vamos buscar todas as assinaturas
    final subsResponse = await getSubscriptions();
    
    if (subsResponse.statusCode != 200) {
      throw Exception('Não foi possível buscar assinaturas para criar categoria');
    }
    
    final Map<String, dynamic> subsData = jsonDecode(subsResponse.body);
    final List<dynamic>? subscriptions = subsData['subscriptions'];
    
    if (subscriptions == null || subscriptions.isEmpty) {
      throw Exception('Não há assinaturas disponíveis para criar categoria');
    }
    
    // Usar a primeira assinatura para criar a categoria
    final String streamId = subscriptions[0]['id'];
    
    // Adicionar a categoria ao feed
    return await addFeedToCategory(
      streamId: streamId,
      categoryName: categoryName,
    );
  }

  Map<String, String> _headers() => {
    'Authorization': 'GoogleLogin auth=$authToken',
  };

  static getProxyBaseUrl() {
    // Retorna a URL base do proxy configurado
    if (kIsWeb) {
      return 'http://localhost:3000'; // URL do proxy local para Flutter Web
    } else {
      return 'http://localhost:3000'; // URL do proxy local para Flutter Mobile/Desktop
    }
  }
}
