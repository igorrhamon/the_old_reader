import 'package:flutter/material.dart';
import '../services/old_reader_api.dart';
import 'article_page.dart';

class SearchPage extends StatefulWidget {
  final OldReaderApi api;
  const SearchPage({super.key, required this.api});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  List<dynamic> _results = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _searched = true;
    });
    final items = await widget.api.searchItems(q);
    setState(() {
      _results = items;
      _loading = false;
    });
  }

  String _title(dynamic article) => article['title'] ?? 'Sem título';
  String _author(dynamic article) => article['author'] ?? '';

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
                _title(article),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: _author(article).isNotEmpty ? Text(_author(article)) : null,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticlePage(article: article, api: widget.api),
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
