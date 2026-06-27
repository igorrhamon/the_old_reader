import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/old_reader_api.dart';
import 'feed_articles_page.dart';

class HomePage extends StatefulWidget {
  final OldReaderApi api;
  const HomePage({super.key, required this.api});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? feeds;
  Map<String, int> unreadCounts = {};
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final results = await Future.wait([
        widget.api.getSubscriptions(),
        widget.api.getUnreadCounts(),
      ]);

      final subsResponse = results[0];
      final unreadResponse = results[1];

      if (subsResponse.statusCode == 200) {
        final json = jsonDecode(subsResponse.body);
        feeds = (json is Map && json.containsKey('subscriptions'))
            ? List<dynamic>.from(json['subscriptions'])
            : [];
      } else {
        setState(() {
          error = 'Erro ao carregar feeds (${subsResponse.statusCode})';
          loading = false;
        });
        return;
      }

      if (unreadResponse.statusCode == 200) {
        try {
          final unreadJson = jsonDecode(unreadResponse.body);
          final List<dynamic>? counts = unreadJson['unreadcounts'];
          if (counts != null) {
            unreadCounts = {
              for (final item in counts)
                if (item['id'] != null && item['count'] != null)
                  item['id'] as String: (item['count'] as num).toInt(),
            };
          }
        } catch (_) {}
      }

      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erro: $e';
        loading = false;
      });
    }
  }

  void _openFeed(BuildContext context, dynamic feed) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedArticlesPage(api: widget.api, feed: feed),
      ),
    );
  }

  Widget _buildSpecialTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Map<String, dynamic> feed,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () => _openFeed(context, feed),
        ),
        onTap: () => _openFeed(context, feed),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    }

    final allFeeds = feeds ?? [];
    final itemCount = allFeeds.length + 2; // +2 for special streams

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSpecialTile(
            context,
            icon: Icons.all_inbox,
            title: 'Todos os artigos',
            feed: {
              'id': 'user/-/state/com.google/reading-list',
              'title': 'Todos os artigos',
            },
          );
        }
        if (index == 1) {
          return _buildSpecialTile(
            context,
            icon: Icons.mark_email_unread,
            title: 'Não lidos',
            feed: {
              'id': 'user/-/state/com.google/reading-list',
              'title': 'Não lidos',
              'exclude': 'user/-/state/com.google/read',
            },
          );
        }

        final feed = allFeeds[index - 2];
        final feedId = feed['id'] as String? ?? '';
        final count = unreadCounts[feedId] ?? 0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.rss_feed, color: Color(0xFF6750A4)),
            ),
            title: Text(
              feed['title'] ?? 'Sem título',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              feed['htmlUrl'] ?? feed['id'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (count > 0)
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count > 999 ? '999+' : count.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () => _openFeed(context, feed),
                ),
              ],
            ),
            onTap: () => _openFeed(context, feed),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
    );
  }
}
