import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_settings.dart';

class PrayerSettingsService {
  Future<PrayerSettings> load() async {
    final prefs = await SharedPreferences.getInstance();

    return PrayerSettings(
      onboardingDone: prefs.getBool('onboardingDone') ?? false,
      isMale: prefs.getBool('isMale') ?? true,
      provinceName: prefs.getString('provinceName') ?? 'Jawa Barat',
      cityName: prefs.getString('cityName') ?? 'Kab. Cianjur',
      minuteOffset: prefs.getInt('minuteOffset') ?? 0,
    );
  }

  Future<void> save(PrayerSettings settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('onboardingDone', settings.onboardingDone);
    await prefs.setBool('isMale', settings.isMale);
    await prefs.setString('provinceName', settings.provinceName);
    await prefs.setString('cityName', settings.cityName);
    await prefs.setInt('minuteOffset', settings.minuteOffset);
  }
}