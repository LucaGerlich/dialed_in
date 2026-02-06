package com.lucagerlich.dialed_in

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BeanStatsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.bean_stats_widget).apply {
                val beanCount = widgetData.getInt("bean_count", 0)
                val totalShots = widgetData.getInt("total_shots", 0)
                val topBean = widgetData.getString("top_bean", "No beans yet")

                setTextViewText(R.id.widget_bean_count_value, beanCount.toString())
                setTextViewText(R.id.widget_total_shots_value, totalShots.toString())
                setTextViewText(R.id.widget_top_bean_value, topBean)
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
