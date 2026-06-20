package com.example.jadwal_sholat_app

import android.app.PendingIntent
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
            updateWidget(
                context,
                appWidgetManager,
                appWidgetId
            )
        }
    }

    companion object {

        data class PrayerStatus(
            val currentName: String,
            val currentTime: String,
            val nextName: String,
            val nextTime: String
        )

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(
                "FlutterSharedPreferences",
                Context.MODE_PRIVATE
            )

            fun getString(
                key: String,
                fallback: String
            ): String {
                return prefs.getString(
                    "flutter.$key",
                    fallback
                ) ?: fallback
            }

            val hijriDate = getString(
                "widget_hijri_date",
                "-"
            )

            val subuh = getString(
                "widget_subuh",
                "--:--"
            )

            val dzuhur = getString(
                "widget_dzuhur",
                "--:--"
            )

            val ashar = getString(
                "widget_ashar",
                "--:--"
            )

            val maghrib = getString(
                "widget_maghrib",
                "--:--"
            )

            val isya = getString(
                "widget_isya",
                "--:--"
            )

            val status = getPrayerStatus(
                subuh = subuh,
                dzuhur = dzuhur,
                ashar = ashar,
                maghrib = maghrib,
                isya = isya
            )

            val views = RemoteViews(
                context.packageName,
                R.layout.prayer_widget
            )

            val launchIntent =
                context.packageManager
                    .getLaunchIntentForPackage(
                        context.packageName
                    )

            if (launchIntent != null) {
                val pendingIntent =
                    PendingIntent.getActivity(
                        context,
                        0,
                        launchIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or
                            PendingIntent.FLAG_IMMUTABLE
                    )

                views.setOnClickPendingIntent(
                    R.id.widget_root,
                    pendingIntent
                )
            }

            views.setTextViewText(
                R.id.hijri_date,
                hijriDate
            )

            views.setTextViewText(
                R.id.current_name,
                status.currentName.uppercase()
            )

            views.setTextViewText(
                R.id.current_time,
                status.currentTime
            )

            views.setTextViewText(
                R.id.next_prayer,
                "Berikutnya: ${status.nextName} ${status.nextTime}"
            )

            views.setTextViewText(
                R.id.time_subuh,
                subuh
            )

            views.setTextViewText(
                R.id.time_dzuhur,
                dzuhur
            )

            views.setTextViewText(
                R.id.time_ashar,
                ashar
            )

            views.setTextViewText(
                R.id.time_maghrib,
                maghrib
            )

            views.setTextViewText(
                R.id.time_isya,
                isya
            )

            appWidgetManager.updateAppWidget(
                appWidgetId,
                views
            )
        }

        private fun getPrayerStatus(
            subuh: String,
            dzuhur: String,
            ashar: String,
            maghrib: String,
            isya: String
        ): PrayerStatus {
            val now =
                java.util.Calendar.getInstance()

            val nowMinutes =
                now.get(java.util.Calendar.HOUR_OF_DAY) * 60 +
                    now.get(java.util.Calendar.MINUTE)

            fun toMinutes(time: String): Int {
                val parts = time.split(":")

                if (parts.size < 2) {
                    return 0
                }

                val hour =
                    parts[0].toIntOrNull() ?: 0

                val minute =
                    parts[1].toIntOrNull() ?: 0

                return hour * 60 + minute
            }

            val prayers = listOf(
                Triple("Subuh", subuh, toMinutes(subuh)),
                Triple("Dzuhur", dzuhur, toMinutes(dzuhur)),
                Triple("Ashar", ashar, toMinutes(ashar)),
                Triple("Maghrib", maghrib, toMinutes(maghrib)),
                Triple("Isya", isya, toMinutes(isya))
            )

            if (
                subuh == "--:--" ||
                dzuhur == "--:--" ||
                ashar == "--:--" ||
                maghrib == "--:--" ||
                isya == "--:--"
            ) {
                return PrayerStatus(
                    currentName = "Jadwal",
                    currentTime = "--:--",
                    nextName = "-",
                    nextTime = "--:--"
                )
            }

            if (nowMinutes < prayers.first().third) {
                return PrayerStatus(
                    currentName = prayers.last().first,
                    currentTime = prayers.last().second,
                    nextName = prayers.first().first,
                    nextTime = prayers.first().second
                )
            }

            for (index in prayers.indices) {
                val current = prayers[index]
                val next =
                    if (index == prayers.lastIndex) {
                        prayers.first()
                    } else {
                        prayers[index + 1]
                    }

                val nextTimeMinutes =
                    if (index == prayers.lastIndex) {
                        24 * 60 + prayers.first().third
                    } else {
                        next.third
                    }

                if (
                    nowMinutes >= current.third &&
                    nowMinutes < nextTimeMinutes
                ) {
                    return PrayerStatus(
                        currentName = current.first,
                        currentTime = current.second,
                        nextName = next.first,
                        nextTime = next.second
                    )
                }
            }

            return PrayerStatus(
                currentName = "Isya",
                currentTime = isya,
                nextName = "Subuh",
                nextTime = subuh
            )
        }
    }
}