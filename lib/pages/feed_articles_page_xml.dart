import 'package:flutter/material.dart';
import '../services/old_reader_api.dart';
import 'package:xml/xml.dart';
import 'article_page.dart';

class FeedArticlesPageXml extends StatefulWidget {
  final OldReaderApi api;
  final dynamic feed;
  const FeedArticlesPageXml({super.key, required this.api, required this.feed});

  @override
  State<FeedArticlesPageXml> createState() => _FeedArticlesPageXmlState();
}

class _FeedArticlesPageXmlState extends State<FeedArticlesPageXml> {
  List<Map<String, String>>? articles;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadArticles();
  }

  Future<void> loadArticles() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final response = await widget.api.getFeedItemsXml(widget.feed['id']);
      if (response.statusCode == 200) {
        final data = response.body;
        final document = XmlDocument.parse(data);
        final entries = document.findAllElements('entry');
        articles = entries.map((entry) {
          return {
            'title': entry.getElement('title')?.text ?? 'Sem título',
            'author': entry.getElement('author')?.getElement('name')?.text ?? '',
            'summary': entry.getElement('summary')?.text ?? '',
            'content': entry.getElement('content')?.text ?? '',
            'published': entry.getElement('published')?.text ?? '',
          };
        }).toList();
        setState(() {
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

  void openArticle(BuildContext context, Map<String, String> article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticlePage(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    } else if (articles == null || articles!.isEmpty) {
      body = const Center(child: Text('Nenhum artigo encontrado.'));
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: articles!.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final article = articles![index];
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
                article['title'] ?? 'Sem título',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                article['author'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                color: Theme.of(context).colorScheme.primary,
                onPressed: () => openArticle(context, article),
              ),
              onTap: () => openArticle(context, article),
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
          widget.feed['title'] ?? 'Feed',
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
