import 'package:flutter/services.dart';
import 'package:jadwal_sholat_app/features/prayer/services/hijri_api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/prayer_status_helper.dart';
import '../models/prayer_day.dart';
import '../models/prayer_settings.dart';

class PrayerWidgetDataService {
  static const _channel = MethodChannel('prayer_widget_channel');
  final _hijriApiService = HijriApiService();

  Future<void> scheduleWidgetUpdate(DateTime time) async {
    try {
      await _channel.invokeMethod(
        'scheduleWidgetUpdate',
        {
          'triggerAt': time.millisecondsSinceEpoch,
        },
      );
    } catch (_) {}
  }

  Future<void> saveTodayWidgetData({
    required PrayerDay today,
    required PrayerSettings settings,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final status = PrayerStatusHelper.getStatus(
      today,
      settings.isMale,
    );

    String hijriDate = '-';

    try {
      hijriDate = await _hijriApiService.fetchTodayHijriDate();
    } catch (_) {
      hijriDate = prefs.getString('widget_hijri_date') ?? '-';
    }

    await prefs.setString('widget_hijri_date', hijriDate);

    await prefs.setString('widget_current_name', status.currentPrayerName);
    await prefs.setString('widget_current_time', status.currentPrayerTime);
    await prefs.setString('widget_next_name', status.nextPrayerName);
    await prefs.setString('widget_next_time', status.nextPrayerTime);

    await prefs.setString('widget_subuh', today.subuh);
    await prefs.setString('widget_dzuhur', today.dzuhur);
    await prefs.setString('widget_ashar', today.ashar);
    await prefs.setString('widget_maghrib', today.maghrib);
    await prefs.setString('widget_isya', today.isya);

    await updateAndroidWidget();
  }

  Future<void> updateAndroidWidget() async {
    try {
      await _channel.invokeMethod('updatePrayerWidget');
    } catch (_) {
      // Aman diabaikan untuk platform non-Android.
    }
  }
}