import 'prayer_day.dart';

class PrayerCache {
  final double latitude;
  final double longitude;
  final int savedAt;
  final List<PrayerDay> days;

  PrayerCache({
    required this.latitude,
    required this.longitude,
    required this.savedAt,
    required this.days,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'savedAt': savedAt,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }

  factory PrayerCache.fromJson(Map<String, dynamic> json) {
    return PrayerCache(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      savedAt: json['savedAt'],
      days: (json['days'] as List)
          .map((item) => PrayerDay.fromCache(item))
          .toList(),
    );
  }
}