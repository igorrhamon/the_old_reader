import 'package:flutter_test/flutter_test.dart';
import 'package:the_old_reader/models/category.dart';

void main() {
  group('Category Model', () {
    test('fromJson cria Category corretamente', () {
      final json = {
        'id': 'user/-/label/Tecnologia',
        'name': 'Tecnologia',
        'unreadCount': 42,
        'feeds': [],
      };

      final category = Category.fromJson(json);

      expect(category.id, 'user/-/label/Tecnologia');
      expect(category.name, 'Tecnologia');
      expect(category.unreadCount, 42);
      expect(category.feeds, isEmpty);
    });

    test('fromJson com campos nulos e defaults', () {
      final json = {
        'id': 'user/-/label/News',
        'name': 'News',
      };

      final category = Category.fromJson(json);

      expect(category.id, 'user/-/label/News');
      expect(category.name, 'News');
      expect(category.unreadCount, 0);
      expect(category.feeds, isEmpty);
    });

    test('toJson serializa corretamente', () {
      final category = Category(
        id: 'user/-/label/Coding',
        name: 'Coding',
        unreadCount: 10,
      );

      final json = category.toJson();

      expect(json['id'], 'user/-/label/Coding');
      expect(json['name'], 'Coding');
      expect(json['unreadCount'], 10);
    });

    test('copyWith preserva valores existentes', () {
      final original = Category(
        id: 'user/-/label/Test',
        name: 'Test',
        unreadCount: 5,
      );

      final copy = original.copyWith(name: 'Updated', unreadCount: 15);

      expect(copy.id, 'user/-/label/Test');
      expect(copy.name, 'Updated');
      expect(copy.unreadCount, 15);
    });

    test('equality usa deep equality (todos os campos)', () {
      final c1 = Category(id: 'user/-/label/Same', name: 'Same');
      final c2 = Category(id: 'user/-/label/Same', name: 'Same');
      final c3 = Category(id: 'user/-/label/Same', name: 'Different');
      final c4 = Category(id: 'user/-/label/Different', name: 'Same');

      expect(c1, equals(c2));
      expect(c1, isNot(equals(c3)));
      expect(c1, isNot(equals(c4)));
    });

    test('roundtrip fromJson → toJson preserva dados', () {
      final original = Category(
        id: 'user/-/label/Roundtrip',
        name: 'Roundtrip',
        unreadCount: 99,
      );

      final restored = Category.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.unreadCount, original.unreadCount);
    });
  });

  group('UnreadCount Model', () {
    test('fromJson cria UnreadCount corretamente', () {
      final json = {
        'id': 'user/-/state/com.google/reading-list',
        'count': 1234,
        'updated': '2026-06-27T10:00:00.000Z',
      };

      final unread = UnreadCount.fromJson(json);

      expect(unread.id, 'user/-/state/com.google/reading-list');
      expect(unread.count, 1234);
      expect(unread.updated, DateTime.utc(2026, 6, 27, 10, 0, 0));
    });

    test('fromJson sem timestamp', () {
      final json = {
        'id': 'feed/001',
        'count': 10,
      };

      final unread = UnreadCount.fromJson(json);

      expect(unread.id, 'feed/001');
      expect(unread.count, 10);
      expect(unread.updated, isNull);
    });

    test('toJson serializa corretamente', () {
      final now = DateTime.utc(2026, 6, 27);
      final unread = UnreadCount(
        id: 'feed/002',
        count: 50,
        updated: now,
      );

      final json = unread.toJson();

      expect(json['id'], 'feed/002');
      expect(json['count'], 50);
      expect(json['updated'], now.toIso8601String());
    });
  });
}