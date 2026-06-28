// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'article.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Article _$ArticleFromJson(Map<String, dynamic> json) {
  return _Article.fromJson(json);
}

/// @nodoc
mixin _$Article {
  String get id => throw _privateConstructorUsedError;
  String get feedId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get author => throw _privateConstructorUsedError;
  String? get summary => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  DateTime? get published => throw _privateConstructorUsedError;
  DateTime? get updated => throw _privateConstructorUsedError;
  List<String> get categories => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  bool get isStarred => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;

  /// Serializes this Article to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleCopyWith<Article> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleCopyWith<$Res> {
  factory $ArticleCopyWith(Article value, $Res Function(Article) then) =
      _$ArticleCopyWithImpl<$Res, Article>;
  @useResult
  $Res call({
    String id,
    String feedId,
    String title,
    String? author,
    String? summary,
    String? content,
    String? url,
    DateTime? published,
    DateTime? updated,
    List<String> categories,
    bool isRead,
    bool isStarred,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class _$ArticleCopyWithImpl<$Res, $Val extends Article>
    implements $ArticleCopyWith<$Res> {
  _$ArticleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? feedId = null,
    Object? title = null,
    Object? author = freezed,
    Object? summary = freezed,
    Object? content = freezed,
    Object? url = freezed,
    Object? published = freezed,
    Object? updated = freezed,
    Object? categories = null,
    Object? isRead = null,
    Object? isStarred = null,
    Object? metadata = null,
  }) {
    return _then(
      _value.copyWith(
            id:
                null == id
                    ? _value.id
                    : id // ignore: cast_nullable_to_non_nullable
                        as String,
            feedId:
                null == feedId
                    ? _value.feedId
                    : feedId // ignore: cast_nullable_to_non_nullable
                        as String,
            title:
                null == title
                    ? _value.title
                    : title // ignore: cast_nullable_to_non_nullable
                        as String,
            author:
                freezed == author
                    ? _value.author
                    : author // ignore: cast_nullable_to_non_nullable
                        as String?,
            summary:
                freezed == summary
                    ? _value.summary
                    : summary // ignore: cast_nullable_to_non_nullable
                        as String?,
            content:
                freezed == content
                    ? _value.content
                    : content // ignore: cast_nullable_to_non_nullable
                        as String?,
            url:
                freezed == url
                    ? _value.url
                    : url // ignore: cast_nullable_to_non_nullable
                        as String?,
            published:
                freezed == published
                    ? _value.published
                    : published // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            updated:
                freezed == updated
                    ? _value.updated
                    : updated // ignore: cast_nullable_to_non_nullable
                        as DateTime?,
            categories:
                null == categories
                    ? _value.categories
                    : categories // ignore: cast_nullable_to_non_nullable
                        as List<String>,
            isRead:
                null == isRead
                    ? _value.isRead
                    : isRead // ignore: cast_nullable_to_non_nullable
                        as bool,
            isStarred:
                null == isStarred
                    ? _value.isStarred
                    : isStarred // ignore: cast_nullable_to_non_nullable
                        as bool,
            metadata:
                null == metadata
                    ? _value.metadata
                    : metadata // ignore: cast_nullable_to_non_nullable
                        as Map<String, dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArticleImplCopyWith<$Res> implements $ArticleCopyWith<$Res> {
  factory _$$ArticleImplCopyWith(
    _$ArticleImpl value,
    $Res Function(_$ArticleImpl) then,
  ) = __$$ArticleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String feedId,
    String title,
    String? author,
    String? summary,
    String? content,
    String? url,
    DateTime? published,
    DateTime? updated,
    List<String> categories,
    bool isRead,
    bool isStarred,
    Map<String, dynamic> metadata,
  });
}

/// @nodoc
class __$$ArticleImplCopyWithImpl<$Res>
    extends _$ArticleCopyWithImpl<$Res, _$ArticleImpl>
    implements _$$ArticleImplCopyWith<$Res> {
  __$$ArticleImplCopyWithImpl(
    _$ArticleImpl _value,
    $Res Function(_$ArticleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? feedId = null,
    Object? title = null,
    Object? author = freezed,
    Object? summary = freezed,
    Object? content = freezed,
    Object? url = freezed,
    Object? published = freezed,
    Object? updated = freezed,
    Object? categories = null,
    Object? isRead = null,
    Object? isStarred = null,
    Object? metadata = null,
  }) {
    return _then(
      _$ArticleImpl(
        id:
            null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                    as String,
        feedId:
            null == feedId
                ? _value.feedId
                : feedId // ignore: cast_nullable_to_non_nullable
                    as String,
        title:
            null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                    as String,
        author:
            freezed == author
                ? _value.author
                : author // ignore: cast_nullable_to_non_nullable
                    as String?,
        summary:
            freezed == summary
                ? _value.summary
                : summary // ignore: cast_nullable_to_non_nullable
                    as String?,
        content:
            freezed == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                    as String?,
        url:
            freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                    as String?,
        published:
            freezed == published
                ? _value.published
                : published // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        updated:
            freezed == updated
                ? _value.updated
                : updated // ignore: cast_nullable_to_non_nullable
                    as DateTime?,
        categories:
            null == categories
                ? _value._categories
                : categories // ignore: cast_nullable_to_non_nullable
                    as List<String>,
        isRead:
            null == isRead
                ? _value.isRead
                : isRead // ignore: cast_nullable_to_non_nullable
                    as bool,
        isStarred:
            null == isStarred
                ? _value.isStarred
                : isStarred // ignore: cast_nullable_to_non_nullable
                    as bool,
        metadata:
            null == metadata
                ? _value._metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                    as Map<String, dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleImpl implements _Article {
  const _$ArticleImpl({
    required this.id,
    required this.feedId,
    required this.title,
    this.author,
    this.summary,
    this.content,
    this.url,
    this.published,
    this.updated,
    final List<String> categories = const [],
    this.isRead = false,
    this.isStarred = false,
    final Map<String, dynamic> metadata = const {},
  }) : _categories = categories,
       _metadata = metadata;

  factory _$ArticleImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleImplFromJson(json);

  @override
  final String id;
  @override
  final String feedId;
  @override
  final String title;
  @override
  final String? author;
  @override
  final String? summary;
  @override
  final String? content;
  @override
  final String? url;
  @override
  final DateTime? published;
  @override
  final DateTime? updated;
  final List<String> _categories;
  @override
  @JsonKey()
  List<String> get categories {
    if (_categories is EqualUnmodifiableListView) return _categories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categories);
  }

  @override
  @JsonKey()
  final bool isRead;
  @override
  @JsonKey()
  final bool isStarred;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  @override
  String toString() {
    return 'Article(id: $id, feedId: $feedId, title: $title, author: $author, summary: $summary, content: $content, url: $url, published: $published, updated: $updated, categories: $categories, isRead: $isRead, isStarred: $isStarred, metadata: $metadata)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.feedId, feedId) || other.feedId == feedId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.summary, summary) || other.summary == summary) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.published, published) ||
                other.published == published) &&
            (identical(other.updated, updated) || other.updated == updated) &&
            const DeepCollectionEquality().equals(
              other._categories,
              _categories,
            ) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.isStarred, isStarred) ||
                other.isStarred == isStarred) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    feedId,
    title,
    author,
    summary,
    content,
    url,
    published,
    updated,
    const DeepCollectionEquality().hash(_categories),
    isRead,
    isStarred,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleImplCopyWith<_$ArticleImpl> get copyWith =>
      __$$ArticleImplCopyWithImpl<_$ArticleImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleImplToJson(this);
  }
}

abstract class _Article implements Article {
  const factory _Article({
    required final String id,
    required final String feedId,
    required final String title,
    final String? author,
    final String? summary,
    final String? content,
    final String? url,
    final DateTime? published,
    final DateTime? updated,
    final List<String> categories,
    final bool isRead,
    final bool isStarred,
    final Map<String, dynamic> metadata,
  }) = _$ArticleImpl;

  factory _Article.fromJson(Map<String, dynamic> json) = _$ArticleImpl.fromJson;

  @override
  String get id;
  @override
  String get feedId;
  @override
  String get title;
  @override
  String? get author;
  @override
  String? get summary;
  @override
  String? get content;
  @override
  String? get url;
  @override
  DateTime? get published;
  @override
  DateTime? get updated;
  @override
  List<String> get categories;
  @override
  bool get isRead;
  @override
  bool get isStarred;
  @override
  Map<String, dynamic> get metadata;

  /// Create a copy of Article
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleImplCopyWith<_$ArticleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ArticleListResult _$ArticleListResultFromJson(Map<String, dynamic> json) {
  return _ArticleListResult.fromJson(json);
}

/// @nodoc
mixin _$ArticleListResult {
  List<Article> get articles => throw _privateConstructorUsedError;
  String? get continuation => throw _privateConstructorUsedError;
  int? get totalCount => throw _privateConstructorUsedError;

  /// Serializes this ArticleListResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ArticleListResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ArticleListResultCopyWith<ArticleListResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ArticleListResultCopyWith<$Res> {
  factory $ArticleListResultCopyWith(
    ArticleListResult value,
    $Res Function(ArticleListResult) then,
  ) = _$ArticleListResultCopyWithImpl<$Res, ArticleListResult>;
  @useResult
  $Res call({List<Article> articles, String? continuation, int? totalCount});
}

/// @nodoc
class _$ArticleListResultCopyWithImpl<$Res, $Val extends ArticleListResult>
    implements $ArticleListResultCopyWith<$Res> {
  _$ArticleListResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ArticleListResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? articles = null,
    Object? continuation = freezed,
    Object? totalCount = freezed,
  }) {
    return _then(
      _value.copyWith(
            articles:
                null == articles
                    ? _value.articles
                    : articles // ignore: cast_nullable_to_non_nullable
                        as List<Article>,
            continuation:
                freezed == continuation
                    ? _value.continuation
                    : continuation // ignore: cast_nullable_to_non_nullable
                        as String?,
            totalCount:
                freezed == totalCount
                    ? _value.totalCount
                    : totalCount // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ArticleListResultImplCopyWith<$Res>
    implements $ArticleListResultCopyWith<$Res> {
  factory _$$ArticleListResultImplCopyWith(
    _$ArticleListResultImpl value,
    $Res Function(_$ArticleListResultImpl) then,
  ) = __$$ArticleListResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Article> articles, String? continuation, int? totalCount});
}

/// @nodoc
class __$$ArticleListResultImplCopyWithImpl<$Res>
    extends _$ArticleListResultCopyWithImpl<$Res, _$ArticleListResultImpl>
    implements _$$ArticleListResultImplCopyWith<$Res> {
  __$$ArticleListResultImplCopyWithImpl(
    _$ArticleListResultImpl _value,
    $Res Function(_$ArticleListResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ArticleListResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? articles = null,
    Object? continuation = freezed,
    Object? totalCount = freezed,
  }) {
    return _then(
      _$ArticleListResultImpl(
        articles:
            null == articles
                ? _value._articles
                : articles // ignore: cast_nullable_to_non_nullable
                    as List<Article>,
        continuation:
            freezed == continuation
                ? _value.continuation
                : continuation // ignore: cast_nullable_to_non_nullable
                    as String?,
        totalCount:
            freezed == totalCount
                ? _value.totalCount
                : totalCount // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ArticleListResultImpl implements _ArticleListResult {
  const _$ArticleListResultImpl({
    required final List<Article> articles,
    this.continuation,
    this.totalCount,
  }) : _articles = articles;

  factory _$ArticleListResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ArticleListResultImplFromJson(json);

  final List<Article> _articles;
  @override
  List<Article> get articles {
    if (_articles is EqualUnmodifiableListView) return _articles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_articles);
  }

  @override
  final String? continuation;
  @override
  final int? totalCount;

  @override
  String toString() {
    return 'ArticleListResult(articles: $articles, continuation: $continuation, totalCount: $totalCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ArticleListResultImpl &&
            const DeepCollectionEquality().equals(other._articles, _articles) &&
            (identical(other.continuation, continuation) ||
                other.continuation == continuation) &&
            (identical(other.totalCount, totalCount) ||
                other.totalCount == totalCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_articles),
    continuation,
    totalCount,
  );

  /// Create a copy of ArticleListResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ArticleListResultImplCopyWith<_$ArticleListResultImpl> get copyWith =>
      __$$ArticleListResultImplCopyWithImpl<_$ArticleListResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ArticleListResultImplToJson(this);
  }
}

abstract class _ArticleListResult implements ArticleListResult {
  const factory _ArticleListResult({
    required final List<Article> articles,
    final String? continuation,
    final int? totalCount,
  }) = _$ArticleListResultImpl;

  factory _ArticleListResult.fromJson(Map<String, dynamic> json) =
      _$ArticleListResultImpl.fromJson;

  @override
  List<Article> get articles;
  @override
  String? get continuation;
  @override
  int? get totalCount;

  /// Create a copy of ArticleListResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ArticleListResultImplCopyWith<_$ArticleListResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
