import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/old_reader_api.dart';
import 'feed_articles_page.dart';

class FolderFeedsPage extends StatefulWidget {
  final OldReaderApi api;
  final String folderName;

  const FolderFeedsPage({
    super.key,
    required this.api,
    required this.folderName,
  });

  @override
  State<FolderFeedsPage> createState() => _FolderFeedsPageState();
}

class _FolderFeedsPageState extends State<FolderFeedsPage> {
  List<dynamic> _feeds = [];
  Map<String, int> _unreadCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        widget.api.getSubscriptions(),
        widget.api.getUnreadCounts(),
      ]);
      if (!mounted) return;

      final http.Response subsResp = results[0];
      final http.Response unreadResp = results[1];

      final unreadCounts = <String, int>{};
      if (unreadResp.statusCode == 200) {
        try {
          final unreadJson = jsonDecode(unreadResp.body);
          final List<dynamic>? counts = unreadJson['unreadcounts'] as List?;
          if (counts != null) {
            for (final item in counts) {
              if (item['id'] != null && item['count'] != null) {
                unreadCounts[item['id'] as String] = (item['count'] as num).toInt();
              }
            }
          }
        } catch (_) {}
      }

      final folderFeeds = <dynamic>[];
      if (subsResp.statusCode == 200) {
        try {
          final data = jsonDecode(subsResp.body);
          final subs = data['subscriptions'] as List? ?? [];
          final target = "user/-/label/${widget.folderName}";
          for (final sub in subs) {
            if (sub['categories'] is List) {
              for (final cat in sub['categories']) {
                if (cat is Map) {
                  final label = cat['label'] as String?;
                  final id = cat['id'] as String?;
                  if (label == target || id == target || label == widget.folderName) {
                    folderFeeds.add(sub);
                    break;
                  }
                }
              }
            }
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _feeds = folderFeeds;
          _unreadCounts = unreadCounts;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openFeed(dynamic feed) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedArticlesPage(api: widget.api, feed: feed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.folderName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _feeds.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum feed nesta pasta.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 80),
                    children: [
                      for (final feed in _feeds) ...[
                        _FeedTile(
                          feed: feed,
                          unreadCount: _unreadCounts[feed['id'] as String? ?? ''] ?? 0,
                          onTap: () => _openFeed(feed),
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16),
                      ],
                    ],
                  ),
                ),
    );
  }
}

class _FeedTile extends StatelessWidget {
  final dynamic feed;
  final int unreadCount;
  final VoidCallback onTap;

  const _FeedTile({
    required this.feed,
    required this.unreadCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = feed['title'] as String? ?? 'Sem título';
    final hasUnread = unreadCount > 0;

    return ListTile(
      leading: Icon(
        Icons.rss_feed_rounded,
        color: hasUnread ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      trailing: hasUnread
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 999 ? '999+' : unreadCount.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
