import 'package:flutter_test/flutter_test.dart';
import 'package:the_old_reader/providers/provider_registry.dart';
import 'package:the_old_reader/providers/feed_provider.dart';
import 'package:the_old_reader/providers/provider_init.dart';
import 'package:the_old_reader/providers/theoldreader/theoldreader_provider.dart';

void main() {
  setUp(() {
    initializeProviders();
  });

  group('ProviderRegistry', () {
    test('isRegistered retorna true para provider registrado', () {
      expect(ProviderRegistry.isRegistered('theoldreader'), true);
    });

    test('isRegistered retorna false para provider não registrado', () {
      expect(ProviderRegistry.isRegistered('feedly'), false);
      expect(ProviderRegistry.isRegistered('nonexistent'), false);
    });

    test('create retorna instância do provider correto', () {
      final provider = ProviderRegistry.create('theoldreader');

      expect(provider, isNotNull);
      expect(provider, isA<TheOldReaderProvider>());
    });

    test('create retorna null para provider não registrado', () {
      final provider = ProviderRegistry.create('nonexistent');

      expect(provider, isNull);
    });

    test('getAvailableProviders retorna lista não vazia', () {
      final providers = ProviderRegistry.getAvailableProviders();

      expect(providers, isNotEmpty);
      expect(providers.length, greaterThanOrEqualTo(1));
    });

    test('getAvailableProviders contém The Old Reader', () {
      final providers = ProviderRegistry.getAvailableProviders();
      final ids = providers.map((p) => p.id).toList();

      expect(ids, contains('theoldreader'));
    });

    test('getProviderInfo retorna info correta', () {
      final info = ProviderRegistry.getProviderInfo('theoldreader');

      expect(info, isNotNull);
      expect(info!.id, 'theoldreader');
      expect(info.name, 'The Old Reader');
      expect(info.supportsWebProxy, true);
      expect(info.authTypes, contains(AuthType.googleLogin));
    });

    test('getProviderInfo retorna null para provider inexistente', () {
      final info = ProviderRegistry.getProviderInfo('nonexistent');

      expect(info, isNull);
    });

    test('create retorna instâncias diferentes a cada chamada', () {
      final p1 = ProviderRegistry.create('theoldreader');
      final p2 = ProviderRegistry.create('theoldreader');

      expect(p1, isNotNull);
      expect(p2, isNotNull);
      expect(identical(p1, p2), false);
    });
  });

  group('FeedProvider Interface', () {
    test('TheOldReaderProvider implementa FeedProvider corretamente', () {
      final provider = ProviderRegistry.create('theoldreader')!;

      expect(provider.providerId, 'theoldreader');
      expect(provider.displayName, 'The Old Reader');
      expect(provider.defaultBaseUrl, contains('theoldreader.com'));
      expect(provider.supportsWebProxy, true);
      expect(provider.supportedAuthTypes, contains(AuthType.googleLogin));
    });

    test('TheOldReaderProvider tem todos os métodos da interface', () {
      final provider = ProviderRegistry.create('theoldreader')!;

      expect(provider.getFeeds, isA<Function>());
      expect(provider.addFeed, isA<Function>());
      expect(provider.removeFeed, isA<Function>());
      expect(provider.renameFeed, isA<Function>());
      expect(provider.moveFeed, isA<Function>());
      expect(provider.getCategories, isA<Function>());
      expect(provider.createCategory, isA<Function>());
      expect(provider.renameCategory, isA<Function>());
      expect(provider.deleteCategory, isA<Function>());
      expect(provider.getArticles, isA<Function>());
      expect(provider.getArticle, isA<Function>());
      expect(provider.getArticlesByIds, isA<Function>());
      expect(provider.markAsRead, isA<Function>());
      expect(provider.markAsUnread, isA<Function>());
      expect(provider.markAllAsRead, isA<Function>());
      expect(provider.starArticle, isA<Function>());
      expect(provider.unstarArticle, isA<Function>());
      expect(provider.getUnreadCounts, isA<Function>());
      expect(provider.search, isA<Function>());
      expect(provider.getStarredArticles, isA<Function>());
      expect(provider.exportOpml, isA<Function>());
      expect(provider.importOpml, isA<Function>());
      expect(provider.getPreferences, isA<Function>());
      expect(provider.setPreference, isA<Function>());
      expect(provider.authenticate, isA<Function>());
      expect(provider.logout, isA<Function>());
      expect(provider.validateToken, isA<Function>());
      expect(provider.getStoredAuth, isA<Function>());
    });
  });

  group('ProviderInfo', () {
    test('ProviderInfo armazena dados corretamente', () {
      const info = ProviderInfo(
        id: 'test',
        name: 'Test Provider',
        supportsWebProxy: false,
        authTypes: [AuthType.apiKey, AuthType.basicAuth],
      );

      expect(info.id, 'test');
      expect(info.name, 'Test Provider');
      expect(info.supportsWebProxy, false);
      expect(info.authTypes.length, 2);
    });
  });
}