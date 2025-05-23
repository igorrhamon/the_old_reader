import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/old_reader_api.dart';
import 'feed_articles_page.dart';
import 'feed_articles_page_xml.dart';

class HomePage extends StatefulWidget {
  final OldReaderApi api;
  const HomePage({super.key, required this.api});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? feeds;
  String? error;  
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await widget.api.getSubscriptions();
      if (response.statusCode == 200) {
        final data = response.body;
        final json = jsonDecode(data);
        feeds = (json is Map && json.containsKey('subscriptions'))
            ? List<dynamic>.from(json['subscriptions'])
            : [];
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          error = 'Erro ao carregar feeds ({response.statusCode})';
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Erro: $e';
        loading = false;
      });
    }
  }

  void _openFeed(BuildContext context, dynamic feed) async {
    try {
      final response = await widget.api.getFeedItems(feed['id']);
      if (!mounted) return;
      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FeedArticlesPage(api: widget.api, feed: feed),
          ),
        );
        return;
      }
    } catch (_) {}
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedArticlesPageXml(api: widget.api, feed: feed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Remove o Scaffold e o AppBar, retornando apenas o conteúdo
    return Builder(
      builder: (context) {
        if (loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (error != null) {
          return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
        }
        if (feeds == null || feeds!.isEmpty) {
          return const Center(child: Text('Nenhum feed encontrado.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: feeds!.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final feed = feeds![index];
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  feed['htmlUrl'] ?? feed['id'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
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
          },
        );
      },
    );
  }
}
