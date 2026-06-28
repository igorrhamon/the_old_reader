// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return _Category.fromJson(json);
}

/// @nodoc
mixin _$Category {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get unreadCount => throw _privateConstructorUsedError;
  List<Feed> get feeds => throw _privateConstructorUsedError;

  /// Serializes this Category to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CategoryCopyWith<Category> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) then) =
      _$CategoryCopyWithImpl<$Res, Category>;
  @useResult
  $Res call({String id, String name, int unreadCount, List<Feed> feeds});
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res, $Val extends Category>
    implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? unreadCount = null,
    Object? feeds = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            name:
                null == name
                    ? _value.name
                    : name // ignore: cast_nullable_to_non_nullable
                        as String,
            unreadCount:
                null == unreadCount
                    ? _value.unreadCount
                    : unreadCount // ignore: cast_nullable_to_non_nullable
                        as int,
            feeds:
                null == feeds
                    ? _value.feeds
                    : feeds // ignore: cast_nullable_to_non_nullable
                        as List<Feed>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CategoryImplCopyWith<$Res>
    implements $CategoryCopyWith<$Res> {
  factory _$$CategoryImplCopyWith(
    _$CategoryImpl value,
    $Res Function(_$CategoryImpl) then,
  ) = __$$CategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String name, int unreadCount, List<Feed> feeds});
}

/// @nodoc
class __$$CategoryImplCopyWithImpl<$Res>
    extends _$CategoryCopyWithImpl<$Res, _$CategoryImpl>
    implements _$$CategoryImplCopyWith<$Res> {
  __$$CategoryImplCopyWithImpl(
    _$CategoryImpl _value,
    $Res Function(_$CategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? unreadCount = null,
    Object? feeds = null,
  }) {
    return _then(
      _$CategoryImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        name:
            null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                    as String,
        unreadCount:
            null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                    as int,
        feeds:
            null == feeds
                ? _value._feeds
                : feeds // ignore: cast_nullable_to_non_nullable
                    as List<Feed>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CategoryImpl implements _Category {
  const _$CategoryImpl({
    required this.id,
    required this.name,
    this.unreadCount = 0,
    final List<Feed> feeds = const [],
  }) : _feeds = feeds;

  factory _$CategoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$CategoryImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  @JsonKey()
  final int unreadCount;
  final List<Feed> _feeds;
  @override
  @JsonKey()
  List<Feed> get feeds {
    if (_feeds is EqualUnmodifiableListView) return _feeds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_feeds);
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, unreadCount: $unreadCount, feeds: $feeds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            const DeepCollectionEquality().equals(other._feeds, _feeds));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    unreadCount,
    const DeepCollectionEquality().hash(_feeds),
  );

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      __$$CategoryImplCopyWithImpl<_$CategoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CategoryImplToJson(this);
  }
}

abstract class _Category implements Category {
  const factory _Category({
    required final String id,
    required final String name,
    final int unreadCount,
    final List<Feed> feeds,
  }) = _$CategoryImpl;

  factory _Category.fromJson(Map<String, dynamic> json) =
      _$CategoryImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  int get unreadCount;
  @override
  List<Feed> get feeds;

  /// Create a copy of Category
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CategoryImplCopyWith<_$CategoryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

UnreadCount _$UnreadCountFromJson(Map<String, dynamic> json) {
  return _UnreadCount.fromJson(json);
}

/// @nodoc
mixin _$UnreadCount {
  String get id => throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;
  DateTime? get updated => throw _privateConstructorUsedError;

  /// Serializes this UnreadCount to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UnreadCountCopyWith<UnreadCount> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UnreadCountCopyWith<$Res> {
  factory $UnreadCountCopyWith(
    UnreadCount value,
    $Res Function(UnreadCount) then,
  ) = _$UnreadCountCopyWithImpl<$Res, UnreadCount>;
  @useResult
  $Res call({String id, int count, DateTime? updated});
}

/// @nodoc
class _$UnreadCountCopyWithImpl<$Res, $Val extends UnreadCount>
    implements $UnreadCountCopyWith<$Res> {
  _$UnreadCountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? count = null,
    Object? updated = freezed,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            count:
                null == count
                    ? _value.count
                    : count // ignore: cast_nullable_to_non_nullable
                        as int,
            updated:
                freezed == updated
                    ? _value.updated
                    : updated // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UnreadCountImplCopyWith<$Res>
    implements $UnreadCountCopyWith<$Res> {
  factory _$$UnreadCountImplCopyWith(
    _$UnreadCountImpl value,
    $Res Function(_$UnreadCountImpl) then,
  ) = __$$UnreadCountImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, int count, DateTime? updated});
}

/// @nodoc
class __$$UnreadCountImplCopyWithImpl<$Res>
    extends _$UnreadCountCopyWithImpl<$Res, _$UnreadCountImpl>
    implements _$$UnreadCountImplCopyWith<$Res> {
  __$$UnreadCountImplCopyWithImpl(
    _$UnreadCountImpl _value,
    $Res Function(_$UnreadCountImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? count = null,
    Object? updated = freezed,
  }) {
    return _then(
      _$UnreadCountImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        count:
            null == count
                ? _value.count
                : count // ignore: cast_nullable_to_non_nullable
                    as int,
        updated:
            freezed == updated
                ? _value.updated
                : updated // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UnreadCountImpl implements _UnreadCount {
  const _$UnreadCountImpl({
    required this.id,
    required this.count,
    this.updated,
  });

  factory _$UnreadCountImpl.fromJson(Map<String, dynamic> json) =>
      _$$UnreadCountImplFromJson(json);

  @override
  final String id;
  @override
  final int count;
  @override
  final DateTime? updated;

  @override
  String toString() {
    return 'UnreadCount(id: $id, count: $count, updated: $updated)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnreadCountImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.updated, updated) || other.updated == updated));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, count, updated);

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnreadCountImplCopyWith<_$UnreadCountImpl> get copyWith =>
      __$$UnreadCountImplCopyWithImpl<_$UnreadCountImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UnreadCountImplToJson(this);
  }
}

abstract class _UnreadCount implements UnreadCount {
  const factory _UnreadCount({
    required final String id,
    required final int count,
    final DateTime? updated,
  }) = _$UnreadCountImpl;

  factory _UnreadCount.fromJson(Map<String, dynamic> json) =
      _$UnreadCountImpl.fromJson;

  @override
  String get id;
  @override
  int get count;
  @override
  DateTime? get updated;

  /// Create a copy of UnreadCount
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnreadCountImplCopyWith<_$UnreadCountImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
