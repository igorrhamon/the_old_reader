import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/old_reader_api.dart';

class ArticlePage extends StatefulWidget {
  final dynamic article;
  final OldReaderApi api;
  const ArticlePage({super.key, required this.article, required this.api});

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  @override
  void initState() {
    super.initState();
    final id = widget.article['id'] as String? ?? '';
    if (id.isNotEmpty) {
      widget.api.markAsRead(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          article['title'] ?? 'Artigo',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article['author'] != null &&
                  article['author'].toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Por ${article['author']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              if (article['published'] != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    article['published'].toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              const SizedBox(height: 16),
              if (article['summary'] != null &&
                  article['summary'].toString().trim().isNotEmpty)
                Html(
                  data: article['summary'],
                  style: {
                    'body': Style.fromTextStyle(
                      Theme.of(context).textTheme.bodyLarge!,
                    ),
                  },
                ),
              if (article['content'] != null &&
                  article['content'].toString().trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Html(
                    data: article['content'],
                    style: {
                      'body': Style.fromTextStyle(
                        Theme.of(context).textTheme.bodyLarge!,
                      ),
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
