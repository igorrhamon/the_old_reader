import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/providers/inoreader/inoreader_provider.dart';
import 'package:feedflow/providers/feed_provider.dart';
import 'package:feedflow/providers/auth/auth_config.dart';

void main() {
  group('InoreaderProvider', () {
    late InoreaderProvider provider;

    setUp(() {
      provider = InoreaderProvider();
    });

    group('Propriedades básicas', () {
      test('providerId retorna inoreader', () {
        expect(provider.providerId, 'inoreader');
      });

      test('displayName retorna Inoreader', () {
        expect(provider.displayName, 'Inoreader');
      });

      test('defaultBaseUrl retorna URL correta', () {
        expect(provider.defaultBaseUrl, 'https://www.inoreader.com/reader/api/0');
      });

      test('supportsWebProxy retorna true', () {
        expect(provider.supportsWebProxy, true);
      });

      test('supportedAuthTypes contém apiKey', () {
        expect(provider.supportedAuthTypes, contains(AuthType.apiKey));
      });
    });

    group('Autenticação', () {
      test('authenticate retorna erro com API key inválida', () async {
        final config = ApiKeyAuthConfig(
          providerId: 'inoreader',
          apiKey: 'invalid_key',
        );
        final result = await provider.authenticate(config);
        expect(result.success, false);
        expect(result.error, isNotNull);
      });

      test('getStoredAuth retorna null antes da autenticação', () {
        expect(provider.getStoredAuth(), isNull);
      });

      test('logout limpa estado', () async {
        await provider.logout();
        expect(provider.getStoredAuth(), isNull);
      });
    });

    group('FeedProvider Interface', () {
      test('InoreaderProvider implementa FeedProvider', () {
        expect(provider, isA<FeedProvider>());
      });

      test('tem todos os métodos necessários', () {
        expect(provider.authenticate, isNotNull);
        expect(provider.logout, isNotNull);
        expect(provider.validateToken, isNotNull);
        expect(provider.getStoredAuth, isNotNull);
        expect(provider.getFeeds, isNotNull);
        expect(provider.addFeed, isNotNull);
        expect(provider.removeFeed, isNotNull);
        expect(provider.renameFeed, isNotNull);
        expect(provider.moveFeed, isNotNull);
        expect(provider.getCategories, isNotNull);
        expect(provider.createCategory, isNotNull);
        expect(provider.renameCategory, isNotNull);
        expect(provider.deleteCategory, isNotNull);
        expect(provider.getArticles, isNotNull);
        expect(provider.getArticle, isNotNull);
        expect(provider.getArticlesByIds, isNotNull);
        expect(provider.markAsRead, isNotNull);
        expect(provider.markAsUnread, isNotNull);
        expect(provider.markAllAsRead, isNotNull);
        expect(provider.starArticle, isNotNull);
        expect(provider.unstarArticle, isNotNull);
        expect(provider.getUnreadCounts, isNotNull);
        expect(provider.search, isNotNull);
        expect(provider.getStarredArticles, isNotNull);
        expect(provider.exportOpml, isNotNull);
        expect(provider.importOpml, isNotNull);
        expect(provider.getPreferences, isNotNull);
        expect(provider.setPreference, isNotNull);
      });
    });

    group('Métodos sem autenticação retornam vazio/null', () {
      test('getFeeds retorna lista vazia', () async {
        final result = await provider.getFeeds();
        expect(result, isEmpty);
      });

      test('getCategories retorna lista vazia', () async {
        final result = await provider.getCategories();
        expect(result, isEmpty);
      });

      test('getUnreadCounts retorna mapa vazio', () async {
        final result = await provider.getUnreadCounts();
        expect(result, isEmpty);
      });

      test('getArticles retorna ArticleListResult vazio', () async {
        final result = await provider.getArticles(streamId: 'test');
        expect(result.articles, isEmpty);
      });

      test('getStarredArticles retorna ArticleListResult vazio', () async {
        final result = await provider.getStarredArticles();
        expect(result.articles, isEmpty);
      });

      test('search retorna ArticleListResult vazio', () async {
        final result = await provider.search('test');
        expect(result.articles, isEmpty);
      });

      test('getArticle retorna null', () async {
        final result = await provider.getArticle('test');
        expect(result, isNull);
      });

      test('exportOpml retorna string vazia', () async {
        final result = await provider.exportOpml();
        expect(result, isEmpty);
      });

      test('getPreferences retorna mapa vazio', () async {
        final result = await provider.getPreferences();
        expect(result, isEmpty);
      });

      test('validateToken retorna false sem autenticação', () async {
        final result = await provider.validateToken();
        expect(result, false);
      });
    });
  });
}
