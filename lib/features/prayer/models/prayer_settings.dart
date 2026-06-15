class PrayerSettings {
  final bool onboardingDone;
  final bool isMale;

  final double? homeLatitude;
  final double? homeLongitude;

  final bool travelMode;
  final String? travelCityName;
  final double? travelLatitude;
  final double? travelLongitude;

  final String locationName;
  final int minuteOffset;

  const PrayerSettings({
    required this.onboardingDone,
    required this.isMale,
    required this.homeLatitude,
    required this.homeLongitude,
    required this.travelMode,
    required this.travelCityName,
    required this.travelLatitude,
    required this.travelLongitude,
    required this.locationName,
    required this.minuteOffset,
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
      locationName: 'Cianjur',
      minuteOffset: 3,
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

  String get activeLocationInfo {
    if (travelMode && travelCityName != null) {
      return '$travelCityName, penyesuaian $minuteOffset menit';
    }

    return '$locationName, penyesuaian $minuteOffset menit';
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
    String? locationName,
    int? minuteOffset,
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
      locationName: locationName ?? this.locationName,
      minuteOffset: minuteOffset ?? this.minuteOffset,
    );
  }
}