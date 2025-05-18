import 'package:http/http.dart' as http;


class OldReaderApi {

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
