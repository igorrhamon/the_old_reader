import 'dart:convert';
import 'package:flutter/material.dart';
import 'article_page.dart';
import '../services/old_reader_api.dart';
import 'package:xml/xml.dart';

const _accent = Color(0xFFFF6B2C);
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);
const _cardBg = Color(0xFF1C1C1E);

class FeedArticlesPage extends StatefulWidget {
  final OldReaderApi api;
  final dynamic feed;
  const FeedArticlesPage({super.key, required this.api, required this.feed});

  @override
  State<FeedArticlesPage> createState() => _FeedArticlesPageState();
}

class _FeedArticlesPageState extends State<FeedArticlesPage>
    with TickerProviderStateMixin {
  final List<Map<String, dynamic>> articles = [];
  final ScrollController _scrollController = ScrollController();
  String? _continuation;
  bool _loadingMore = false;
  String? error;
  bool loading = true;
  Set<String> favoriteIds = {};
  late final AnimationController _staggerCtrl;
  late final Animation<double> _staggerAnim;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _staggerAnim = CurvedAnimation(
      parent: _staggerCtrl,
      curve: Curves.easeOutCubic,
    );
    _loadArticles();
    _loadFavorites();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
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

  /// Converte Atom XML do stream/contents em lista de artigos + token de continuação.
  String _extractText(dynamic obj) {
    if (obj == null) return '';
    if (obj is String) return obj;
    if (obj is Map) return (obj['content'] as String?) ?? '';
    return '';
  }

  (List<Map<String, dynamic>>, String?) _parseAtom(String body) {
    // Tenta JSON (output=json); fallback para Atom XML
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final continuation = data['continuation'] as String?;
      final rawItems = data['items'] as List<dynamic>? ?? [];
      final items = rawItems.map((item) {
        final m = item as Map<String, dynamic>;
        final categories = (m['categories'] as List<dynamic>? ?? [])
            .map((c) => c.toString())
            .toList();
        // alternates ou canonical para URL do artigo
        final alternates = m['alternate'] as List<dynamic>?;
        final canonicals = m['canonical'] as List<dynamic>?;
        final urlList = (alternates?.isNotEmpty == true ? alternates : canonicals) ?? [];
        final url = urlList.isNotEmpty
            ? (urlList[0] as Map<dynamic, dynamic>)['href'] as String? ?? ''
            : '';
        return <String, dynamic>{
          'id': m['id'] as String? ?? '',
          'title': _extractText(m['title']),
          'author': m['author'] as String? ?? '',
          'summary': _extractText(m['summary']),
          'content': _extractText(m['content']),
          'published': m['published'],
          'categories': categories,
          'url': url,
        };
      }).toList();
      return (items, continuation);
    } catch (_) {}
    // fallback Atom XML
    final doc = XmlDocument.parse(body);
    final continuation = doc.findAllElements('continuation').firstOrNull?.innerText;
    final items = doc.findAllElements('entry').map((entry) {
      final categories = entry
          .findElements('category')
          .map((c) => c.getAttribute('term') ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
      final link = entry
          .findElements('link')
          .where((l) => l.getAttribute('rel') == 'alternate')
          .firstOrNull
          ?.getAttribute('href') ?? '';
      final published = entry.findElements('published').firstOrNull?.innerText;
      return <String, dynamic>{
        'id': entry.findElements('id').firstOrNull?.innerText ?? '',
        'title': entry.findElements('title').firstOrNull?.innerText ?? '',
        'author': entry.findElements('author').firstOrNull
            ?.findElements('name').firstOrNull?.innerText ?? '',
        'summary': entry.findElements('summary').firstOrNull?.innerText ?? '',
        'content': entry.findElements('content').firstOrNull?.innerText ?? '',
        'published': published,
        'categories': categories,
        'url': link,
      };
    }).toList();
    return (items, continuation);
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
        final (items, continuation) = _parseAtom(response.body);
        setState(() {
          articles..clear()..addAll(items);
          _continuation = continuation;
          loading = false;
        });
        _staggerCtrl.forward(from: 0);
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
        final (items, continuation) = _parseAtom(response.body);
        setState(() {
          articles.addAll(items);
          _continuation = continuation;
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

  bool _isRead(Map<String, dynamic> article) {
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

  void _openArticle(BuildContext context, Map<String, dynamic> article) {
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

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = const Center(child: CircularProgressIndicator(color: _accent));
    } else if (error != null) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: _accent, size: 48),
            const SizedBox(height: 16),
            Text(error!, style: const TextStyle(color: _textSecondary)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadArticles,
              child: const Text('Tentar novamente', style: TextStyle(color: _accent)),
            ),
          ],
        ),
      );
    } else if (articles.isEmpty) {
      content = const Center(
        child: Text('Nenhum artigo encontrado.', style: TextStyle(color: _textSecondary)),
      );
    } else {
      content = ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: articles.length + (_loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(color: _accent),
              ),
            );
          }
          final article = articles[index];
          final articleId = article['id'] as String? ?? index.toString();
          final isFav = favoriteIds.contains(articleId);
          final isRead = _isRead(article);

          final delay = (index * 0.05).clamp(0.0, 0.7);

          return FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: _staggerAnim,
                curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
              ),
            ),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _staggerAnim,
                  curve: Interval(delay, delay + 0.3, curve: Curves.easeOutCubic),
                ),
              ),
              child: InkWell(
                onTap: () => _openArticle(context, article),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 400),
                        opacity: isRead ? 0 : 1,
                        child: Container(
                          width: 4,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _accent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Hero(
                              tag: 'article_title_$articleId',
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  article['title'] as String? ?? 'Sem título',
                                  style: TextStyle(
                                    color: isRead ? _textSecondary : _textPrimary,
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            if ((article['author'] as String?)?.isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                article['author'] as String,
                                style: const TextStyle(color: _textSecondary, fontSize: 13),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _AnimatedFavoriteButton(
                        isFav: isFav,
                        onPressed: () => _toggleFavorite(articleId),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: Text(
          widget.feed['title'] as String? ?? 'Feed',
          style: const TextStyle(color: _textPrimary, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Marcar todos como lidos',
            color: _textPrimary,
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: content,
    );
  }
}

class _AnimatedFavoriteButton extends StatefulWidget {
  final bool isFav;
  final VoidCallback onPressed;
  const _AnimatedFavoriteButton({required this.isFav, required this.onPressed});

  @override
  State<_AnimatedFavoriteButton> createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<_AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 1, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(_AnimatedFavoriteButton old) {
    super.didUpdateWidget(old);
    if (widget.isFav != old.isFav) {
      _ctrl.forward().then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: IconButton(
        icon: Icon(
          widget.isFav ? Icons.star : Icons.star_border,
          color: widget.isFav ? const Color(0xFFFF6B2C) : const Color(0xFF8E8E93),
          size: 20,
        ),
        onPressed: widget.onPressed,
        visualDensity: VisualDensity.compact,
        tooltip: widget.isFav ? 'Remover dos favoritos' : 'Adicionar aos favoritos',
      ),
    );
  }
}
