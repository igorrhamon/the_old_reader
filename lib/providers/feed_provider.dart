import '../models/feed.dart';
import '../models/article.dart';
import '../models/category.dart';
import 'auth/auth_config.dart';

abstract class FeedProvider {
  String get providerId;
  String get displayName;
  String get defaultBaseUrl;
  bool get supportsWebProxy;
  List<AuthType> get supportedAuthTypes;

  Future<AuthResult> authenticate(Object config);
  Future<void> logout();
  Future<bool> validateToken();
  Object? getStoredAuth();

  Future<List<Feed>> getFeeds();
  Future<FeedResult> addFeed(String feedUrl, {String? category});
  Future<void> removeFeed(String feedId);
  Future<void> renameFeed(String feedId, String newTitle);
  Future<void> moveFeed(String feedId, String? categoryId);

  Future<List<Category>> getCategories();
  Future<CategoryResult> createCategory(String name);
  Future<void> renameCategory(String categoryId, String newName);
  Future<void> deleteCategory(String categoryId);

  Future<ArticleListResult> getArticles({
    required String streamId,
    int limit = 20,
    String? continuation,
    DateTime? newerThan,
    DateTime? olderThan,
    bool excludeRead = false,
  });

  Future<Article?> getArticle(String articleId);
  Future<List<Article>> getArticlesByIds(List<String> ids);

  Future<void> markAsRead(String articleId);
  Future<void> markAsUnread(String articleId);
  Future<void> markAllAsRead(String streamId, {DateTime? before});
  Future<void> starArticle(String articleId);
  Future<void> unstarArticle(String articleId);

  Future<Map<String, int>> getUnreadCounts();

  Future<ArticleListResult> search(String query, {int limit = 20, String? continuation});

  Future<ArticleListResult> getStarredArticles({int limit = 20, String? continuation});

  Future<String> exportOpml();
  Future<OpmlImportResult> importOpml(String opmlContent);

  Future<Map<String, dynamic>> getPreferences();
  Future<void> setPreference(String key, String value);
}

enum AuthType { googleLogin, oauth2, apiKey, basicAuth, localFile }