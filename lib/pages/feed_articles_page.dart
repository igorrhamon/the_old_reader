import 'package:flutter/material.dart';
import 'article_page.dart';
import '../services/old_reader_api.dart';
import 'dart:convert';

class FeedArticlesPage extends StatefulWidget {
  final OldReaderApi api;
  final dynamic feed;
  const FeedArticlesPage({super.key, required this.api, required this.feed});

  @override
  State<FeedArticlesPage> createState() => _FeedArticlesPageState();
}

class _FeedArticlesPageState extends State<FeedArticlesPage> {
  final List<dynamic> articles = [];
  final ScrollController _scrollController = ScrollController();
  String? _continuation;
  bool _loadingMore = false;
  String? error;
  bool loading = true;
  Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadFavorites();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _continuation != null) {
      _loadMore();
    }
  }

  Future<void> _loadArticles() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await widget.api.getStreamContents(
        stream: widget.feed['id'],
        n: 20,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final items = List<dynamic>.from(json['items'] ?? []);
        setState(() {
          articles
            ..clear()
            ..addAll(items);
          _continuation = json['continuation'] as String?;
          loading = false;
        });
      } else {
        setState(() {
          error = 'Erro ao carregar artigos (${response.statusCode})';
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

  Future<void> _loadMore() async {
    if (_loadingMore || _continuation == null) return;
    setState(() => _loadingMore = true);
    try {
      final response = await widget.api.getStreamContents(
        stream: widget.feed['id'],
        n: 20,
        c: _continuation,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final items = List<dynamic>.from(json['items'] ?? []);
        setState(() {
          articles.addAll(items);
          _continuation = json['continuation'] as String?;
        });
      }
    } finally {
      setState(() => _loadingMore = false);
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await widget.api.getStarredItemIds();
      setState(() => favoriteIds = ids.toSet());
    } catch (_) {}
  }

  bool _isRead(dynamic article) {
    final categories = article['categories'];
    if (categories is List) {
      return categories.contains('user/-/state/com.google/read');
    }
    return false;
  }

  Future<void> _toggleFavorite(String articleId) async {
    final isFav = favoriteIds.contains(articleId);
    if (isFav) {
      await widget.api.removeFavorite(articleId);
      setState(() => favoriteIds.remove(articleId));
    } else {
      await widget.api.addFavorite(articleId);
      setState(() => favoriteIds.add(articleId));
    }
  }

  Future<void> _markAllAsRead() async {
    await widget.api.markAllAsRead(stream: widget.feed['id']);
    setState(() {
      for (final article in articles) {
        final cats = article['categories'];
        if (cats is List && !cats.contains('user/-/state/com.google/read')) {
          cats.add('user/-/state/com.google/read');
        }
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos os artigos marcados como lidos.')),
      );
    }
  }

  void _openArticle(BuildContext context, dynamic article) {
    final articleId = article['id'] as String?;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticlePage(article: article, api: widget.api),
      ),
    ).then((_) {
      if (articleId != null) {
        setState(() {
          final cats = article['categories'];
          if (cats is List && !cats.contains('user/-/state/com.google/read')) {
            cats.add('user/-/state/com.google/read');
          }
        });
      }
    });
  }

  String _articleSummary(dynamic article) {
    final summary = article['summary'];
    if (summary is Map) return summary['content'] as String? ?? '';
    if (summary is String) return summary;
    return '';
  }

  String _articleContent(dynamic article) {
    final content = article['content'];
    if (content is Map) return content['content'] as String? ?? '';
    if (content is String) return content;
    return '';
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      content = Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    } else if (articles.isEmpty) {
      content = const Center(child: Text('Nenhum artigo encontrado.'));
    } else {
      content = ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: articles.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final article = articles[index];
          final articleId =
              article['id'] as String? ?? article['title'] ?? index.toString();
          final isFav = favoriteIds.contains(articleId);
          final isRead = _isRead(article);

          // Normalise summary/content so ArticlePage receives flat strings
          final enriched = Map<String, dynamic>.from(article as Map)
            ..['summary'] = _articleSummary(article)
            ..['content'] = _articleContent(article);

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: isRead
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : Theme.of(context).colorScheme.secondaryContainer,
                child: Icon(
                  Icons.article,
                  color: isRead
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : const Color(0xFF625B71),
                ),
              ),
              title: Text(
                article['title'] as String? ?? 'Sem título',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                  color: isRead
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
              subtitle: Text(
                article['author'] as String? ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? Colors.yellow[700] : null,
                    ),
                    tooltip: isFav
                        ? 'Remover dos favoritos'
                        : 'Adicionar aos favoritos',
                    onPressed: () => _toggleFavorite(articleId),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => _openArticle(context, enriched),
                  ),
                ],
              ),
              onTap: () => _openArticle(context, enriched),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.feed['title'] as String? ?? 'Feed',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onPrimary,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todos como lidos',
            color: Theme.of(context).colorScheme.onPrimary,
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: content,
    );
  }
}
