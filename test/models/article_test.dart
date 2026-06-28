import 'package:flutter_test/flutter_test.dart';
import 'package:the_old_reader/models/article.dart';

void main() {
  group('Article Model', () {
    test('fromJson cria Article corretamente', () {
      final json = {
        'id': 'article/001',
        'feedId': 'feed/123',
        'title': 'Test Article',
        'author': 'John Doe',
        'summary': 'This is a summary',
        'content': '<p>Full content</p>',
        'url': 'https://example.com/article',
        'published': '2026-06-27T10:00:00.000Z',
        'updated': '2026-06-27T12:00:00.000Z',
        'categories': ['read', 'starred'],
        'isRead': true,
        'isStarred': true,
        'metadata': {'extra': 'data'},
      };

      final article = Article.fromJson(json);

      expect(article.id, 'article/001');
      expect(article.feedId, 'feed/123');
      expect(article.title, 'Test Article');
      expect(article.author, 'John Doe');
      expect(article.summary, 'This is a summary');
      expect(article.content, '<p>Full content</p>');
      expect(article.url, 'https://example.com/article');
      expect(article.published, DateTime.utc(2026, 6, 27, 10, 0, 0));
      expect(article.updated, DateTime.utc(2026, 6, 27, 12, 0, 0));
      expect(article.categories, ['read', 'starred']);
      expect(article.isRead, true);
      expect(article.isStarred, true);
    });

    test('fromJson com campos nulos e defaults', () {
      final json = {
        'id': 'article/002',
        'feedId': 'feed/456',
        'title': 'Minimal Article',
      };

      final article = Article.fromJson(json);

      expect(article.id, 'article/002');
      expect(article.feedId, 'feed/456');
      expect(article.title, 'Minimal Article');
      expect(article.author, isNull);
      expect(article.summary, isNull);
      expect(article.content, isNull);
      expect(article.url, isNull);
      expect(article.published, isNull);
      expect(article.updated, isNull);
      expect(article.categories, isEmpty);
      expect(article.isRead, false);
      expect(article.isStarred, false);
    });

    test('toJson serializa corretamente', () {
      final now = DateTime.utc(2026, 6, 27);
      final article = Article(
        id: 'article/003',
        feedId: 'feed/789',
        title: 'Serialized',
        author: 'Jane',
        published: now,
        isRead: true,
        categories: ['tech'],
      );

      final json = article.toJson();

      expect(json['id'], 'article/003');
      expect(json['feedId'], 'feed/789');
      expect(json['title'], 'Serialized');
      expect(json['author'], 'Jane');
      expect(json['published'], now.toIso8601String());
      expect(json['isRead'], true);
      expect(json['categories'], ['tech']);
    });

    test('copyWith preserva valores existentes', () {
      final original = Article(
        id: 'article/004',
        feedId: 'feed/004',
        title: 'Original',
        author: 'Author',
        isRead: false,
        isStarred: false,
      );

      final copy = original.copyWith(isRead: true, isStarred: true);

      expect(copy.id, 'article/004');
      expect(copy.feedId, 'feed/004');
      expect(copy.title, 'Original');
      expect(copy.author, 'Author');
      expect(copy.isRead, true);
      expect(copy.isStarred, true);
    });

    test('equality usa deep equality (todos os campos)', () {
      final a1 = Article(id: 'article/005', feedId: 'f', title: 'Same');
      final a2 = Article(id: 'article/005', feedId: 'f', title: 'Same');
      final a3 = Article(id: 'article/005', feedId: 'f', title: 'Different');
      final a4 = Article(id: 'article/006', feedId: 'f', title: 'Same');

      expect(a1, equals(a2));
      expect(a1, isNot(equals(a3)));
      expect(a1, isNot(equals(a4)));
    });

    test('roundtrip fromJson → toJson preserva dados', () {
      final now = DateTime.utc(2026, 1, 1);
      final original = Article(
        id: 'article/007',
        feedId: 'feed/007',
        title: 'Roundtrip',
        author: 'Author',
        summary: 'Summary',
        content: 'Content',
        url: 'https://example.com',
        published: now,
        categories: ['read'],
        isRead: true,
        isStarred: false,
      );

      final restored = Article.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.feedId, original.feedId);
      expect(restored.title, original.title);
      expect(restored.author, original.author);
      expect(restored.summary, original.summary);
      expect(restored.content, original.content);
      expect(restored.url, original.url);
      expect(restored.published, original.published);
      expect(restored.categories, original.categories);
      expect(restored.isRead, original.isRead);
      expect(restored.isStarred, original.isStarred);
    });
  });

  group('ArticleListResult Model', () {
    test('fromJson cria ArticleListResult corretamente', () {
      final json = {
        'articles': [
          {
            'id': 'article/010',
            'feedId': 'feed/010',
            'title': 'Article 10',
          },
          {
            'id': 'article/011',
            'feedId': 'feed/011',
            'title': 'Article 11',
          },
        ],
        'continuation': 'next_page_token',
        'totalCount': 100,
      };

      final result = ArticleListResult.fromJson(json);

      expect(result.articles.length, 2);
      expect(result.articles[0].id, 'article/010');
      expect(result.articles[1].id, 'article/011');
      expect(result.continuation, 'next_page_token');
      expect(result.totalCount, 100);
    });

    test('fromJson com lista vazia', () {
      final json = {
        'articles': [],
      };

      final result = ArticleListResult.fromJson(json);

      expect(result.articles, isEmpty);
      expect(result.continuation, isNull);
      expect(result.totalCount, isNull);
    });
  });
}