import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../models/feed.dart';
import '../models/article.dart';
import 'article_page.dart';

class FeedArticlesPageXml extends StatefulWidget {
  final FeedProvider provider;
  final Feed feed;
  const FeedArticlesPageXml({super.key, required this.provider, required this.feed});

  @override
  State<FeedArticlesPageXml> createState() => _FeedArticlesPageXmlState();
}

class _FeedArticlesPageXmlState extends State<FeedArticlesPageXml> {
  List<Article> articles = [];
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.provider.getArticles(
        streamId: widget.feed.id,
        limit: 20,
      );
      setState(() {
        articles = result.articles;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Erro: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    } else if (articles.isEmpty) {
      body = const Center(child: Text('Nenhum artigo encontrado.'));
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: articles.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final article = articles[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: const Icon(Icons.article, color: Color(0xFF625B71)),
              ),
              title: Text(
                article.title.isNotEmpty ? article.title : 'Sem título',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                article.author ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArticlePage(article: article, provider: widget.provider),
                  ),
                ),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticlePage(article: article, provider: widget.provider),
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.feed.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: body,
    );
  }
}
