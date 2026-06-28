import 'package:flutter/material.dart';
import '../providers/feed_provider.dart';
import '../models/article.dart';
import 'article_page.dart';

class FavoritesPage extends StatefulWidget {
  final FeedProvider provider;
  const FavoritesPage({super.key, required this.provider});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Article> favoriteArticles = [];
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
      final result = await widget.provider.getStarredArticles();
      setState(() {
        favoriteArticles = result.articles;
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
          title: Text(article.title),
          subtitle: Text(article.author ?? ''),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ArticlePage(article: article, provider: widget.provider)),
          ),
        );
      },
    );
  }
}
