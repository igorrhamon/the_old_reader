import 'package:shared_preferences/shared_preferences.dart';

class FavoritesManager {
  static const _prefix = 'favorite_';

  static Future<void> setFavorite(String articleId, bool isFavorite) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$articleId', isFavorite);
  }

  static Future<bool> isFavorite(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$articleId') ?? false;
  }

  static Future<List<String>> getAllFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getKeys()
        .where((k) => k.startsWith(_prefix) && prefs.getBool(k) == true)
        .map((k) => k.replaceFirst(_prefix, ''))
        .toList();
  }
}