import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/providers/feedly/feedly_provider.dart';
import 'package:feedflow/providers/feed_provider.dart';

void main() {
  late FeedlyProvider provider;

  setUp(() {
    provider = FeedlyProvider();
  });

  group('FeedlyProvider', () {
    test('implementa FeedProvider', () {
      expect(provider, isA<FeedProvider>());
    });

    test('providerId é feedly', () {
      expect(provider.providerId, 'feedly');
    });

    test('displayName é Feedly', () {
      expect(provider.displayName, 'Feedly');
    });

    test('defaultBaseUrl aponta para cloud.feedly.com', () {
      expect(provider.defaultBaseUrl, 'https://cloud.feedly.com');
    });

    test('supportsWebProxy é false', () {
      expect(provider.supportsWebProxy, false);
    });

    test('supportedAuthTypes contém oauth2', () {
      expect(provider.supportedAuthTypes, contains(AuthType.oauth2));
    });

    test('getStoredAuth retorna null sem autenticação', () {
      expect(provider.getStoredAuth(), isNull);
    });

    test('validateToken retorna false sem autenticação', () async {
      expect(await provider.validateToken(), false);
    });

    test('getFeeds retorna lista vazia sem autenticação', () async {
      expect(await provider.getFeeds(), isEmpty);
    });

    test('getCategories retorna lista vazia sem autenticação', () async {
      expect(await provider.getCategories(), isEmpty);
    });

    test('getArticle retorna null sem autenticação', () async {
      expect(await provider.getArticle('test-id'), isNull);
    });

    test('getArticlesByIds retorna lista vazia', () async {
      expect(await provider.getArticlesByIds(['id1', 'id2']), isEmpty);
    });

    test('search retorna ArticleListResult vazio', () async {
      final result = await provider.search('test query');
      expect(result.articles, isEmpty);
      expect(result.continuation, isNull);
    });

    test('exportOpml retorna string vazia', () async {
      expect(await provider.exportOpml(), isEmpty);
    });

    test('importOpml retorna erro graceful', () async {
      final result = await provider.importOpml('<opml><body/></opml>');
      expect(result.success, false);
      expect(result.errors, isNotEmpty);
      expect(result.errors.first, contains('Feedly'));
    });

    test('getPreferences retorna mapa vazio', () async {
      expect(await provider.getPreferences(), isEmpty);
    });

    test('setPreference não lança exceção', () async {
      await provider.setPreference('theme', 'dark');
    });

    test('markAllAsRead não lança exceção', () async {
      await provider.markAllAsRead('user/test/tag/global.all');
    });

    test('addFeed retorna erro gracefully', () async {
      final result = await provider.addFeed('https://example.com/feed.xml');
      expect(result.success, false);
      expect(result.error, contains('Feedly'));
    });

    test('createCategory retorna erro graceful', () async {
      final result = await provider.createCategory('Test Category');
      expect(result.success, false);
      expect(result.error, contains('Feedly'));
    });
  });
}
