import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import '../auth/auth_config.dart';

class FeedlyAuth {
  static const String _authBaseUrl = 'https://feedly.com';
  static const String _apiBaseUrl = 'https://cloud.feedly.com';
  static const String redirectUri = 'feedflow://oauth2/feedly';
  static const String _scope = 'https://cloud.feedly.com/subscriptions';

  static Future<OAuth2AuthConfig> authorize(
    String clientId, {
    String clientSecret = '',
  }) async {
    final authUrl = Uri.parse('$_authBaseUrl/v3/auth/auth').replace(
      queryParameters: {
        'client_id': clientId,
        'redirect_uri': redirectUri,
        'response_type': 'code',
        'scope': _scope,
      },
    ).toString();

    final result = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: 'feedflow',
    );

    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) throw Exception('Código OAuth2 não recebido');

    final tokenResponse = await http.post(
      Uri.parse('$_apiBaseUrl/v3/auth/token'),
      body: {
        'code': code,
        'client_id': clientId,
        'client_secret': clientSecret,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw Exception('Falha ao obter token: ${tokenResponse.body}');
    }

    final tokenData = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    final accessToken = tokenData['access_token'] as String;
    final refreshToken = tokenData['refresh_token'] as String? ?? '';
    final expiresIn = tokenData['expires_in'] as int? ?? 2592000;
    final expiresAt =
        DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();

    return OAuth2AuthConfig(
      providerId: 'feedly',
      clientId: clientId,
      clientSecret: clientSecret,
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      scopes: [_scope],
    );
  }

  static Future<OAuth2AuthConfig> refresh(OAuth2AuthConfig config) async {
    final response = await http.post(
      Uri.parse('$_apiBaseUrl/v3/auth/token'),
      body: {
        'refresh_token': config.refreshToken,
        'client_id': config.clientId,
        'client_secret': config.clientSecret,
        'grant_type': 'refresh_token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao renovar token Feedly');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final expiresIn = data['expires_in'] as int? ?? 2592000;

    return config.copyWith(
      accessToken: data['access_token'] as String,
      expiresAt: DateTime.now()
          .add(Duration(seconds: expiresIn))
          .toIso8601String(),
    );
  }
}
