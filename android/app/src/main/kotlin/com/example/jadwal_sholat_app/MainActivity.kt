package com.example.jadwal_sholat_app

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val channelName = "prayer_widget_channel"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "updatePrayerWidget" -> {
                    updatePrayerWidget()
                    result.success(true)
                }

                "scheduleWidgetUpdate" -> {
                    val triggerAt =
                        call.argument<Long>("triggerAt")

                    if (triggerAt != null) {
                        scheduleWidgetUpdate(triggerAt)
                        result.success(true)
                    } else {
                        result.error(
                            "INVALID_ARGUMENT",
                            "triggerAt is null",
                            null
                        )
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun updatePrayerWidget() {

        val appWidgetManager =
            AppWidgetManager.getInstance(this)

        val componentName =
            ComponentName(
                this,
                PrayerWidgetProvider::class.java
            )

        val appWidgetIds =
            appWidgetManager.getAppWidgetIds(
                componentName
            )

        for (appWidgetId in appWidgetIds) {
            PrayerWidgetProvider.updateWidget(
                this,
                appWidgetManager,
                appWidgetId
            )
        }
    }

    private fun scheduleWidgetUpdate(
        triggerAt: Long
    ) {

        val alarmManager =
            getSystemService(
                Context.ALARM_SERVICE
            ) as AlarmManager

        val intent = Intent(
            this,
            PrayerWidgetUpdateReceiver::class.java
        )

        val requestCode =
            (triggerAt % Int.MAX_VALUE).toInt()

        val pendingIntent =
            PendingIntent.getBroadcast(
                this,
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