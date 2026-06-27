import 'package:flutter/material.dart';
import 'article_page.dart';
import '../services/old_reader_api.dart';
import 'dart:convert';

const _accent = Color(0xFFFF6B2C);
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);
const _divider = Color(0xFF3A3A3C);
const _surface = Color(0xFF1C1C1E);
const _gold = Color(0xFFFFCC02);

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
        exclude: widget.feed['exclude'] as String?,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final items = List<dynamic>.from(json['items'] ?? []);
        setState(() {
          articles..clear()..addAll(items);
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
        exclude: widget.feed['exclude'] as String?,
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
        const SnackBar(
          content: Text('Todos os artigos marcados como lidos.'),
          backgroundColor: _surface,
        ),
      );
    }
  }

  void _openArticle(BuildContext context, dynamic article) {
    final articleId = article['id'] as String?;
    final enriched = Map<String, dynamic>.from(article as Map)
      ..['summary'] = _extractText(article['summary'])
      ..['content'] = _extractText(article['content']);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ArticlePage(article: enriched, api: widget.api)),
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

  String _extractText(dynamic field) {
    if (field is Map) return field['content'] as String? ?? '';
    if (field is String) return field;
    return '';
  }

  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();
  }

  String _formatDate(dynamic published) {
    if (published == null) return '';
    try {
      final ts = int.tryParse(published.toString());
      if (ts != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inMinutes < 60) return '${diff.inMinutes}min';
        if (diff.inHours < 24) return '${diff.inHours}h';
        if (diff.inDays < 7) return '${diff.inDays}d';
        return '${dt.day}/${dt.month}';
      }
    } catch (_) {}
    return published.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: Text(
          widget.feed['title'] as String? ?? 'Feed',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.3),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Marcar todos como lidos',
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) return const Center(child: CircularProgressIndicator(color: _accent));

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: _textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: _textSecondary)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadArticles,
              child: const Text('Tentar novamente', style: TextStyle(color: _accent)),
            ),
          ],
        ),
      );
    }

    if (articles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, color: _textSecondary, size: 48),
            SizedBox(height: 12),
            Text('Nenhum artigo encontrado.', style: TextStyle(color: _textSecondary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: _accent,
      backgroundColor: _surface,
      onRefresh: _loadArticles,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: articles.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(color: _accent, strokeWidth: 2)),
            );
          }
          final article = articles[index];
          final articleId = article['id'] as String? ?? article['title'] ?? index.toString();
          final isFav = favoriteIds.contains(articleId);
          final isRead = _isRead(article);
          final title = article['title'] as String? ?? 'Sem título';
          final author = article['author'] as String? ?? '';
          final published = article['published'];
          final rawSummary = _extractText(article['summary']);
          final rawContent = _extractText(article['content']);
          final preview = _stripHtml(rawSummary.isNotEmpty ? rawSummary : rawContent);
          final isLast = index == articles.length - 1;

          return Column(
            children: [
              InkWell(
                onTap: () => _openArticle(context, article),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                  decoration: BoxDecoration(
                    border: !isRead
                        ? const Border(left: BorderSide(color: _accent, width: 3))
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: isRead ? _textSecondary : _textPrimary,
                                fontSize: 15,
                                fontWeight: isRead ? FontWeight.w400 : FontWeight.w700,
                                letterSpacing: -0.2,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (preview.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                preview,
                                style: const TextStyle(
                                  color: _textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                if (author.isNotEmpty) ...[
                                  Text(
                                    author,
                                    style: const TextStyle(color: _textSecondary, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(' · ', style: TextStyle(color: _textSecondary, fontSize: 11)),
                                ],
                                Text(
                                  _formatDate(published),
                                  style: const TextStyle(color: _textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _toggleFavorite(articleId),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 2, left: 4),
                          child: Icon(
                            isFav ? Icons.star_rounded : Icons.star_border_rounded,
                            color: isFav ? _gold : _textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!isLast)
                const Divider(color: _divider, height: 1, indent: 20),
            ],
          );
        },
      ),
    );
  }
}
