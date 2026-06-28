import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../models/feed.dart';
import 'feed_articles_page.dart';

class FolderFeedsPage extends StatefulWidget {
  final FeedProvider provider;
  final String folderName;

  const FolderFeedsPage({
    super.key,
    required this.provider,
    required this.folderName,
  });

  @override
  State<FolderFeedsPage> createState() => _FolderFeedsPageState();
}

class _FolderFeedsPageState extends State<FolderFeedsPage> {
  List<Feed> _feeds = [];
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
        widget.provider.getFeeds(),
        widget.provider.getUnreadCounts(),
      ]);
      if (!mounted) return;

      final allFeeds = results[0] as List<Feed>;
      final unreadCounts = results[1] as Map<String, int>;

      final folderFeeds = allFeeds
          .where((f) => f.categories.contains(widget.folderName))
          .toList();

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
                        ListTile(
                          leading: Icon(
                            Icons.rss_feed_rounded,
                            color: (_unreadCounts[feed.id] ?? 0) > 0
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            feed.title,
                            style: TextStyle(
                              fontWeight: (_unreadCounts[feed.id] ?? 0) > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          trailing: (_unreadCounts[feed.id] ?? 0) > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    (_unreadCounts[feed.id] ?? 0) > 999
                                        ? '999+'
                                        : (_unreadCounts[feed.id] ?? 0).toString(),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                                  ),
                                )
                              : null,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FeedArticlesPage(provider: widget.provider, feed: feed),
                            ),
                          ),
                        ),
                        const Divider(height: 1, indent: 56, endIndent: 16),
                      ],
                    ],
                  ),
                ),
    );
  }
}
