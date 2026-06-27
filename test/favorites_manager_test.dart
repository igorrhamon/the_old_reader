import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_old_reader/managers/favorites_manager.dart';

void main() {
  group('FavoritesManager', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('isFavorite retorna false para artigo não favoritado', () async {
      final result = await FavoritesManager.isFavorite('article-1');
      expect(result, false);
    });

    test('setFavorite true faz isFavorite retornar true', () async {
      await FavoritesManager.setFavorite('article-1', true);
      final result = await FavoritesManager.isFavorite('article-1');
      expect(result, true);
    });

    test('setFavorite false depois de true retorna false', () async {
      await FavoritesManager.setFavorite('article-1', true);
      await FavoritesManager.setFavorite('article-1', false);
      final result = await FavoritesManager.isFavorite('article-1');
      expect(result, false);
    });

    test('getAllFavorites retorna lista vazia quando não há favoritos', () async {
      final result = await FavoritesManager.getAllFavorites();
      expect(result, []);
    });

    test('getAllFavorites retorna apenas artigos favoritados', () async {
      await FavoritesManager.setFavorite('article-1', true);
      await FavoritesManager.setFavorite('article-2', false);
      await FavoritesManager.setFavorite('article-3', true);
      final result = await FavoritesManager.getAllFavorites();
      expect(result.length, 2);
      expect(result, contains('article-1'));
      expect(result, contains('article-3'));
      expect(result, isNot(contains('article-2')));
    });

    test('favoritar múltiplos artigos e listar todos', () async {
      await FavoritesManager.setFavorite('a', true);
      await FavoritesManager.setFavorite('b', true);
      await FavoritesManager.setFavorite('c', true);
      final result = await FavoritesManager.getAllFavorites();
      expect(result.length, 3);
    });
  });
}
