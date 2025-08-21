import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
  Map<String, int> unreadCounts = {};  String _formatLastUpdate(dynamic timestamp) {
    if (timestamp == null) return 'Data desconhecida';
    
    try {
      // timestamp está em microsegundos desde a época
      final date = DateTime.fromMillisecondsSinceEpoch(
        (int.parse(timestamp.toString()) ~/ 1000).toInt()
      );
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} meses atrás';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} dias atrás';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} horas atrás';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutos atrás';
      } else {
        return 'Agora mesmo';
      }
    } catch (e) {
      return 'Data inválida';
    }
  }

  Future<void> _markAllAsRead(dynamic feed) async {
    final feedId = feed['id'];
    if (feedId == null) return;

    try {
      final response = await widget.api.markAllAsRead(stream: feedId);
      if (response.statusCode == 200) {
        setState(() {
          unreadCounts[feedId] = 0;
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Todos os artigos de ${feed['title']} foram marcados como lidos'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao marcar artigos como lidos'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload feeds if they might have changed
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      // Carregar feeds e contadores em paralelo
      final responsesFuture = Future.wait([
        widget.api.getSubscriptions(),
        widget.api.getUnreadCountsMap(),
      ]);

      final responses = await responsesFuture;
      final subsResponse = responses[0] as http.Response;
      final counts = responses[1] as Map<String, int>;

      if (subsResponse.statusCode == 200) {
        final data = subsResponse.body;
        final json = jsonDecode(data);
        feeds = (json is Map && json.containsKey('subscriptions'))
            ? List<dynamic>.from(json['subscriptions'])
            : [];
        unreadCounts = counts;
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          error = 'Erro ao carregar feeds ({response.statusCode})';
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
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        feed['title'] ?? 'Sem título',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: unreadCounts[feed['id']] != null && unreadCounts[feed['id']]! > 0
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    if (unreadCounts[feed['id']] != null && unreadCounts[feed['id']]! > 0)
                      Tooltip(
                        message: '${unreadCounts[feed['id']]} artigos não lidos',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.mark_email_unread_outlined,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${unreadCounts[feed['id']]}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feed['htmlUrl'] ?? feed['id'] ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (unreadCounts[feed['id']] != null && unreadCounts[feed['id']]! > 0)
                      Text(
                        'Última atualização: ${_formatLastUpdate(feed['firstitemmsec'])}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (unreadCounts[feed['id']] != null && unreadCounts[feed['id']]! > 0)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        color: Theme.of(context).colorScheme.primary,
                        tooltip: 'Marcar todos como lidos',
                        onPressed: () => _markAllAsRead(feed),
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
      },
    );
  }
}
