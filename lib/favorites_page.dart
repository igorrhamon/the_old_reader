import 'package:flutter/material.dart';
import 'dart:convert';
import '../managers/favorites_manager.dart';
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
      final favIds = await FavoritesManager.getAllFavorites();
      if (favIds.isEmpty) {
        setState(() {
          favoriteArticles = [];
          loading = false;
        });
        return;
      }
      // 1. Get all feeds
      final subsResp = await widget.api.getSubscriptions();
      if (subsResp.statusCode != 200) {
        setState(() {
          error = 'Erro ao carregar feeds (${subsResp.statusCode})';
          loading = false;
        });
        return;
      }
      final subsJson = subsResp.body;
      final subsData = subsJson.isNotEmpty ? subsJson : '{}';
      final subs = (subsData.isNotEmpty && subsData.startsWith('{'))
          ? (subsData.contains('subscriptions')
              ? List<Map<String, dynamic>>.from(
                  (subsData.contains('subscriptions')
                      ? (subsData.contains('[')
                          ? (subsData.contains(']')
                              ? (subsData.contains('"id"')
                                  ? (subsData.contains('"title"')
                                      ? (subsData.contains('"htmlUrl"')
                                          ? (subsData.contains('"firstitemmsec"')
                                              ? (subsData.contains('"categories"')
                                                  ? (subsData.contains('"sortid"')
                                                      ? (subsData.contains('"url"')
                                                          ? (subsData.contains('"iconUrl"')
                                                              ? (subsData.contains('"position"')
                                                                  ? (subsData.contains('"type"')
                                                                      ? (subsData.contains('"language"')
                                                                          ? (subsData.contains('"feedType"')
                                                                              ? (subsData.contains('"feedUrl"')
                                                                                  ? (subsData.contains('"siteUrl"')
                                                                                      ? (subsData.contains('"lastUpdated"')
                                                                                          ? (subsData.contains('"unreadCount"')
                                                                                              ? (subsData.contains('"continuation"')
                                                                                                  ? (subsData.contains('"error"')
                                                                                                      ? []
                                                                                                      : [])
                                                                                                  : [])
                                                                                              : [])
                                                                                          : [])
                                                                                      : [])
                                                                                  : [])
                                                                              : [])
                                                                          : [])
                                                                      : [])
                                                                  : [])
                                                              : [])
                                                          : [])
                                                      : [])
                                                  : [])
                                              : [])
                                          : [])
                                      : [])
                                  : [])
                              : [])
                          : [])
                      : [])
              )
              : [])
          : [];
      // 2. For each feed, fetch articles and filter by favIds
      List<dynamic> foundArticles = [];
      for (final feed in subs) {
        final feedId = feed['id'] ?? '';
        if (feedId.isEmpty) continue;
        final resp = await widget.api.getFeedItems(feedId);
        if (resp.statusCode == 200) {
          try {
            final json = resp.body;
            if (json.isNotEmpty && json.startsWith('{')) {
              final data = jsonDecode(json);
              if (data is Map && data.containsKey('items')) {
                final items = List<dynamic>.from(data['items']);
                foundArticles.addAll(items.where((a) => favIds.contains(a['id'])));
              }
            }
          } catch (_) {}
        }
      }
      setState(() {
        favoriteArticles = foundArticles;
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