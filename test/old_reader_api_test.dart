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
    group('baseUrl', () {
      test('usa API direta em native (kIsWeb=false em testes)', () {
        expect(OldReaderApi.baseUrl, 'https://theoldreader.com/reader/api/0');
      });

      test('setProxyPort é no-op em native', () {
        OldReaderApi.setProxyPort(9999);
        expect(OldReaderApi.baseUrl, 'https://theoldreader.com/reader/api/0');
        OldReaderApi.setProxyPort(3000);
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
