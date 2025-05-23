import 'package:http/http.dart' as http;


class OldReaderApi {

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

  Map<String, String> _headers() => {
        'Authorization': 'GoogleLogin auth=$authToken',
      };
}
