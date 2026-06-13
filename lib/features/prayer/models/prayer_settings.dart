class PrayerSettings {
  final bool onboardingDone;
  final bool isMale;

  final double? homeLatitude;
  final double? homeLongitude;

  final bool travelMode;
  final String? travelCityName;
  final double? travelLatitude;
  final double? travelLongitude;

  const PrayerSettings({
    required this.onboardingDone,
    required this.isMale,
    required this.homeLatitude,
    required this.homeLongitude,
    required this.travelMode,
    required this.travelCityName,
    required this.travelLatitude,
    required this.travelLongitude,
  });

  factory PrayerSettings.defaultValue() {
    return const PrayerSettings(
      onboardingDone: false,
      isMale: true,
      homeLatitude: null,
      homeLongitude: null,
      travelMode: false,
      travelCityName: null,
      travelLatitude: null,
      travelLongitude: null,
    );
  }

  double? get activeLatitude {
    if (travelMode && travelLatitude != null) {
      return travelLatitude;
    }
    return homeLatitude;
  }

  double? get activeLongitude {
    if (travelMode && travelLongitude != null) {
      return travelLongitude;
    }
    return homeLongitude;
  }

  String get activeLocationLabel {
    if (travelMode && travelCityName != null) {
      return travelCityName!;
    }
    return 'Lokasi utama';
  }

  String get activeLocationInfo {
    final lat = activeLatitude;
    final lng = activeLongitude;

    if (lat == null || lng == null) {
      return 'Lokasi belum tersedia';
    }

    if (travelMode && travelCityName != null) {
      return '$travelCityName (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
    }

    return 'Lokasi utama (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
  }

  PrayerSettings copyWith({
    bool? onboardingDone,
    bool? isMale,
    double? homeLatitude,
    double? homeLongitude,
    bool? travelMode,
    String? travelCityName,
    double? travelLatitude,
    double? travelLongitude,
  }) {
    return PrayerSettings(
      onboardingDone: onboardingDone ?? this.onboardingDone,
      isMale: isMale ?? this.isMale,
      homeLatitude: homeLatitude ?? this.homeLatitude,
      homeLongitude: homeLongitude ?? this.homeLongitude,
      travelMode: travelMode ?? this.travelMode,
      travelCityName: travelCityName ?? this.travelCityName,
      travelLatitude: travelLatitude ?? this.travelLatitude,
      travelLongitude: travelLongitude ?? this.travelLongitude,
    );
  }
}