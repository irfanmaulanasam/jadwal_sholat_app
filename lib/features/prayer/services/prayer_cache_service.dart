import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/prayer_cache.dart';
import '../models/prayer_day.dart';

class PrayerCacheService {
  static const _key = 'prayer_location_caches';

  Future<List<PrayerCache>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);

    if (raw == null) return [];

    final List decoded = jsonDecode(raw);

    return decoded
        .map((item) => PrayerCache.fromJson(item))
        .toList();
  }

  Future<void> saveCache({
    required double latitude,
    required double longitude,
    required List<PrayerDay> days,
  }) async {
    final caches = await loadAll();

    caches.removeWhere((cache) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        cache.latitude,
        cache.longitude,
      );

      return distance < 20000;
    });

    caches.add(
      PrayerCache(
        latitude: latitude,
        longitude: longitude,
        savedAt: DateTime.now().millisecondsSinceEpoch,
        days: days,
      ),
    );

    final encoded = jsonEncode(
      caches.map((cache) => cache.toJson()).toList(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, encoded);
  }

  Future<PrayerCache?> findNearestCache({
    required double latitude,
    required double longitude,
    double maxDistanceMeters = 25000,
  }) async {
    final caches = await loadAll();

    if (caches.isEmpty) return null;

    PrayerCache? nearest;
    double? nearestDistance;

    for (final cache in caches) {
      final distance = Geolocator.distanceBetween(
        latitude,
        longitude,
        cache.latitude,
        cache.longitude,
      );

      if (nearestDistance == null || distance < nearestDistance) {
        nearest = cache;
        nearestDistance = distance;
      }
    }

    if (nearestDistance != null &&
        nearestDistance <= maxDistanceMeters) {
      return nearest;
    }

    return null;
  }

  Future<PrayerCache?> loadLastCache() async {
    final caches = await loadAll();

    if (caches.isEmpty) return null;

    caches.sort((a, b) => b.savedAt.compareTo(a.savedAt));

    return caches.first;
  }

  bool isStillValid(PrayerCache cache) {
    final savedDate =
        DateTime.fromMillisecondsSinceEpoch(cache.savedAt);

    return DateTime.now().difference(savedDate).inDays < 30;
  }
}