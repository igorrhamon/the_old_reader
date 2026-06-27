import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:the_old_reader/services/old_reader_api.dart';

http.Response _jsonResponse(dynamic body, {int status = 200}) {
  return http.Response(jsonEncode(body), status, headers: {
    'Content-Type': 'application/json',
  });
}

void main() {
  group('OldReaderApi', () {
    setUp(() {
      OldReaderApi.setProxyPort(3000);
    });

    group('proxy config', () {
      test('getProxyBaseUrl retorna URL com porta padrão', () {
        OldReaderApi.setProxyPort(3000);
        expect(OldReaderApi.getProxyBaseUrl(), 'http://localhost:3000');
      });

      test('setProxyPort altera a URL', () {
        OldReaderApi.setProxyPort(9999);
        expect(OldReaderApi.getProxyBaseUrl(), 'http://localhost:9999');
      });

      test('initializeProxy define baseUrl com /proxy', () {
        OldReaderApi.setProxyPort(3000);
        OldReaderApi.initializeProxy();
        expect(OldReaderApi.baseUrl, 'http://localhost:3000/proxy');
      });

      test('setProxyPort atualiza baseUrl dinamicamente', () {
        OldReaderApi.setProxyPort(4000);
        OldReaderApi.initializeProxy();
        expect(OldReaderApi.baseUrl, 'http://localhost:4000/proxy');
      });
    });

    group('extractCategoriesFromTagsResponse', () {
      test('retorna lista vazia se status não for 200', () {
        final api = OldReaderApi('token');
        final response = http.Response('', 500);
        expect(api.extractCategoriesFromTagsResponse(response), []);
      });

      test('retorna lista vazia se response body for inválido', () {
        final api = OldReaderApi('token');
        final response = http.Response('não é json', 200);
        expect(api.extractCategoriesFromTagsResponse(response), []);
      });

      test('extrai labels de tags com prefixo user/-/label/', () {
        final api = OldReaderApi('token');
        final response = _jsonResponse({
          'tags': [
            {'id': 'user/-/label/Tecnologia'},
            {'id': 'user/-/label/Notícias'},
            {'id': 'user/-/state/com.google/starred'},
          ],
        });
        expect(
          api.extractCategoriesFromTagsResponse(response),
          ['Tecnologia', 'Notícias'],
        );
      });

      test('ignora tags sem prefixo user/-/label/', () {
        final api = OldReaderApi('token');
        final response = _jsonResponse({
          'tags': [
            {'id': 'user/-/state/com.google/read'},
            {'id': 'user/-/state/com.google/starred'},
          ],
        });
        expect(api.extractCategoriesFromTagsResponse(response), []);
      });

      test('retorna lista vazia se tags for nulo', () {
        final api = OldReaderApi('token');
        final response = _jsonResponse({'tags': null});
        expect(api.extractCategoriesFromTagsResponse(response), []);
      });
    });
  });
}
