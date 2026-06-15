import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/hijr_date_helpers.dart';
import '../helpers/prayer_status_helper.dart';
import '../models/prayer_day.dart';
import '../models/prayer_settings.dart';

class PrayerWidgetDataService {
  Future<void> saveTodayWidgetData({
    required PrayerDay today,
    required PrayerSettings settings,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final status = PrayerStatusHelper.getStatus(
      today,
      settings.isMale,
    );

    await prefs.setString(
      'widget_hijri_date',
      HijriHelper.fromGregorian(DateTime.now()),
    );

    await prefs.setString(
      'widget_current_name',
      status.currentPrayerName,
    );

    await prefs.setString(
      'widget_current_time',
      status.currentPrayerTime,
    );

    await prefs.setString(
      'widget_next_name',
      status.nextPrayerName,
    );

    await prefs.setString(
      'widget_next_time',
      status.nextPrayerTime,
    );

    await prefs.setString('widget_subuh', today.subuh);
    await prefs.setString('widget_dzuhur', today.dzuhur);
    await prefs.setString('widget_ashar', today.ashar);
    await prefs.setString('widget_maghrib', today.maghrib);
    await prefs.setString('widget_isya', today.isya);
  }
}