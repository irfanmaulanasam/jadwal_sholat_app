package com.example.jadwal_sholat_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews

class PrayerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updatePrayerWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updatePrayerWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int
    ) {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )

        fun getString(key: String, fallback: String): String {
            return prefs.getString("flutter.$key", fallback) ?: fallback
        }

        val hijriDate = getString("widget_hijri_date", "-")
        val currentName = getString("widget_current_name", "Jadwal")
        val currentTime = getString("widget_current_time", "--:--")
        val nextName = getString("widget_next_name", "-")
        val nextTime = getString("widget_next_time", "--:--")

        val views = RemoteViews(
            context.packageName,
            R.layout.prayer_widget
        )

        views.setTextViewText(R.id.hijri_date, hijriDate)
        views.setTextViewText(R.id.current_name, currentName.uppercase())
        views.setTextViewText(R.id.current_time, currentTime)
        views.setTextViewText(
            R.id.next_prayer,
            "Berikutnya: $nextName $nextTime"
        )

        views.setTextViewText(R.id.time_subuh, getString("widget_subuh", "--:--"))
        views.setTextViewText(R.id.time_dzuhur, getString("widget_dzuhur", "--:--"))
        views.setTextViewText(R.id.time_ashar, getString("widget_ashar", "--:--"))
        views.setTextViewText(R.id.time_maghrib, getString("widget_maghrib", "--:--"))
        views.setTextViewText(R.id.time_isya, getString("widget_isya", "--:--"))

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}