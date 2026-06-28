import 'package:flutter_test/flutter_test.dart';
import 'package:the_old_reader/providers/auth/auth_config.dart';

void main() {
  group('GoogleLoginAuthConfig', () {
    test('fromJson cria GoogleLoginAuthConfig corretamente', () {
      final json = {
        'type': 'googleLogin',
        'providerId': 'theoldreader',
        'email': 'user@example.com',
        'password': 'secret123',
        'authToken': 'abc123token',
      };

      final config = GoogleLoginAuthConfig.fromJson(json);

      expect(config.type, 'googleLogin');
      expect(config.providerId, 'theoldreader');
      expect(config.email, 'user@example.com');
      expect(config.password, 'secret123');
      expect(config.authToken, 'abc123token');
    });

    test('fromJson sem password (token pós-login)', () {
      final json = {
        'type': 'googleLogin',
        'providerId': 'theoldreader',
        'email': 'user@example.com',
        'authToken': 'token_only',
      };

      final config = GoogleLoginAuthConfig.fromJson(json);

      expect(config.password, isNull);
      expect(config.authToken, 'token_only');
    });

    test('toJson serializa corretamente', () {
      final config = GoogleLoginAuthConfig(
        providerId: 'theoldreader',
        email: 'test@test.com',
        authToken: 'mytoken',
      );

      final json = config.toJson();

      expect(json['type'], 'googleLogin');
      expect(json['providerId'], 'theoldreader');
      expect(json['email'], 'test@test.com');
      expect(json['authToken'], 'mytoken');
      // password é null, freezed serializa como null
      expect(json['password'], isNull);
    });

    test('roundtrip fromJson → toJson preserva dados', () {
      final original = GoogleLoginAuthConfig(
        providerId: 'theoldreader',
        email: 'round@test.com',
        password: 'pass123',
        authToken: 'round_token',
      );

      final restored = GoogleLoginAuthConfig.fromJson(original.toJson());

      expect(restored.email, original.email);
      expect(restored.password, original.password);
      expect(restored.authToken, original.authToken);
    });
  });

  group('OAuth2AuthConfig', () {
    test('fromJson cria OAuth2AuthConfig corretamente', () {
      final json = {
        'type': 'oauth2',
        'providerId': 'feedly',
        'clientId': 'my_client_id',
        'clientSecret': 'my_secret',
        'accessToken': 'access_token_123',
        'refreshToken': 'refresh_token_456',
        'expiresAt': '2026-12-31T23:59:59.000Z',
        'scopes': ['read', 'write'],
      };

      final config = OAuth2AuthConfig.fromJson(json);

      expect(config.type, 'oauth2');
      expect(config.providerId, 'feedly');
      expect(config.clientId, 'my_client_id');
      expect(config.clientSecret, 'my_secret');
      expect(config.accessToken, 'access_token_123');
      expect(config.refreshToken, 'refresh_token_456');
      expect(config.expiresAt, '2026-12-31T23:59:59.000Z');
      expect(config.scopes, ['read', 'write']);
    });

    test('fromJson com scopes vazios (default)', () {
      final json = {
        'type': 'oauth2',
        'providerId': 'feedly',
        'clientId': 'id',
        'clientSecret': 'secret',
        'accessToken': 'access',
        'refreshToken': 'refresh',
        'expiresAt': '2026-12-31T23:59:59.000Z',
      };

      final config = OAuth2AuthConfig.fromJson(json);

      expect(config.scopes, isEmpty);
    });

    test('toJson serializa corretamente', () {
      final config = OAuth2AuthConfig(
        providerId: 'feedly',
        clientId: 'id',
        clientSecret: 'secret',
        accessToken: 'access',
        refreshToken: 'refresh',
        expiresAt: '2026-12-31',
        scopes: ['email'],
      );

      final json = config.toJson();

      expect(json['type'], 'oauth2');
      expect(json['providerId'], 'feedly');
      expect(json['scopes'], ['email']);
    });
  });

  group('ApiKeyAuthConfig', () {
    test('fromJson cria ApiKeyAuthConfig corretamente', () {
      final json = {
        'type': 'apiKey',
        'providerId': 'freshrss',
        'apiKey': 'key_123',
        'apiSecret': 'secret_456',
        'baseUrl': 'https://freshrss.example.com',
      };

      final config = ApiKeyAuthConfig.fromJson(json);

      expect(config.type, 'apiKey');
      expect(config.providerId, 'freshrss');
      expect(config.apiKey, 'key_123');
      expect(config.apiSecret, 'secret_456');
      expect(config.baseUrl, 'https://freshrss.example.com');
    });

    test('fromJson sem campos opcionais', () {
      final json = {
        'type': 'apiKey',
        'providerId': 'miniflux',
        'apiKey': 'miniflux_key',
      };

      final config = ApiKeyAuthConfig.fromJson(json);

      expect(config.apiSecret, isNull);
      expect(config.baseUrl, isNull);
    });

    test('toJson serializa corretamente', () {
      final config = ApiKeyAuthConfig(
        providerId: 'freshrss',
        apiKey: 'my_key',
      );

      final json = config.toJson();

      expect(json['type'], 'apiKey');
      expect(json['apiKey'], 'my_key');
    });
  });

  group('BasicAuthConfig', () {
    test('fromJson cria BasicAuthConfig corretamente', () {
      final json = {
        'type': 'basicAuth',
        'providerId': 'feedbin',
        'username': 'user',
        'password': 'pass',
        'baseUrl': 'https://feedbin.example.com',
      };

      final config = BasicAuthConfig.fromJson(json);

      expect(config.type, 'basicAuth');
      expect(config.providerId, 'feedbin');
      expect(config.username, 'user');
      expect(config.password, 'pass');
      expect(config.baseUrl, 'https://feedbin.example.com');
    });

    test('toJson serializa corretamente', () {
      final config = BasicAuthConfig(
        providerId: 'feedbin',
        username: 'user',
        password: 'pass',
      );

      final json = config.toJson();

      expect(json['type'], 'basicAuth');
      expect(json['username'], 'user');
    });
  });

  group('LocalOpmlAuthConfig', () {
    test('fromJson cria LocalOpmlAuthConfig corretamente', () {
      final json = {
        'type': 'localOpml',
        'providerId': 'local_opml',
        'filePath': '/storage/emulated/0/Download/opml.xml',
      };

      final config = LocalOpmlAuthConfig.fromJson(json);

      expect(config.type, 'localOpml');
      expect(config.providerId, 'local_opml');
      expect(config.filePath, '/storage/emulated/0/Download/opml.xml');
    });

    test('toJson serializa corretamente', () {
      final config = LocalOpmlAuthConfig(
        providerId: 'local_opml',
        filePath: '/path/to/opml.xml',
      );

      final json = config.toJson();

      expect(json['type'], 'localOpml');
      expect(json['filePath'], '/path/to/opml.xml');
    });
  });

  group('AuthResult', () {
    test('fromJson cria AuthResult de sucesso', () {
      final json = {
        'success': true,
        'userId': 'user/123',
        'userName': 'Test User',
      };

      final result = AuthResult.fromJson(json);

      expect(result.success, true);
      expect(result.userId, 'user/123');
      expect(result.userName, 'Test User');
      expect(result.error, isNull);
    });

    test('fromJson cria AuthResult de falha', () {
      final json = {
        'success': false,
        'error': 'Invalid credentials',
      };

      final result = AuthResult.fromJson(json);

      expect(result.success, false);
      expect(result.error, 'Invalid credentials');
      expect(result.userId, isNull);
    });
  });

  group('FeedResult', () {
    test('fromJson cria FeedResult de sucesso', () {
      final json = {
        'success': true,
        'feedId': 'feed/123',
      };

      final result = FeedResult.fromJson(json);

      expect(result.success, true);
      expect(result.feedId, 'feed/123');
      expect(result.error, isNull);
    });

    test('fromJson cria FeedResult de falha', () {
      final json = {
        'success': false,
        'error': 'Feed already exists',
      };

      final result = FeedResult.fromJson(json);

      expect(result.success, false);
      expect(result.error, 'Feed already exists');
    });
  });

  group('CategoryResult', () {
    test('fromJson cria CategoryResult de sucesso', () {
      final json = {
        'success': true,
        'categoryId': 'user/-/label/Tech',
      };

      final result = CategoryResult.fromJson(json);

      expect(result.success, true);
      expect(result.categoryId, 'user/-/label/Tech');
    });
  });

  group('OpmlImportResult', () {
    test('fromJson cria OpmlImportResult de sucesso', () {
      final json = {
        'success': true,
        'feeds': [],
        'errors': [],
      };

      final result = OpmlImportResult.fromJson(json);

      expect(result.success, true);
      expect(result.feeds, isEmpty);
      expect(result.errors, isEmpty);
    });

    test('fromJson com erros', () {
      final json = {
        'success': false,
        'feeds': [],
        'errors': ['Invalid OPML', 'Feed not found'],
      };

      final result = OpmlImportResult.fromJson(json);

      expect(result.success, false);
      expect(result.errors.length, 2);
    });
  });
}