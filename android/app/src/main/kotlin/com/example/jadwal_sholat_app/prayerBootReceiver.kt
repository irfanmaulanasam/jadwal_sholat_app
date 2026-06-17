package com.example.jadwal_sholat_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Context
import android.content.Intent

class PrayerBootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (
            intent.action != Intent.ACTION_BOOT_COMPLETED &&
            intent.action != Intent.ACTION_MY_PACKAGE_REPLACED
        ) {
            return
        }

        updateWidgetNow(context)
        restoreWidgetUpdateAlarms(context)
    }

    private fun updateWidgetNow(context: Context) {
        val appWidgetManager =
            AppWidgetManager.getInstance(context)

        val componentName =
            ComponentName(
                context,
                PrayerWidgetProvider::class.java
            )

        val appWidgetIds =
            appWidgetManager.getAppWidgetIds(componentName)

        for (appWidgetId in appWidgetIds) {
            PrayerWidgetProvider.updateWidget(
                context,
                appWidgetManager,
                appWidgetId
            )
        }
    }

    private fun restoreWidgetUpdateAlarms(context: Context) {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )

        val raw = prefs.getString(
            "flutter.widget_update_triggers",
            ""
        ) ?: ""

        if (raw.isBlank()) return

        val now = System.currentTimeMillis()

        raw.split(",")
            .mapNotNull { it.toLongOrNull() }
            .filter { it > now }
            .forEach { triggerAt ->
                scheduleWidgetUpdate(
                    context,
                    triggerAt,
                )
            }
    }

    private fun scheduleWidgetUpdate(
        context: Context,
        triggerAt: Long
    ) {
        val alarmManager =
            context.getSystemService(
                Context.ALARM_SERVICE
            ) as AlarmManager

        val intent = Intent(
            context,
            PrayerWidgetUpdateReceiver::class.java
        )

        val requestCode =
            (triggerAt % Int.MAX_VALUE).toInt()

        val pendingIntent =
            PendingIntent.getBroadcast(
                context,
                requestCode,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or
                    PendingIntent.FLAG_IMMUTABLE
            )

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerAt,
            pendingIntent
        )
    }
}