import 'package:freezed_annotation/freezed_annotation.dart';

part 'feed.freezed.dart';
part 'feed.g.dart';

@freezed
class Feed with _$Feed {
  const factory Feed({
    required String id,
    required String title,
    String? url,
    String? siteUrl,
    String? iconUrl,
    @Default(0) int unreadCount,
    @Default([]) List<String> categories,
    @Default({}) Map<String, dynamic> metadata,
  }) = _Feed;

  factory Feed.fromJson(Map<String, dynamic> json) => _$FeedFromJson(json);
}

extension FeedExtension on Feed {
  Feed copyWith({
    String? id,
    String? title,
    String? url,
    String? siteUrl,
    String? iconUrl,
    int? unreadCount,
    List<String>? categories,
    Map<String, dynamic>? metadata,
  }) {
    return Feed(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      siteUrl: siteUrl ?? this.siteUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      unreadCount: unreadCount ?? this.unreadCount,
      categories: categories ?? this.categories,
      metadata: metadata ?? this.metadata,
    );
  }

  String get displayTitle => title.isNotEmpty ? title : (url ?? 'Sem título');
  
  String get firstCategory => categories.isNotEmpty ? categories.first : 'Sem categoria';
  
  bool get hasUnread => unreadCount > 0;
}