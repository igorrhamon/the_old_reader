import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../services/old_reader_api.dart';

const _accent = Color(0xFFFF6B2C);
const _textPrimary = Color(0xFFF2F2F7);
const _textSecondary = Color(0xFF8E8E93);
const _bg = Color(0xFF0F0F0F);
const _surface = Color(0xFF1C1C1E);

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
    if (id.isNotEmpty) widget.api.markAsRead(id);
  }

  String _formatDate(dynamic published) {
    if (published == null) return '';
    try {
      final ts = int.tryParse(published.toString());
      if (ts != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
        const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
        return '${dt.day} ${months[dt.month - 1]}. ${dt.year}';
      }
    } catch (_) {}
    return published.toString();
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final title = article['title'] as String? ?? 'Artigo';
    final author = article['author'] as String? ?? '';
    final published = article['published'];
    final summary = article['summary'] as String? ?? '';
    final content = article['content'] as String? ?? '';
    final htmlContent = content.isNotEmpty ? content : summary;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Artigo', style: TextStyle(fontSize: 15, color: _textSecondary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Orange accent line — the article's "chapter mark"
                  Container(
                    width: 32,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'article_title_${article['id']}',
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (author.isNotEmpty) ...[
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            author.isNotEmpty ? author[0].toUpperCase() : '?',
                            style: const TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            author,
                            style: const TextStyle(color: _textSecondary, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (published != null)
                          Text(
                            _formatDate(published),
                            style: const TextStyle(color: _textSecondary, fontSize: 12),
                          ),
                      ] else if (published != null) ...[
                        Text(
                          _formatDate(published),
                          style: const TextStyle(color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Divider(color: Color(0xFF3A3A3C)),
                  const SizedBox(height: 20),
                  if (htmlContent.isNotEmpty)
                    Html(
                      data: htmlContent,
                      style: {
                        'body': Style(
                          color: _textPrimary,
                          fontSize: FontSize(16),
                          lineHeight: const LineHeight(1.75),
                          fontFamily: 'Roboto',
                          padding: HtmlPaddings.zero,
                          margin: Margins.zero,
                        ),
                        'p': Style(
                          color: _textPrimary,
                          fontSize: FontSize(16),
                          lineHeight: const LineHeight(1.75),
                          margin: Margins.only(bottom: 16),
                        ),
                        'h1': Style(color: _textPrimary, fontWeight: FontWeight.w700),
                        'h2': Style(color: _textPrimary, fontWeight: FontWeight.w700),
                        'h3': Style(color: _textPrimary, fontWeight: FontWeight.w700),
                        'a': Style(color: _accent),
                        'blockquote': Style(
                          color: _textSecondary,
                          border: const Border(
                            left: BorderSide(color: _accent, width: 3),
                          ),
                          padding: HtmlPaddings.only(left: 16),
                          fontStyle: FontStyle.italic,
                        ),
                        'code': Style(
                          backgroundColor: _surface,
                          color: const Color(0xFF10B981),
                          fontFamily: 'monospace',
                          fontSize: FontSize(13),
                        ),
                        'pre': Style(
                          backgroundColor: _surface,
                          color: const Color(0xFF10B981),
                          fontFamily: 'monospace',
                          fontSize: FontSize(13),
                        ),
                        'img': Style(width: Width(100, Unit.percent)),
                      },
                    )
                  else
                    const Text(
                      'Conteúdo não disponível.',
                      style: TextStyle(color: _textSecondary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
