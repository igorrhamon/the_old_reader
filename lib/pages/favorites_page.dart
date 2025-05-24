import 'package:flutter/material.dart';
import '../services/old_reader_api.dart';
import 'article_page.dart';

class FavoritesPage extends StatefulWidget {
  final OldReaderApi api;
  const FavoritesPage({super.key, required this.api});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<dynamic> favoriteArticles = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      // 1. Busca IDs de itens favoritados via Old Reader
      final starredIds = await widget.api.getStarredItemIdsApi();
      // 2. Busca conteúdo desses itens
      final fetchedArticles = await widget.api.getItemsContentsApi(starredIds);
      setState(() {
        favoriteArticles = fetchedArticles;
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
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!, style: const TextStyle(color: Colors.red)));
    }
    if (favoriteArticles.isEmpty) {
      return const Center(child: Text('Nenhum favorito.'));
    }
    return ListView.builder(
      itemCount: favoriteArticles.length,
      itemBuilder: (context, index) {
        final article = favoriteArticles[index];
        return ListTile(
          title: Text(article['title'] ?? ''),
          subtitle: Text(article['author'] ?? ''),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ArticlePage(article: article)),
          ),
        );
      },
    );
  }
}