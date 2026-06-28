import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/old_reader_api.dart';
import 'feed_articles_page.dart';
import 'folder_feeds_page.dart';

class FoldersPage extends StatefulWidget {
  final OldReaderApi api;
  const FoldersPage({super.key, required this.api});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  List<String> _categories = [];
  Map<String, int> _folderUnreadCounts = {};
  Map<String, List<dynamic>> _feedsByFolder = {};
  List<dynamic> _uncategorizedFeeds = [];
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
        widget.api.getCategories(),
        widget.api.getUnreadCounts(),
        widget.api.getSubscriptions(),
      ]);
      if (!mounted) return;
      final categories = results[0] as List<String>;
      final unreadResp = results[1] as http.Response;
      final subsResp = results[2] as http.Response;
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
      final feedsByFolder = <String, List<dynamic>>{};
      final uncategorized = <dynamic>[];
      if (subsResp.statusCode == 200) {
        try {
          final data = jsonDecode(subsResp.body);
          final subs = data['subscriptions'] as List? ?? [];
          for (final sub in subs) {
            bool hasFolder = false;
            if (sub['categories'] is List) {
              for (final cat in sub['categories']) {
                if (cat is Map && cat['label'] is String) {
                  final label = cat['label'] as String;
                  if (label.startsWith('user/-/label/')) {
                    final folderName = label.replaceFirst('user/-/label/', '');
                    feedsByFolder.putIfAbsent(folderName, () => []).add(sub);
                    hasFolder = true;
                  }
                }
              }
            }
            if (!hasFolder) uncategorized.add(sub);
          }
        } catch (_) {}
      }
      final folderUnreadCounts = <String, int>{};
      for (final cat in categories) {
        final key = 'user/-/label/$cat';
        folderUnreadCounts[cat] = unreadCounts[key] ?? 0;
      }
      setState(() {
        _categories = categories;
        _folderUnreadCounts = folderUnreadCounts;
        _feedsByFolder = feedsByFolder;
        _uncategorizedFeeds = uncategorized;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _renameFolder(String oldName) async {
    final controller = TextEditingController(text: oldName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Renomear pasta'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Renomear'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != oldName) {
      try {
        await widget.api.renameTag(
          from: 'user/-/label/$oldName',
          to: 'user/-/label/$result',
        );
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao renomear: $e')),
          );
        }
      }
    }
  }

  Future<void> _removeFolder(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover pasta'),
        content: Text('Remover a pasta "$name"? Os feeds serão movidos para "Sem categoria".'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await widget.api.removeTag('user/-/label/$name');
        _loadData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao remover: $e')),
          );
        }
      }
    }
  }

  void _openFolderFeed(String folderName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FolderFeedsPage(
          api: widget.api,
          folderName: folderName,
        ),
      ),
    );
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
      appBar: AppBar(title: const Text('Pastas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 80),
                children: [
                  ..._categories.map((name) => _FolderTile(
                    name: name,
                    unreadCount: _folderUnreadCounts[name] ?? 0,
                    feeds: _feedsByFolder[name] ?? [],
                    onTap: () => _openFolderFeed(name),
                    onRename: () => _renameFolder(name),
                    onRemove: () => _removeFolder(name),
                    onFeedTap: _openFeed,
                  )),
                  if (_uncategorizedFeeds.isNotEmpty) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'SEM CATEGORIA',
                        style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ),
                    ..._uncategorizedFeeds.map((feed) => _FeedInFolderTile(
                      feed: feed,
                      onTap: () => _openFeed(feed),
                    )),
                  ],
                ],
              ),
            ),
    );
  }
}

class _FolderTile extends StatefulWidget {
  final String name;
  final int unreadCount;
  final List<dynamic> feeds;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onRemove;
  final void Function(dynamic) onFeedTap;

  const _FolderTile({
    required this.name,
    required this.unreadCount,
    required this.feeds,
    required this.onTap,
    required this.onRename,
    required this.onRemove,
    required this.onFeedTap,
  });

  @override
  State<_FolderTile> createState() => _FolderTileState();
}

class _FolderTileState extends State<_FolderTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = widget.unreadCount > 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ListTile(
              leading: Icon(
                _expanded ? Icons.folder_open_rounded : Icons.folder_rounded,
                color: hasUnread ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              title: Text(
                widget.name,
                style: TextStyle(
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasUnread)
                    Container(
                      margin: const EdgeInsets.only(right: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        widget.unreadCount > 999 ? '999+' : widget.unreadCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (widget.feeds.isNotEmpty)
                    IconButton(
                      icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                      tooltip: _expanded ? 'Recolher' : 'Expandir',
                      onPressed: () => setState(() => _expanded = !_expanded),
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'rename') widget.onRename();
                      if (value == 'delete') widget.onRemove();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'rename', child: ListTile(
                        leading: Icon(Icons.edit, size: 18),
                        title: Text('Renomear'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      )),
                      const PopupMenuItem(value: 'delete', child: ListTile(
                        leading: Icon(Icons.delete, size: 18, color: Colors.red),
                        title: Text('Remover', style: TextStyle(color: Colors.red)),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded && widget.feeds.isNotEmpty)
          ...widget.feeds.map((feed) => _FeedInFolderTile(
            feed: feed,
            onTap: () => widget.onFeedTap(feed),
          )),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _FeedInFolderTile extends StatelessWidget {
  final dynamic feed;
  final VoidCallback onTap;

  const _FeedInFolderTile({required this.feed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = feed['title'] as String? ?? 'Sem título';
    return Padding(
      padding: const EdgeInsets.only(left: 48),
      child: ListTile(
        dense: true,
        leading: Icon(Icons.rss_feed_rounded, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
        title: Text(title, style: const TextStyle(fontSize: 13)),
        onTap: onTap,
      ),
    );
  }
}
