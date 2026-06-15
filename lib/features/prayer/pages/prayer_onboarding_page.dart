import 'package:flutter/material.dart';

import '../models/prayer_settings.dart';
import '../services/location_service.dart';
import '../services/prayer_settings_service.dart';
import 'prayer_page.dart';

class PrayerOnboardingPage extends StatefulWidget {
  const PrayerOnboardingPage({super.key});

  @override
  State<PrayerOnboardingPage> createState() => _PrayerOnboardingPageState();
}

class _PrayerOnboardingPageState extends State<PrayerOnboardingPage> {
  bool _isMale = true;
  bool _loading = false;

  final _settingsService = PrayerSettingsService();
  final _locationService = LocationService();

  Future<void> _saveAndContinue() async {
    setState(() => _loading = true);

    try {
      final position = await _locationService.getCurrentPosition();

      await _settingsService.save(
        PrayerSettings(
          onboardingDone: true,
          isMale: _isMale,
          homeLatitude: position.latitude,
          homeLongitude: position.longitude,
          travelMode: false,
          travelCityName: null,
          travelLatitude: null,
          travelLongitude: null,
          locationName: 'Cianjur',
          minuteOffset: 3,
        ),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const PrayerPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil lokasi: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Awal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Pengguna'),
          RadioListTile<bool>(
            title: const Text('Laki-laki'),
            value: true,
            groupValue: _isMale,
            onChanged: _loading
                ? null
                : (value) {
                    setState(() => _isMale = value!);
                  },
          ),
          RadioListTile<bool>(
            title: const Text('Perempuan'),
            value: false,
            groupValue: _isMale,
            onChanged: _loading
                ? null
                : (value) {
                    setState(() => _isMale = value!);
                  },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _saveAndContinue,
            child: _loading
                ? const Text('Mengambil lokasi...')
                : const Text('Pakai Lokasi Sekarang'),
          ),
        ],
      ),
    );
  }
}