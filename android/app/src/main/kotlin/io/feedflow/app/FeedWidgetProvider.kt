package io.feedflow.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews

class FeedWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        fun updateWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
            val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            val views = RemoteViews(context.packageName, R.layout.feed_widget)

            val count = prefs.getInt("article_count", 0)

            val rowIds = listOf(
                listOf(R.id.article_row_0, R.id.article_title_0, R.id.article_feed_0),
                listOf(R.id.article_row_1, R.id.article_title_1, R.id.article_feed_1),
                listOf(R.id.article_row_2, R.id.article_title_2, R.id.article_feed_2),
                listOf(R.id.article_row_3, R.id.article_title_3, R.id.article_feed_3),
                listOf(R.id.article_row_4, R.id.article_title_4, R.id.article_feed_4),
            )

            for (i in 0 until 5) {
                val (rowId, titleId, feedId) = rowIds[i]
                if (i < count) {
                    val title = prefs.getString("article_title_$i", "") ?: ""
                    val feed = prefs.getString("article_feed_$i", "") ?: ""
                    val url = prefs.getString("article_url_$i", "") ?: ""

                    views.setViewVisibility(rowId, View.VISIBLE)
                    views.setTextViewText(titleId, title)
                    views.setTextViewText(feedId, feed)

                    val intent = Intent(context, MainActivity::class.java).apply {
                        action = Intent.ACTION_VIEW
                        if (url.isNotEmpty()) data = Uri.parse(url)
                        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                    }
                    val pi = PendingIntent.getActivity(
                        context, i, intent,
                        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                    )
                    views.setOnClickPendingIntent(rowId, pi)
                } else {
                    views.setViewVisibility(rowId, View.GONE)
                }
            }

            val refreshIntent = Intent(context, FeedWidgetProvider::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
            }
            val refreshPi = PendingIntent.getBroadcast(
                context, appWidgetId, refreshIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.btn_refresh, refreshPi)

            val openIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }
            val openPi = PendingIntent.getActivity(
                context, 999, openIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_header, openPi)

            if (count == 0) {
                views.setViewVisibility(R.id.tv_empty, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.tv_empty, View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
