import 'dart:convert';

import 'package:flutter/material.dart';
import '../services/old_reader_api.dart';
import 'feed_articles_page.dart';

const _accent = Color(0xFFFF6B2C);
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);
const _divider = Color(0xFF3A3A3C);
const _surface = Color(0xFF1C1C1E);

class HomePage extends StatefulWidget {
  final OldReaderApi api;
  const HomePage({super.key, required this.api});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic>? feeds;
  Map<String, int> unreadCounts = {};
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadFeeds();
  }

  @override
  void didUpdateWidget(HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadFeeds();
  }

  Future<void> _loadFeeds() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final results = await Future.wait([
        widget.api.getSubscriptions(),
        widget.api.getUnreadCounts(),
      ]);

      final subsResponse = results[0];
      final unreadResponse = results[1];

      if (subsResponse.statusCode == 200) {
        final json = jsonDecode(subsResponse.body);
        feeds = (json is Map && json.containsKey('subscriptions'))
            ? List<dynamic>.from(json['subscriptions'])
            : [];
      } else {
        setState(() {
          error = 'Erro ao carregar feeds (${subsResponse.statusCode})';
          loading = false;
        });
        return;
      }

      if (unreadResponse.statusCode == 200) {
        try {
          final unreadJson = jsonDecode(unreadResponse.body);
          final List<dynamic>? counts = unreadJson['unreadcounts'];
          if (counts != null) {
            unreadCounts = {
              for (final item in counts)
                if (item['id'] != null && item['count'] != null)
                  item['id'] as String: (item['count'] as num).toInt(),
            };
          }
        } catch (_) {}
      }

      setState(() => loading = false);
    } catch (e) {
      setState(() {
        error = 'Erro: $e';
        loading = false;
      });
    }
  }

  void _openFeed(BuildContext context, dynamic feed) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedArticlesPage(api: widget.api, feed: feed),
      ),
    );
  }

  String _feedInitial(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  Color _avatarColor(String title) {
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
      const Color(0xFFEF4444),
    ];
    if (title.isEmpty) return colors[0];
    return colors[title.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator(color: _accent));
    }
    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: _textSecondary, size: 48),
            const SizedBox(height: 12),
            Text(error!, style: const TextStyle(color: _textSecondary)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadFeeds,
              child: const Text('Tentar novamente', style: TextStyle(color: _accent)),
            ),
          ],
        ),
      );
    }

    final allFeeds = feeds ?? [];
    final totalUnread = unreadCounts['user/-/state/com.google/reading-list'] ?? 0;

    return RefreshIndicator(
      color: _accent,
      backgroundColor: _surface,
      onRefresh: _loadFeeds,
      child: ListView(
        children: [
          // Smart streams section
          _sectionHeader('INÍCIO'),
          _smartStreamTile(
            context,
            icon: Icons.all_inbox_rounded,
            title: 'Todos os artigos',
            subtitle: totalUnread > 0 ? '$totalUnread não lidos' : null,
            feed: {
              'id': 'user/-/state/com.google/reading-list',
              'title': 'Todos os artigos',
            },
            hasUnread: totalUnread > 0,
          ),
          _smartStreamTile(
            context,
            icon: Icons.circle_notifications_rounded,
            title: 'Não lidos',
            subtitle: totalUnread > 0 ? '$totalUnread artigos' : 'Nenhum',
            feed: {
              'id': 'user/-/state/com.google/reading-list',
              'title': 'Não lidos',
              'exclude': 'user/-/state/com.google/read',
            },
            hasUnread: totalUnread > 0,
          ),
          const Divider(color: _divider, height: 1),
          _sectionHeader('ASSINATURAS'),
          if (allFeeds.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: Text(
                'Nenhum feed. Toque em + para adicionar.',
                style: TextStyle(color: _textSecondary, fontSize: 14),
              ),
            )
          else
            ...allFeeds.asMap().entries.map((entry) {
              final feed = entry.value;
              final feedId = feed['id'] as String? ?? '';
              final count = unreadCounts[feedId] ?? 0;
              final title = feed['title'] as String? ?? 'Sem título';
              final isLast = entry.key == allFeeds.length - 1;
              return _feedTile(context, feed: feed, title: title, count: count, isLast: isLast);
            }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
      child: Text(
        label,
        style: const TextStyle(
          color: _textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _smartStreamTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Map<String, dynamic> feed,
    required bool hasUnread,
  }) {
    return InkWell(
      onTap: () => _openFeed(context, feed),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: hasUnread
              ? const Border(left: BorderSide(color: _accent, width: 3))
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: hasUnread ? const Color(0x1AFF6B2C) : const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: hasUnread ? _accent : _textSecondary, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 15,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(color: _textSecondary, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _feedTile(
    BuildContext context, {
    required dynamic feed,
    required String title,
    required int count,
    required bool isLast,
  }) {
    final hasUnread = count > 0;
    return Column(
      children: [
        InkWell(
          onTap: () => _openFeed(context, feed),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: hasUnread
                  ? const Border(left: BorderSide(color: _accent, width: 3))
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _avatarColor(title).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _feedInitial(title),
                    style: TextStyle(
                      color: _avatarColor(title),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: _textPrimary,
                      fontSize: 14,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count > 999 ? '999+' : count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: _textSecondary, size: 18),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(color: _divider, height: 1, indent: 66),
      ],
    );
  }
}
