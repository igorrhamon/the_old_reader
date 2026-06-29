import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../models/feed.dart';
import '../models/category.dart';
import 'feed_articles_page.dart';
import 'folder_feeds_page.dart';

class FoldersPage extends StatefulWidget {
  final FeedProvider provider;
  const FoldersPage({super.key, required this.provider});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  List<Category> _categories = [];
  Map<String, int> _folderUnreadCounts = {};
  Map<String, List<Feed>> _feedsByFolder = {};
  List<Feed> _uncategorizedFeeds = [];
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
        widget.provider.getCategories(),
        widget.provider.getUnreadCounts(),
        widget.provider.getFeeds(),
      ]);
      if (!mounted) return;
      final categories = results[0] as List<Category>;
      final unreadCounts = results[1] as Map<String, int>;
      final feeds = results[2] as List<Feed>;

      final feedsByFolder = <String, List<Feed>>{};
      final uncategorized = <Feed>[];
      for (final feed in feeds) {
        if (feed.categories.isNotEmpty) {
          for (final catName in feed.categories) {
            feedsByFolder.putIfAbsent(catName, () => []).add(feed);
          }
        } else {
          uncategorized.add(feed);
        }
      }

      final folderUnreadCounts = <String, int>{};
      for (final cat in categories) {
        folderUnreadCounts[cat.name] = unreadCounts[cat.id] ?? 0;
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

  Future<void> _renameFolder(Category cat) async {
    final controller = TextEditingController(text: cat.name);
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
    if (result != null && result.isNotEmpty && result != cat.name) {
      try {
        await widget.provider.renameCategory(cat.id, result);
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

  Future<void> _removeFolder(Category cat) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover pasta'),
        content: Text('Remover a pasta "${cat.name}"? Os feeds serão movidos para "Sem categoria".'),
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
        await widget.provider.deleteCategory(cat.id);
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
          provider: widget.provider,
          folderName: folderName,
        ),
      ),
    );
  }

  void _openFeed(Feed feed) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedArticlesPage(provider: widget.provider, feed: feed),
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
                  ..._categories.map((cat) => _FolderTile(
                    category: cat,
                    unreadCount: _folderUnreadCounts[cat.name] ?? 0,
                    feeds: _feedsByFolder[cat.name] ?? [],
                    onTap: () => _openFolderFeed(cat.name),
                    onRename: () => _renameFolder(cat),
                    onRemove: () => _removeFolder(cat),
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
                    ..._uncategorizedFeeds.map((feed) => ListTile(
                      dense: true,
                      leading: Icon(Icons.rss_feed_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      title: Text(feed.title, style: const TextStyle(fontSize: 13)),
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
  final Category category;
  final int unreadCount;
  final List<Feed> feeds;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onRemove;
  final void Function(Feed) onFeedTap;

  const _FolderTile({
    required this.category,
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
                color: theme.colorScheme.primary,
              ),
              title: Text(
                widget.category.name,
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
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _expanded && widget.feeds.isNotEmpty
                ? widget.feeds.map((feed) => ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.only(left: 48),
                    leading: Icon(Icons.rss_feed_rounded, size: 16, color: theme.colorScheme.onSurfaceVariant),
                    title: Text(feed.title, style: const TextStyle(fontSize: 13)),
                    onTap: () => widget.onFeedTap(feed),
                  )).toList()
                : [],
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}
