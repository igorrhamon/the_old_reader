import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../models/article.dart';
import 'article_page.dart';

class SearchPage extends StatefulWidget {
  final FeedProvider provider;
  const SearchPage({super.key, required this.provider});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  List<Article> _results = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _searched = true;
    });
    final result = await widget.provider.search(q);
    setState(() {
      _results = result.articles;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_searched && _results.isEmpty) {
      body = const Center(child: Text('Nenhum resultado encontrado.'));
    } else {
      body = ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _results.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final article = _results[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                article.title.isNotEmpty ? article.title : 'Sem título',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: (article.author?.isNotEmpty == true) ? Text(article.author!) : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticlePage(article: article, provider: widget.provider),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          decoration: InputDecoration(
            hintText: 'Buscar artigos...',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7)),
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: () => _search(_controller.text),
          ),
        ],
      ),
      body: body,
    );
  }
}
