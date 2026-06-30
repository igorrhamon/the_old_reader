import 'package:flutter_test/flutter_test.dart';
import 'package:feedflow/models/feed.dart';

void main() {
  group('Feed Model', () {
    test('fromJson cria Feed corretamente', () {
      final json = {
        'id': 'feed/123',
        'title': 'Test Feed',
        'url': 'https://example.com/feed',
        'siteUrl': 'https://example.com',
        'iconUrl': 'https://example.com/icon.png',
        'unreadCount': 42,
        'categories': ['Tecnologia', 'Coding'],
        'metadata': {'custom': 'value'},
      };

      final feed = Feed.fromJson(json);

      expect(feed.id, 'feed/123');
      expect(feed.title, 'Test Feed');
      expect(feed.url, 'https://example.com/feed');
      expect(feed.siteUrl, 'https://example.com');
      expect(feed.iconUrl, 'https://example.com/icon.png');
      expect(feed.unreadCount, 42);
      expect(feed.categories, ['Tecnologia', 'Coding']);
      expect(feed.metadata, {'custom': 'value'});
    });

    test('fromJson com campos nulos', () {
      final json = {
        'id': 'feed/456',
        'title': 'Minimal Feed',
      };

      final feed = Feed.fromJson(json);

      expect(feed.id, 'feed/456');
      expect(feed.title, 'Minimal Feed');
      expect(feed.url, isNull);
      expect(feed.siteUrl, isNull);
      expect(feed.iconUrl, isNull);
      expect(feed.unreadCount, 0);
      expect(feed.categories, isEmpty);
      expect(feed.metadata, isEmpty);
    });

    test('toJson serializa corretamente', () {
      final feed = Feed(
        id: 'feed/789',
        title: 'Serialized Feed',
        url: 'https://example.com/feed',
        unreadCount: 10,
        categories: ['News'],
      );

      final json = feed.toJson();

      expect(json['id'], 'feed/789');
      expect(json['title'], 'Serialized Feed');
      expect(json['url'], 'https://example.com/feed');
      expect(json['unreadCount'], 10);
      expect(json['categories'], ['News']);
    });

    test('copyWith preserva valores existentes', () {
      final original = Feed(
        id: 'feed/001',
        title: 'Original',
        url: 'https://example.com',
        unreadCount: 5,
        categories: ['Tech'],
      );

      final copy = original.copyWith(title: 'Updated Title', unreadCount: 10);

      expect(copy.id, 'feed/001');
      expect(copy.title, 'Updated Title');
      expect(copy.url, 'https://example.com');
      expect(copy.unreadCount, 10);
      expect(copy.categories, ['Tech']);
    });

    test('copyWith retorna igual se sem mudanças', () {
      final original = Feed(id: 'feed/002', title: 'No Change');
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.title, original.title);
    });

    test('equality usa deep equality (todos os campos)', () {
      final feed1 = Feed(id: 'feed/003', title: 'Same');
      final feed2 = Feed(id: 'feed/003', title: 'Same');
      final feed3 = Feed(id: 'feed/003', title: 'Different');
      final feed4 = Feed(id: 'feed/004', title: 'Same');

      expect(feed1, equals(feed2));
      expect(feed1, isNot(equals(feed3)));
      expect(feed1, isNot(equals(feed4)));
    });

    test('hashCode consistente com equality', () {
      final feed1 = Feed(id: 'feed/005', title: 'Feed');
      final feed2 = Feed(id: 'feed/005', title: 'Feed');

      expect(feed1.hashCode, equals(feed2.hashCode));
    });

    test('toString retorna representação legível', () {
      final feed = Feed(id: 'feed/006', title: 'Readable', unreadCount: 3);

      expect(feed.toString(), contains('feed/006'));
      expect(feed.toString(), contains('Readable'));
      expect(feed.toString(), contains('3'));
    });

    test('roundtrip fromJson → toJson preserva dados', () {
      final original = Feed(
        id: 'feed/007',
        title: 'Roundtrip',
        url: 'https://example.com',
        siteUrl: 'https://example.com',
        iconUrl: 'https://example.com/icon.png',
        unreadCount: 99,
        categories: ['A', 'B'],
        metadata: {'key': 'value'},
      );

      final restored = Feed.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.url, original.url);
      expect(restored.siteUrl, original.siteUrl);
      expect(restored.iconUrl, original.iconUrl);
      expect(restored.unreadCount, original.unreadCount);
      expect(restored.categories, original.categories);
      expect(restored.metadata, original.metadata);
    });
  });
}