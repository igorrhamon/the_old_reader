// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeedImpl _$$FeedImplFromJson(Map<String, dynamic> json) => _$FeedImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  url: json['url'] as String?,
  siteUrl: json['siteUrl'] as String?,
  iconUrl: json['iconUrl'] as String?,
  unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
  categories:
      (json['categories'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$$FeedImplToJson(_$FeedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'url': instance.url,
      'siteUrl': instance.siteUrl,
      'iconUrl': instance.iconUrl,
      'unreadCount': instance.unreadCount,
      'categories': instance.categories,
      'metadata': instance.metadata,
    };
