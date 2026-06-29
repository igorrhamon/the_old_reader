import 'package:home_widget/home_widget.dart';
import '../models/article.dart';

const _appGroupId = 'io.feedflow.app';
const _androidWidgetName = 'FeedWidgetProvider';
const _maxArticles = 5;

class FeedWidgetService {
  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  static Future<void> update(List<Article> articles) async {
    // Pegar até 5 artigos não lidos
    final unread = articles.where((a) => !a.isRead).take(_maxArticles).toList();

    await HomeWidget.saveWidgetData('article_count', unread.length);

    for (var i = 0; i < _maxArticles; i++) {
      if (i < unread.length) {
        final a = unread[i];
        await HomeWidget.saveWidgetData('article_title_$i', a.title);
        await HomeWidget.saveWidgetData('article_feed_$i', a.feedId);
        await HomeWidget.saveWidgetData('article_id_$i', a.id);
        await HomeWidget.saveWidgetData('article_url_$i', a.url ?? '');
      } else {
        await HomeWidget.saveWidgetData('article_title_$i', '');
        await HomeWidget.saveWidgetData('article_feed_$i', '');
        await HomeWidget.saveWidgetData('article_id_$i', '');
        await HomeWidget.saveWidgetData('article_url_$i', '');
      }
    }

    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
    );
  }
}
