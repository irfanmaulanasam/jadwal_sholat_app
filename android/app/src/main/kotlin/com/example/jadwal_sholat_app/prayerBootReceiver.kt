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
        restoreNativePrayerAlarms(context)
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

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) return
        }

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerAt,
            pendingIntent
        )
    }
    private fun restoreNativePrayerAlarms(context: Context) {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )

        val raw = prefs.getString(
            "flutter.native_prayer_alarm_triggers",
            ""
        ) ?: ""

        if (raw.isBlank()) return

        val now = System.currentTimeMillis()

        raw.split(";;")
            .filter { it.isNotBlank() }
            .forEach { item ->
                val parts = item.split("|")

                if (parts.size < 3) return@forEach

                val triggerAt = parts[0].toLongOrNull() ?: return@forEach
                val prayerName = parts[1]
                val prayerTime = parts[2]

                if (triggerAt > now) {
                    scheduleNativePrayerAlarm(
                        context,
                        triggerAt,
                        prayerName,
                        prayerTime
                    )
                }
            }
    }

    private fun scheduleNativePrayerAlarm(
        context: Context,
        triggerAt: Long,
        prayerName: String,
        prayerTime: String
    ) {
        val alarmManager =
            context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            if (!alarmManager.canScheduleExactAlarms()) return
        }

        val intent = Intent(
            context,
            NativePrayerAlarmReceiver::class.java
        ).apply {
            putExtra("prayerName", prayerName)
            putExtra("prayerTime", prayerTime)
        }

        val requestCode =
            (triggerAt.toString() + prayerName).hashCode()

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