import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_settings.dart';

class PrayerSettingsService {
  Future<PrayerSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return PrayerSettings(
      onboardingDone: prefs.getBool('onboardingDone') ?? false,
      isMale: prefs.getBool('isMale') ?? true,

      homeLatitude: prefs.getDouble('homeLatitude'),
      homeLongitude: prefs.getDouble('homeLongitude'),

      travelMode: prefs.getBool('travelMode') ?? false,
      travelCityName: prefs.getString('travelCityName'),
      travelLatitude: prefs.getDouble('travelLatitude'),
      travelLongitude: prefs.getDouble('travelLongitude'),

      locationName: prefs.getString('locationName') ?? 'Cianjur',
      minuteOffset: prefs.getInt('minuteOffset') ?? 3,
    );
  }

  Future<void> save(PrayerSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('onboardingDone', settings.onboardingDone);
    await prefs.setBool('isMale', settings.isMale);

    if (settings.homeLatitude != null) {
      await prefs.setDouble('homeLatitude', settings.homeLatitude!);
    }

    if (settings.homeLongitude != null) {
      await prefs.setDouble('homeLongitude', settings.homeLongitude!);
    }

    await prefs.setBool('travelMode', settings.travelMode);

    if (settings.travelCityName != null) {
      await prefs.setString('travelCityName', settings.travelCityName!);
    }

    if (settings.travelLatitude != null) {
      await prefs.setDouble('travelLatitude', settings.travelLatitude!);
    }

    if (settings.travelLongitude != null) {
      await prefs.setDouble('travelLongitude', settings.travelLongitude!);
    }

    await prefs.setString('locationName', settings.locationName);
    await prefs.setInt('minuteOffset', settings.minuteOffset);
  }

  Future<void> disableTravelMode() async {
    final current = await load();

    await save(
      current.copyWith(
        travelMode: false,
      ),
    );
  }
}