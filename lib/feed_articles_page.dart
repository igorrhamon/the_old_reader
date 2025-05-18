
import 'package:flutter/material.dart';
import 'package:the_old_reader/article_page.dart';
import 'old_reader_api.dart';
import 'package:xml/xml.dart';
import 'dart:convert';

class FeedArticlesPage extends StatefulWidget {
  final OldReaderApi api;
  final dynamic feed;
  const FeedArticlesPage({super.key, required this.api, required this.feed});

  @override
  State<FeedArticlesPage> createState() => _FeedArticlesPageState();
}

class _FeedArticlesPageState extends State<FeedArticlesPage> {
  List<dynamic>? articles;
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
    // Try JSON first
    try {
      final response = await widget.api.getFeedItems(widget.feed['id']);
      if (response.statusCode == 200) {
        final data = response.body;
        try {
          final json = jsonDecode(data);
          articles = (json is Map && json.containsKey('items'))
              ? List<dynamic>.from(json['items'])
              : [];
          setState(() {
            loading = false;
          });
          return;
        } catch (_) {
          // Not JSON, try XML below
          setState(() {
            loading = true;
          });
          // Fallback to XML
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
        }
      }
    } catch (_) {}
    // Fallback to XML
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

  void _openArticle(BuildContext context, dynamic article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticlePage(article: article),
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
    if (articles == null || articles!.isEmpty) {
      return const Center(child: Text('Nenhum artigo encontrado.'));
    }
    return ListView.separated(
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
              onPressed: () => _openArticle(context, article),
            ),
            onTap: () => _openArticle(context, article),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        );
      },
    );
  }
}

