// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

GoogleLoginAuthConfig _$GoogleLoginAuthConfigFromJson(
  Map<String, dynamic> json,
) {
  return _GoogleLoginAuthConfig.fromJson(json);
}

/// @nodoc
mixin _$GoogleLoginAuthConfig {
  String get type => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get password => throw _privateConstructorUsedError;
  String get authToken => throw _privateConstructorUsedError;

  /// Serializes this GoogleLoginAuthConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GoogleLoginAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoogleLoginAuthConfigCopyWith<GoogleLoginAuthConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoogleLoginAuthConfigCopyWith<$Res> {
  factory $GoogleLoginAuthConfigCopyWith(
    GoogleLoginAuthConfig value,
    $Res Function(GoogleLoginAuthConfig) then,
  ) = _$GoogleLoginAuthConfigCopyWithImpl<$Res, GoogleLoginAuthConfig>;
  @useResult
  $Res call({
    String type,
    String providerId,
    String email,
    String? password,
    String authToken,
  });
}

/// @nodoc
class _$GoogleLoginAuthConfigCopyWithImpl<
  $Res,
  $Val extends GoogleLoginAuthConfig
>
    implements $GoogleLoginAuthConfigCopyWith<$Res> {
  _$GoogleLoginAuthConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GoogleLoginAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? email = null,
    Object? password = freezed,
    Object? authToken = null,
  }) {
    return _then(
      _value.copyWith(
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            providerId:
                null == providerId
                    ? _value.providerId
                    : providerId // ignore: cast_nullable_to_non_nullable
                        as String,
            email:
                null == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String,
            password:
                freezed == password
                    ? _value.password
                    : password // ignore: cast_nullable_to_non_nullable
                        as String?,
            authToken:
                null == authToken
                    ? _value.authToken
                    : authToken // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GoogleLoginAuthConfigImplCopyWith<$Res>
    implements $GoogleLoginAuthConfigCopyWith<$Res> {
  factory _$$GoogleLoginAuthConfigImplCopyWith(
    _$GoogleLoginAuthConfigImpl value,
    $Res Function(_$GoogleLoginAuthConfigImpl) then,
  ) = __$$GoogleLoginAuthConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String providerId,
    String email,
    String? password,
    String authToken,
  });
}

/// @nodoc
class __$$GoogleLoginAuthConfigImplCopyWithImpl<$Res>
    extends
        _$GoogleLoginAuthConfigCopyWithImpl<$Res, _$GoogleLoginAuthConfigImpl>
    implements _$$GoogleLoginAuthConfigImplCopyWith<$Res> {
  __$$GoogleLoginAuthConfigImplCopyWithImpl(
    _$GoogleLoginAuthConfigImpl _value,
    $Res Function(_$GoogleLoginAuthConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GoogleLoginAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? email = null,
    Object? password = freezed,
    Object? authToken = null,
  }) {
    return _then(
      _$GoogleLoginAuthConfigImpl(
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        providerId:
            null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                    as String,
        email:
            null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String,
        password:
            freezed == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                    as String?,
        authToken:
            null == authToken
                ? _value.authToken
                : authToken // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GoogleLoginAuthConfigImpl implements _GoogleLoginAuthConfig {
  const _$GoogleLoginAuthConfigImpl({
    this.type = 'googleLogin',
    required this.providerId,
    required this.email,
    this.password,
    required this.authToken,
  });

  factory _$GoogleLoginAuthConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoogleLoginAuthConfigImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  @override
  final String providerId;
  @override
  final String email;
  @override
  final String? password;
  @override
  final String authToken;

  @override
  String toString() {
    return 'GoogleLoginAuthConfig(type: $type, providerId: $providerId, email: $email, password: $password, authToken: $authToken)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoogleLoginAuthConfigImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.authToken, authToken) ||
                other.authToken == authToken));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, providerId, email, password, authToken);

  /// Create a copy of GoogleLoginAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoogleLoginAuthConfigImplCopyWith<_$GoogleLoginAuthConfigImpl>
  get copyWith =>
      __$$GoogleLoginAuthConfigImplCopyWithImpl<_$GoogleLoginAuthConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GoogleLoginAuthConfigImplToJson(this);
  }
}

abstract class _GoogleLoginAuthConfig implements GoogleLoginAuthConfig {
  const factory _GoogleLoginAuthConfig({
    final String type,
    required final String providerId,
    required final String email,
    final String? password,
    required final String authToken,
  }) = _$GoogleLoginAuthConfigImpl;

  factory _GoogleLoginAuthConfig.fromJson(Map<String, dynamic> json) =
      _$GoogleLoginAuthConfigImpl.fromJson;

  @override
  String get type;
  @override
  String get providerId;
  @override
  String get email;
  @override
  String? get password;
  @override
  String get authToken;

  /// Create a copy of GoogleLoginAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoogleLoginAuthConfigImplCopyWith<_$GoogleLoginAuthConfigImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OAuth2AuthConfig _$OAuth2AuthConfigFromJson(Map<String, dynamic> json) {
  return _OAuth2AuthConfig.fromJson(json);
}

/// @nodoc
mixin _$OAuth2AuthConfig {
  String get type => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get clientId => throw _privateConstructorUsedError;
  String get clientSecret => throw _privateConstructorUsedError;
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  String get expiresAt => throw _privateConstructorUsedError;
  List<String> get scopes => throw _privateConstructorUsedError;

  /// Serializes this OAuth2AuthConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OAuth2AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OAuth2AuthConfigCopyWith<OAuth2AuthConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OAuth2AuthConfigCopyWith<$Res> {
  factory $OAuth2AuthConfigCopyWith(
    OAuth2AuthConfig value,
    $Res Function(OAuth2AuthConfig) then,
  ) = _$OAuth2AuthConfigCopyWithImpl<$Res, OAuth2AuthConfig>;
  @useResult
  $Res call({
    String type,
    String providerId,
    String clientId,
    String clientSecret,
    String accessToken,
    String refreshToken,
    String expiresAt,
    List<String> scopes,
  });
}

/// @nodoc
class _$OAuth2AuthConfigCopyWithImpl<$Res, $Val extends OAuth2AuthConfig>
    implements $OAuth2AuthConfigCopyWith<$Res> {
  _$OAuth2AuthConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OAuth2AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? clientId = null,
    Object? clientSecret = null,
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
    Object? scopes = null,
  }) {
    return _then(
      _value.copyWith(
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            providerId:
                null == providerId
                    ? _value.providerId
                    : providerId // ignore: cast_nullable_to_non_nullable
                        as String,
            clientId:
                null == clientId
                    ? _value.clientId
                    : clientId // ignore: cast_nullable_to_non_nullable
                        as String,
            clientSecret:
                null == clientSecret
                    ? _value.clientSecret
                    : clientSecret // ignore: cast_nullable_to_non_nullable
                        as String,
            accessToken:
                null == accessToken
                    ? _value.accessToken
                    : accessToken // ignore: cast_nullable_to_non_nullable
                        as String,
            refreshToken:
                null == refreshToken
                    ? _value.refreshToken
                    : refreshToken // ignore: cast_nullable_to_non_nullable
                        as String,
            expiresAt:
                null == expiresAt
                    ? _value.expiresAt
                    : expiresAt // ignore: cast_nullable_to_non_nullable
                        as String,
            scopes:
                null == scopes
                    ? _value.scopes
                    : scopes // ignore: cast_nullable_to_non_nullable
                        as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OAuth2AuthConfigImplCopyWith<$Res>
    implements $OAuth2AuthConfigCopyWith<$Res> {
  factory _$$OAuth2AuthConfigImplCopyWith(
    _$OAuth2AuthConfigImpl value,
    $Res Function(_$OAuth2AuthConfigImpl) then,
  ) = __$$OAuth2AuthConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String providerId,
    String clientId,
    String clientSecret,
    String accessToken,
    String refreshToken,
    String expiresAt,
    List<String> scopes,
  });
}

/// @nodoc
class __$$OAuth2AuthConfigImplCopyWithImpl<$Res>
    extends _$OAuth2AuthConfigCopyWithImpl<$Res, _$OAuth2AuthConfigImpl>
    implements _$$OAuth2AuthConfigImplCopyWith<$Res> {
  __$$OAuth2AuthConfigImplCopyWithImpl(
    _$OAuth2AuthConfigImpl _value,
    $Res Function(_$OAuth2AuthConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OAuth2AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? clientId = null,
    Object? clientSecret = null,
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? expiresAt = null,
    Object? scopes = null,
  }) {
    return _then(
      _$OAuth2AuthConfigImpl(
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        providerId:
            null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                    as String,
        clientId:
            null == clientId
                ? _value.clientId
                : clientId // ignore: cast_nullable_to_non_nullable
                    as String,
        clientSecret:
            null == clientSecret
                ? _value.clientSecret
                : clientSecret // ignore: cast_nullable_to_non_nullable
                    as String,
        accessToken:
            null == accessToken
                ? _value.accessToken
                : accessToken // ignore: cast_nullable_to_non_nullable
                    as String,
        refreshToken:
            null == refreshToken
                ? _value.refreshToken
                : refreshToken // ignore: cast_nullable_to_non_nullable
                    as String,
        expiresAt:
            null == expiresAt
                ? _value.expiresAt
                : expiresAt // ignore: cast_nullable_to_non_nullable
                    as String,
        scopes:
            null == scopes
                ? _value._scopes
                : scopes // ignore: cast_nullable_to_non_nullable
                    as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OAuth2AuthConfigImpl implements _OAuth2AuthConfig {
  const _$OAuth2AuthConfigImpl({
    this.type = 'oauth2',
    required this.providerId,
    required this.clientId,
    required this.clientSecret,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    final List<String> scopes = const [],
  }) : _scopes = scopes;

  factory _$OAuth2AuthConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$OAuth2AuthConfigImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  @override
  final String providerId;
  @override
  final String clientId;
  @override
  final String clientSecret;
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final String expiresAt;
  final List<String> _scopes;
  @override
  @JsonKey()
  List<String> get scopes {
    if (_scopes is EqualUnmodifiableListView) return _scopes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scopes);
  }

  @override
  String toString() {
    return 'OAuth2AuthConfig(type: $type, providerId: $providerId, clientId: $clientId, clientSecret: $clientSecret, accessToken: $accessToken, refreshToken: $refreshToken, expiresAt: $expiresAt, scopes: $scopes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OAuth2AuthConfigImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientSecret, clientSecret) ||
                other.clientSecret == clientSecret) &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            const DeepCollectionEquality().equals(other._scopes, _scopes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    type,
    providerId,
    clientId,
    clientSecret,
    accessToken,
    refreshToken,
    expiresAt,
    const DeepCollectionEquality().hash(_scopes),
  );

  /// Create a copy of OAuth2AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OAuth2AuthConfigImplCopyWith<_$OAuth2AuthConfigImpl> get copyWith =>
      __$$OAuth2AuthConfigImplCopyWithImpl<_$OAuth2AuthConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OAuth2AuthConfigImplToJson(this);
  }
}

abstract class _OAuth2AuthConfig implements OAuth2AuthConfig {
  const factory _OAuth2AuthConfig({
    final String type,
    required final String providerId,
    required final String clientId,
    required final String clientSecret,
    required final String accessToken,
    required final String refreshToken,
    required final String expiresAt,
    final List<String> scopes,
  }) = _$OAuth2AuthConfigImpl;

  factory _OAuth2AuthConfig.fromJson(Map<String, dynamic> json) =
      _$OAuth2AuthConfigImpl.fromJson;

  @override
  String get type;
  @override
  String get providerId;
  @override
  String get clientId;
  @override
  String get clientSecret;
  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  String get expiresAt;
  @override
  List<String> get scopes;

  /// Create a copy of OAuth2AuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OAuth2AuthConfigImplCopyWith<_$OAuth2AuthConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiKeyAuthConfig _$ApiKeyAuthConfigFromJson(Map<String, dynamic> json) {
  return _ApiKeyAuthConfig.fromJson(json);
}

/// @nodoc
mixin _$ApiKeyAuthConfig {
  String get type => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get apiKey => throw _privateConstructorUsedError;
  String? get apiSecret => throw _privateConstructorUsedError;
  String? get baseUrl => throw _privateConstructorUsedError;

  /// Serializes this ApiKeyAuthConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ApiKeyAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ApiKeyAuthConfigCopyWith<ApiKeyAuthConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiKeyAuthConfigCopyWith<$Res> {
  factory $ApiKeyAuthConfigCopyWith(
    ApiKeyAuthConfig value,
    $Res Function(ApiKeyAuthConfig) then,
  ) = _$ApiKeyAuthConfigCopyWithImpl<$Res, ApiKeyAuthConfig>;
  @useResult
  $Res call({
    String type,
    String providerId,
    String apiKey,
    String? apiSecret,
    String? baseUrl,
  });
}

/// @nodoc
class _$ApiKeyAuthConfigCopyWithImpl<$Res, $Val extends ApiKeyAuthConfig>
    implements $ApiKeyAuthConfigCopyWith<$Res> {
  _$ApiKeyAuthConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ApiKeyAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? apiKey = null,
    Object? apiSecret = freezed,
    Object? baseUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            providerId:
                null == providerId
                    ? _value.providerId
                    : providerId // ignore: cast_nullable_to_non_nullable
                        as String,
            apiKey:
                null == apiKey
                    ? _value.apiKey
                    : apiKey // ignore: cast_nullable_to_non_nullable
                        as String,
            apiSecret:
                freezed == apiSecret
                    ? _value.apiSecret
                    : apiSecret // ignore: cast_nullable_to_non_nullable
                        as String?,
            baseUrl:
                freezed == baseUrl
                    ? _value.baseUrl
                    : baseUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ApiKeyAuthConfigImplCopyWith<$Res>
    implements $ApiKeyAuthConfigCopyWith<$Res> {
  factory _$$ApiKeyAuthConfigImplCopyWith(
    _$ApiKeyAuthConfigImpl value,
    $Res Function(_$ApiKeyAuthConfigImpl) then,
  ) = __$$ApiKeyAuthConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String providerId,
    String apiKey,
    String? apiSecret,
    String? baseUrl,
  });
}

/// @nodoc
class __$$ApiKeyAuthConfigImplCopyWithImpl<$Res>
    extends _$ApiKeyAuthConfigCopyWithImpl<$Res, _$ApiKeyAuthConfigImpl>
    implements _$$ApiKeyAuthConfigImplCopyWith<$Res> {
  __$$ApiKeyAuthConfigImplCopyWithImpl(
    _$ApiKeyAuthConfigImpl _value,
    $Res Function(_$ApiKeyAuthConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ApiKeyAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? apiKey = null,
    Object? apiSecret = freezed,
    Object? baseUrl = freezed,
  }) {
    return _then(
      _$ApiKeyAuthConfigImpl(
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        providerId:
            null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                    as String,
        apiKey:
            null == apiKey
                ? _value.apiKey
                : apiKey // ignore: cast_nullable_to_non_nullable
                    as String,
        apiSecret:
            freezed == apiSecret
                ? _value.apiSecret
                : apiSecret // ignore: cast_nullable_to_non_nullable
                    as String?,
        baseUrl:
            freezed == baseUrl
                ? _value.baseUrl
                : baseUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiKeyAuthConfigImpl implements _ApiKeyAuthConfig {
  const _$ApiKeyAuthConfigImpl({
    this.type = 'apiKey',
    required this.providerId,
    required this.apiKey,
    this.apiSecret,
    this.baseUrl,
  });

  factory _$ApiKeyAuthConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiKeyAuthConfigImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  @override
  final String providerId;
  @override
  final String apiKey;
  @override
  final String? apiSecret;
  @override
  final String? baseUrl;

  @override
  String toString() {
    return 'ApiKeyAuthConfig(type: $type, providerId: $providerId, apiKey: $apiKey, apiSecret: $apiSecret, baseUrl: $baseUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiKeyAuthConfigImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            (identical(other.apiSecret, apiSecret) ||
                other.apiSecret == apiSecret) &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, providerId, apiKey, apiSecret, baseUrl);

  /// Create a copy of ApiKeyAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiKeyAuthConfigImplCopyWith<_$ApiKeyAuthConfigImpl> get copyWith =>
      __$$ApiKeyAuthConfigImplCopyWithImpl<_$ApiKeyAuthConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiKeyAuthConfigImplToJson(this);
  }
}

abstract class _ApiKeyAuthConfig implements ApiKeyAuthConfig {
  const factory _ApiKeyAuthConfig({
    final String type,
    required final String providerId,
    required final String apiKey,
    final String? apiSecret,
    final String? baseUrl,
  }) = _$ApiKeyAuthConfigImpl;

  factory _ApiKeyAuthConfig.fromJson(Map<String, dynamic> json) =
      _$ApiKeyAuthConfigImpl.fromJson;

  @override
  String get type;
  @override
  String get providerId;
  @override
  String get apiKey;
  @override
  String? get apiSecret;
  @override
  String? get baseUrl;

  /// Create a copy of ApiKeyAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ApiKeyAuthConfigImplCopyWith<_$ApiKeyAuthConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BasicAuthConfig _$BasicAuthConfigFromJson(Map<String, dynamic> json) {
  return _BasicAuthConfig.fromJson(json);
}

/// @nodoc
mixin _$BasicAuthConfig {
  String get type => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String? get baseUrl => throw _privateConstructorUsedError;

  /// Serializes this BasicAuthConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BasicAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BasicAuthConfigCopyWith<BasicAuthConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BasicAuthConfigCopyWith<$Res> {
  factory $BasicAuthConfigCopyWith(
    BasicAuthConfig value,
    $Res Function(BasicAuthConfig) then,
  ) = _$BasicAuthConfigCopyWithImpl<$Res, BasicAuthConfig>;
  @useResult
  $Res call({
    String type,
    String providerId,
    String username,
    String password,
    String? baseUrl,
  });
}

/// @nodoc
class _$BasicAuthConfigCopyWithImpl<$Res, $Val extends BasicAuthConfig>
    implements $BasicAuthConfigCopyWith<$Res> {
  _$BasicAuthConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BasicAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? username = null,
    Object? password = null,
    Object? baseUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            providerId:
                null == providerId
                    ? _value.providerId
                    : providerId // ignore: cast_nullable_to_non_nullable
                        as String,
            username:
                null == username
                    ? _value.username
                    : username // ignore: cast_nullable_to_non_nullable
                        as String,
            password:
                null == password
                    ? _value.password
                    : password // ignore: cast_nullable_to_non_nullable
                        as String,
            baseUrl:
                freezed == baseUrl
                    ? _value.baseUrl
                    : baseUrl // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BasicAuthConfigImplCopyWith<$Res>
    implements $BasicAuthConfigCopyWith<$Res> {
  factory _$$BasicAuthConfigImplCopyWith(
    _$BasicAuthConfigImpl value,
    $Res Function(_$BasicAuthConfigImpl) then,
  ) = __$$BasicAuthConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String type,
    String providerId,
    String username,
    String password,
    String? baseUrl,
  });
}

/// @nodoc
class __$$BasicAuthConfigImplCopyWithImpl<$Res>
    extends _$BasicAuthConfigCopyWithImpl<$Res, _$BasicAuthConfigImpl>
    implements _$$BasicAuthConfigImplCopyWith<$Res> {
  __$$BasicAuthConfigImplCopyWithImpl(
    _$BasicAuthConfigImpl _value,
    $Res Function(_$BasicAuthConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BasicAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? username = null,
    Object? password = null,
    Object? baseUrl = freezed,
  }) {
    return _then(
      _$BasicAuthConfigImpl(
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        providerId:
            null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                    as String,
        username:
            null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                    as String,
        password:
            null == password
                ? _value.password
                : password // ignore: cast_nullable_to_non_nullable
                    as String,
        baseUrl:
            freezed == baseUrl
                ? _value.baseUrl
                : baseUrl // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BasicAuthConfigImpl implements _BasicAuthConfig {
  const _$BasicAuthConfigImpl({
    this.type = 'basicAuth',
    required this.providerId,
    required this.username,
    required this.password,
    this.baseUrl,
  });

  factory _$BasicAuthConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$BasicAuthConfigImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  @override
  final String providerId;
  @override
  final String username;
  @override
  final String password;
  @override
  final String? baseUrl;

  @override
  String toString() {
    return 'BasicAuthConfig(type: $type, providerId: $providerId, username: $username, password: $password, baseUrl: $baseUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BasicAuthConfigImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, providerId, username, password, baseUrl);

  /// Create a copy of BasicAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BasicAuthConfigImplCopyWith<_$BasicAuthConfigImpl> get copyWith =>
      __$$BasicAuthConfigImplCopyWithImpl<_$BasicAuthConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$BasicAuthConfigImplToJson(this);
  }
}

abstract class _BasicAuthConfig implements BasicAuthConfig {
  const factory _BasicAuthConfig({
    final String type,
    required final String providerId,
    required final String username,
    required final String password,
    final String? baseUrl,
  }) = _$BasicAuthConfigImpl;

  factory _BasicAuthConfig.fromJson(Map<String, dynamic> json) =
      _$BasicAuthConfigImpl.fromJson;

  @override
  String get type;
  @override
  String get providerId;
  @override
  String get username;
  @override
  String get password;
  @override
  String? get baseUrl;

  /// Create a copy of BasicAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BasicAuthConfigImplCopyWith<_$BasicAuthConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LocalOpmlAuthConfig _$LocalOpmlAuthConfigFromJson(Map<String, dynamic> json) {
  return _LocalOpmlAuthConfig.fromJson(json);
}

/// @nodoc
mixin _$LocalOpmlAuthConfig {
  String get type => throw _privateConstructorUsedError;
  String get providerId => throw _privateConstructorUsedError;
  String get filePath => throw _privateConstructorUsedError;

  /// Serializes this LocalOpmlAuthConfig to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocalOpmlAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocalOpmlAuthConfigCopyWith<LocalOpmlAuthConfig> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocalOpmlAuthConfigCopyWith<$Res> {
  factory $LocalOpmlAuthConfigCopyWith(
    LocalOpmlAuthConfig value,
    $Res Function(LocalOpmlAuthConfig) then,
  ) = _$LocalOpmlAuthConfigCopyWithImpl<$Res, LocalOpmlAuthConfig>;
  @useResult
  $Res call({String type, String providerId, String filePath});
}

/// @nodoc
class _$LocalOpmlAuthConfigCopyWithImpl<$Res, $Val extends LocalOpmlAuthConfig>
    implements $LocalOpmlAuthConfigCopyWith<$Res> {
  _$LocalOpmlAuthConfigCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocalOpmlAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? filePath = null,
  }) {
    return _then(
      _value.copyWith(
            type:
                null == type
                    ? _value.type
                    : type // ignore: cast_nullable_to_non_nullable
                        as String,
            providerId:
                null == providerId
                    ? _value.providerId
                    : providerId // ignore: cast_nullable_to_non_nullable
                        as String,
            filePath:
                null == filePath
                    ? _value.filePath
                    : filePath // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocalOpmlAuthConfigImplCopyWith<$Res>
    implements $LocalOpmlAuthConfigCopyWith<$Res> {
  factory _$$LocalOpmlAuthConfigImplCopyWith(
    _$LocalOpmlAuthConfigImpl value,
    $Res Function(_$LocalOpmlAuthConfigImpl) then,
  ) = __$$LocalOpmlAuthConfigImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String type, String providerId, String filePath});
}

/// @nodoc
class __$$LocalOpmlAuthConfigImplCopyWithImpl<$Res>
    extends _$LocalOpmlAuthConfigCopyWithImpl<$Res, _$LocalOpmlAuthConfigImpl>
    implements _$$LocalOpmlAuthConfigImplCopyWith<$Res> {
  __$$LocalOpmlAuthConfigImplCopyWithImpl(
    _$LocalOpmlAuthConfigImpl _value,
    $Res Function(_$LocalOpmlAuthConfigImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocalOpmlAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? providerId = null,
    Object? filePath = null,
  }) {
    return _then(
      _$LocalOpmlAuthConfigImpl(
        type:
            null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                    as String,
        providerId:
            null == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                    as String,
        filePath:
            null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocalOpmlAuthConfigImpl implements _LocalOpmlAuthConfig {
  const _$LocalOpmlAuthConfigImpl({
    this.type = 'localOpml',
    required this.providerId,
    required this.filePath,
  });

  factory _$LocalOpmlAuthConfigImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocalOpmlAuthConfigImplFromJson(json);

  @override
  @JsonKey()
  final String type;
  @override
  final String providerId;
  @override
  final String filePath;

  @override
  String toString() {
    return 'LocalOpmlAuthConfig(type: $type, providerId: $providerId, filePath: $filePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocalOpmlAuthConfigImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, providerId, filePath);

  /// Create a copy of LocalOpmlAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocalOpmlAuthConfigImplCopyWith<_$LocalOpmlAuthConfigImpl> get copyWith =>
      __$$LocalOpmlAuthConfigImplCopyWithImpl<_$LocalOpmlAuthConfigImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$LocalOpmlAuthConfigImplToJson(this);
  }
}

abstract class _LocalOpmlAuthConfig implements LocalOpmlAuthConfig {
  const factory _LocalOpmlAuthConfig({
    final String type,
    required final String providerId,
    required final String filePath,
  }) = _$LocalOpmlAuthConfigImpl;

  factory _LocalOpmlAuthConfig.fromJson(Map<String, dynamic> json) =
      _$LocalOpmlAuthConfigImpl.fromJson;

  @override
  String get type;
  @override
  String get providerId;
  @override
  String get filePath;

  /// Create a copy of LocalOpmlAuthConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocalOpmlAuthConfigImplCopyWith<_$LocalOpmlAuthConfigImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

AuthResult _$AuthResultFromJson(Map<String, dynamic> json) {
  return _AuthResult.fromJson(json);
}

/// @nodoc
mixin _$AuthResult {
  bool get success => throw _privateConstructorUsedError;
  GoogleLoginAuthConfig? get config => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  String? get userId => throw _privateConstructorUsedError;
  String? get userName => throw _privateConstructorUsedError;

  /// Serializes this AuthResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResultCopyWith<AuthResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResultCopyWith<$Res> {
  factory $AuthResultCopyWith(
    AuthResult value,
    $Res Function(AuthResult) then,
  ) = _$AuthResultCopyWithImpl<$Res, AuthResult>;
  @useResult
  $Res call({
    bool success,
    GoogleLoginAuthConfig? config,
    String? error,
    String? userId,
    String? userName,
  });

  $GoogleLoginAuthConfigCopyWith<$Res>? get config;
}

/// @nodoc
class _$AuthResultCopyWithImpl<$Res, $Val extends AuthResult>
    implements $AuthResultCopyWith<$Res> {
  _$AuthResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? config = freezed,
    Object? error = freezed,
    Object? userId = freezed,
    Object? userName = freezed,
  }) {
    return _then(
      _value.copyWith(
            success:
                null == success
                    ? _value.success
                    : success // ignore: cast_nullable_to_non_nullable
                        as bool,
            config:
                freezed == config
                    ? _value.config
                    : config // ignore: cast_nullable_to_non_nullable
                        as GoogleLoginAuthConfig?,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
            userId:
                freezed == userId
                    ? _value.userId
                    : userId // ignore: cast_nullable_to_non_nullable
                        as String?,
            userName:
                freezed == userName
                    ? _value.userName
                    : userName // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GoogleLoginAuthConfigCopyWith<$Res>? get config {
    if (_value.config == null) {
      return null;
    }

    return $GoogleLoginAuthConfigCopyWith<$Res>(_value.config!, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResultImplCopyWith<$Res>
    implements $AuthResultCopyWith<$Res> {
  factory _$$AuthResultImplCopyWith(
    _$AuthResultImpl value,
    $Res Function(_$AuthResultImpl) then,
  ) = __$$AuthResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    GoogleLoginAuthConfig? config,
    String? error,
    String? userId,
    String? userName,
  });

  @override
  $GoogleLoginAuthConfigCopyWith<$Res>? get config;
}

/// @nodoc
class __$$AuthResultImplCopyWithImpl<$Res>
    extends _$AuthResultCopyWithImpl<$Res, _$AuthResultImpl>
    implements _$$AuthResultImplCopyWith<$Res> {
  __$$AuthResultImplCopyWithImpl(
    _$AuthResultImpl _value,
    $Res Function(_$AuthResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? config = freezed,
    Object? error = freezed,
    Object? userId = freezed,
    Object? userName = freezed,
  }) {
    return _then(
      _$AuthResultImpl(
        success:
            null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                    as bool,
        config:
            freezed == config
                ? _value.config
                : config // ignore: cast_nullable_to_non_nullable
                    as GoogleLoginAuthConfig?,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
        userId:
            freezed == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                    as String?,
        userName:
            freezed == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResultImpl implements _AuthResult {
  const _$AuthResultImpl({
    required this.success,
    this.config,
    this.error,
    this.userId,
    this.userName,
  });

  factory _$AuthResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResultImplFromJson(json);

  @override
  final bool success;
  @override
  final GoogleLoginAuthConfig? config;
  @override
  final String? error;
  @override
  final String? userId;
  @override
  final String? userName;

  @override
  String toString() {
    return 'AuthResult(success: $success, config: $config, error: $error, userId: $userId, userName: $userName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, config, error, userId, userName);

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      __$$AuthResultImplCopyWithImpl<_$AuthResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResultImplToJson(this);
  }
}

abstract class _AuthResult implements AuthResult {
  const factory _AuthResult({
    required final bool success,
    final GoogleLoginAuthConfig? config,
    final String? error,
    final String? userId,
    final String? userName,
  }) = _$AuthResultImpl;

  factory _AuthResult.fromJson(Map<String, dynamic> json) =
      _$AuthResultImpl.fromJson;

  @override
  bool get success;
  @override
  GoogleLoginAuthConfig? get config;
  @override
  String? get error;
  @override
  String? get userId;
  @override
  String? get userName;

  /// Create a copy of AuthResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResultImplCopyWith<_$AuthResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FeedResult _$FeedResultFromJson(Map<String, dynamic> json) {
  return _FeedResult.fromJson(json);
}

/// @nodoc
mixin _$FeedResult {
  bool get success => throw _privateConstructorUsedError;
  String? get feedId => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Feed? get feed => throw _privateConstructorUsedError;

  /// Serializes this FeedResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FeedResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FeedResultCopyWith<FeedResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FeedResultCopyWith<$Res> {
  factory $FeedResultCopyWith(
    FeedResult value,
    $Res Function(FeedResult) then,
  ) = _$FeedResultCopyWithImpl<$Res, FeedResult>;
  @useResult
  $Res call({bool success, String? feedId, String? error, Feed? feed});

  $FeedCopyWith<$Res>? get feed;
}

/// @nodoc
class _$FeedResultCopyWithImpl<$Res, $Val extends FeedResult>
    implements $FeedResultCopyWith<$Res> {
  _$FeedResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FeedResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? feedId = freezed,
    Object? error = freezed,
    Object? feed = freezed,
  }) {
    return _then(
      _value.copyWith(
            success:
                null == success
                    ? _value.success
                    : success // ignore: cast_nullable_to_non_nullable
                        as bool,
            feedId:
                freezed == feedId
                    ? _value.feedId
                    : feedId // ignore: cast_nullable_to_non_nullable
                        as String?,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
            feed:
                freezed == feed
                    ? _value.feed
                    : feed // ignore: cast_nullable_to_non_nullable
                        as Feed?,
          )
          as $Val,
    );
  }

  /// Create a copy of FeedResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FeedCopyWith<$Res>? get feed {
    if (_value.feed == null) {
      return null;
    }

    return $FeedCopyWith<$Res>(_value.feed!, (value) {
      return _then(_value.copyWith(feed: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FeedResultImplCopyWith<$Res>
    implements $FeedResultCopyWith<$Res> {
  factory _$$FeedResultImplCopyWith(
    _$FeedResultImpl value,
    $Res Function(_$FeedResultImpl) then,
  ) = __$$FeedResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String? feedId, String? error, Feed? feed});

  @override
  $FeedCopyWith<$Res>? get feed;
}

/// @nodoc
class __$$FeedResultImplCopyWithImpl<$Res>
    extends _$FeedResultCopyWithImpl<$Res, _$FeedResultImpl>
    implements _$$FeedResultImplCopyWith<$Res> {
  __$$FeedResultImplCopyWithImpl(
    _$FeedResultImpl _value,
    $Res Function(_$FeedResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FeedResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? feedId = freezed,
    Object? error = freezed,
    Object? feed = freezed,
  }) {
    return _then(
      _$FeedResultImpl(
        success:
            null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                    as bool,
        feedId:
            freezed == feedId
                ? _value.feedId
                : feedId // ignore: cast_nullable_to_non_nullable
                    as String?,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
        feed:
            freezed == feed
                ? _value.feed
                : feed // ignore: cast_nullable_to_non_nullable
                    as Feed?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FeedResultImpl implements _FeedResult {
  const _$FeedResultImpl({
    required this.success,
    this.feedId,
    this.error,
    this.feed,
  });

  factory _$FeedResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$FeedResultImplFromJson(json);

  @override
  final bool success;
  @override
  final String? feedId;
  @override
  final String? error;
  @override
  final Feed? feed;

  @override
  String toString() {
    return 'FeedResult(success: $success, feedId: $feedId, error: $error, feed: $feed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FeedResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.feedId, feedId) || other.feedId == feedId) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.feed, feed) || other.feed == feed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, feedId, error, feed);

  /// Create a copy of FeedResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FeedResultImplCopyWith<_$FeedResultImpl> get copyWith =>
      __$$FeedResultImplCopyWithImpl<_$FeedResultImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FeedResultImplToJson(this);
  }
}

abstract class _FeedResult implements FeedResult {
  const factory _FeedResult({
    required final bool success,
    final String? feedId,
    final String? error,
    final Feed? feed,
  }) = _$FeedResultImpl;

  factory _FeedResult.fromJson(Map<String, dynamic> json) =
      _$FeedResultImpl.fromJson;

  @override
  bool get success;
  @override
  String? get feedId;
  @override
  String? get error;
  @override
  Feed? get feed;

  /// Create a copy of FeedResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FeedResultImplCopyWith<_$FeedResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CategoryResult _$CategoryResultFromJson(Map<String, dynamic> json) {
  return _CategoryResult.fromJson(json);
}

/// @nodoc
mixin _$CategoryResult {
  bool get success => throw _privateConstructorUsedError;
  String? get categoryId => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  Category? get category => throw _privateConstructorUsedError;

  /// Serializes this CategoryResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CategoryResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryResultCopyWith<CategoryResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryResultCopyWith<$Res> {
  factory $CategoryResultCopyWith(
    CategoryResult value,
    $Res Function(CategoryResult) then,
  ) = _$CategoryResultCopyWithImpl<$Res, CategoryResult>;
  @useResult
  $Res call({
    bool success,
    String? categoryId,
    String? error,
    Category? category,
  });

  $CategoryCopyWith<$Res>? get category;
}

/// @nodoc
class _$CategoryResultCopyWithImpl<$Res, $Val extends CategoryResult>
    implements $CategoryResultCopyWith<$Res> {
  _$CategoryResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CategoryResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? categoryId = freezed,
    Object? error = freezed,
    Object? category = freezed,
  }) {
    return _then(
      _value.copyWith(
            success:
                null == success
                    ? _value.success
                    : success // ignore: cast_nullable_to_non_nullable
                        as bool,
            categoryId:
                freezed == categoryId
                    ? _value.categoryId
                    : categoryId // ignore: cast_nullable_to_non_nullable
                        as String?,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
            category:
                freezed == category
                    ? _value.category
                    : category // ignore: cast_nullable_to_non_nullable
                        as Category?,
          )
          as $Val,
    );
  }

  /// Create a copy of CategoryResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CategoryCopyWith<$Res>? get category {
    if (_value.category == null) {
      return null;
    }

    return $CategoryCopyWith<$Res>(_value.category!, (value) {
      return _then(_value.copyWith(category: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CategoryResultImplCopyWith<$Res>
    implements $CategoryResultCopyWith<$Res> {
  factory _$$CategoryResultImplCopyWith(
    _$CategoryResultImpl value,
    $Res Function(_$CategoryResultImpl) then,
  ) = __$$CategoryResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool success,
    String? categoryId,
    String? error,
    Category? category,
  });

  @override
  $CategoryCopyWith<$Res>? get category;
}

/// @nodoc
class __$$CategoryResultImplCopyWithImpl<$Res>
    extends _$CategoryResultCopyWithImpl<$Res, _$CategoryResultImpl>
    implements _$$CategoryResultImplCopyWith<$Res> {
  __$$CategoryResultImplCopyWithImpl(
    _$CategoryResultImpl _value,
    $Res Function(_$CategoryResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CategoryResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? categoryId = freezed,
    Object? error = freezed,
    Object? category = freezed,
  }) {
    return _then(
      _$CategoryResultImpl(
        success:
            null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                    as bool,
        categoryId:
            freezed == categoryId
                ? _value.categoryId
                : categoryId // ignore: cast_nullable_to_non_nullable
                    as String?,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
        category:
            freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                    as Category?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryResultImpl implements _CategoryResult {
  const _$CategoryResultImpl({
    required this.success,
    this.categoryId,
    this.error,
    this.category,
  });

  factory _$CategoryResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryResultImplFromJson(json);

  @override
  final bool success;
  @override
  final String? categoryId;
  @override
  final String? error;
  @override
  final Category? category;

  @override
  String toString() {
    return 'CategoryResult(success: $success, categoryId: $categoryId, error: $error, category: $category)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.category, category) ||
                other.category == category));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, success, categoryId, error, category);

  /// Create a copy of CategoryResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryResultImplCopyWith<_$CategoryResultImpl> get copyWith =>
      __$$CategoryResultImplCopyWithImpl<_$CategoryResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryResultImplToJson(this);
  }
}

abstract class _CategoryResult implements CategoryResult {
  const factory _CategoryResult({
    required final bool success,
    final String? categoryId,
    final String? error,
    final Category? category,
  }) = _$CategoryResultImpl;

  factory _CategoryResult.fromJson(Map<String, dynamic> json) =
      _$CategoryResultImpl.fromJson;

  @override
  bool get success;
  @override
  String? get categoryId;
  @override
  String? get error;
  @override
  Category? get category;

  /// Create a copy of CategoryResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryResultImplCopyWith<_$CategoryResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OpmlImportResult _$OpmlImportResultFromJson(Map<String, dynamic> json) {
  return _OpmlImportResult.fromJson(json);
}

/// @nodoc
mixin _$OpmlImportResult {
  bool get success => throw _privateConstructorUsedError;
  List<Feed> get feeds => throw _privateConstructorUsedError;
  List<String> get errors => throw _privateConstructorUsedError;

  /// Serializes this OpmlImportResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OpmlImportResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OpmlImportResultCopyWith<OpmlImportResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OpmlImportResultCopyWith<$Res> {
  factory $OpmlImportResultCopyWith(
    OpmlImportResult value,
    $Res Function(OpmlImportResult) then,
  ) = _$OpmlImportResultCopyWithImpl<$Res, OpmlImportResult>;
  @useResult
  $Res call({bool success, List<Feed> feeds, List<String> errors});
}

/// @nodoc
class _$OpmlImportResultCopyWithImpl<$Res, $Val extends OpmlImportResult>
    implements $OpmlImportResultCopyWith<$Res> {
  _$OpmlImportResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OpmlImportResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? feeds = null,
    Object? errors = null,
  }) {
    return _then(
      _value.copyWith(
            success:
                null == success
                    ? _value.success
                    : success // ignore: cast_nullable_to_non_nullable
                        as bool,
            feeds:
                null == feeds
                    ? _value.feeds
                    : feeds // ignore: cast_nullable_to_non_nullable
                        as List<Feed>,
            errors:
                null == errors
                    ? _value.errors
                    : errors // ignore: cast_nullable_to_non_nullable
                        as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OpmlImportResultImplCopyWith<$Res>
    implements $OpmlImportResultCopyWith<$Res> {
  factory _$$OpmlImportResultImplCopyWith(
    _$OpmlImportResultImpl value,
    $Res Function(_$OpmlImportResultImpl) then,
  ) = __$$OpmlImportResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, List<Feed> feeds, List<String> errors});
}

/// @nodoc
class __$$OpmlImportResultImplCopyWithImpl<$Res>
    extends _$OpmlImportResultCopyWithImpl<$Res, _$OpmlImportResultImpl>
    implements _$$OpmlImportResultImplCopyWith<$Res> {
  __$$OpmlImportResultImplCopyWithImpl(
    _$OpmlImportResultImpl _value,
    $Res Function(_$OpmlImportResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OpmlImportResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? feeds = null,
    Object? errors = null,
  }) {
    return _then(
      _$OpmlImportResultImpl(
        success:
            null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                    as bool,
        feeds:
            null == feeds
                ? _value._feeds
                : feeds // ignore: cast_nullable_to_non_nullable
                    as List<Feed>,
        errors:
            null == errors
                ? _value._errors
                : errors // ignore: cast_nullable_to_non_nullable
                    as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OpmlImportResultImpl implements _OpmlImportResult {
  const _$OpmlImportResultImpl({
    required this.success,
    final List<Feed> feeds = const [],
    final List<String> errors = const [],
  }) : _feeds = feeds,
       _errors = errors;

  factory _$OpmlImportResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$OpmlImportResultImplFromJson(json);

  @override
  final bool success;
  final List<Feed> _feeds;
  @override
  @JsonKey()
  List<Feed> get feeds {
    if (_feeds is EqualUnmodifiableListView) return _feeds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feeds);
  }

  final List<String> _errors;
  @override
  @JsonKey()
  List<String> get errors {
    if (_errors is EqualUnmodifiableListView) return _errors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_errors);
  }

  @override
  String toString() {
    return 'OpmlImportResult(success: $success, feeds: $feeds, errors: $errors)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OpmlImportResultImpl &&
            (identical(other.success, success) || other.success == success) &&
            const DeepCollectionEquality().equals(other._feeds, _feeds) &&
            const DeepCollectionEquality().equals(other._errors, _errors));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    const DeepCollectionEquality().hash(_feeds),
    const DeepCollectionEquality().hash(_errors),
  );

  /// Create a copy of OpmlImportResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OpmlImportResultImplCopyWith<_$OpmlImportResultImpl> get copyWith =>
      __$$OpmlImportResultImplCopyWithImpl<_$OpmlImportResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OpmlImportResultImplToJson(this);
  }
}

abstract class _OpmlImportResult implements OpmlImportResult {
  const factory _OpmlImportResult({
    required final bool success,
    final List<Feed> feeds,
    final List<String> errors,
  }) = _$OpmlImportResultImpl;

  factory _OpmlImportResult.fromJson(Map<String, dynamic> json) =
      _$OpmlImportResultImpl.fromJson;

  @override
  bool get success;
  @override
  List<Feed> get feeds;
  @override
  List<String> get errors;

  /// Create a copy of OpmlImportResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OpmlImportResultImplCopyWith<_$OpmlImportResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
