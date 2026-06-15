import 'package:flutter/material.dart';

import '../models/prayer_settings.dart';
import '../services/prayer_settings_service.dart';
import 'prayer_page.dart';

class PrayerOnboardingPage extends StatefulWidget {
  const PrayerOnboardingPage({super.key});

  @override
  State<PrayerOnboardingPage> createState() => _PrayerOnboardingPageState();
}

class _PrayerOnboardingPageState extends State<PrayerOnboardingPage> {
  bool _isMale = true;

  final _settingsService = PrayerSettingsService();

  Future<void> _saveAndContinue() async {
    await _settingsService.save(
      PrayerSettings(
        onboardingDone: true,
        isMale: _isMale,
        provinceName: 'Jawa Barat',
        cityName: 'Kab. Cianjur',
        minuteOffset: 0,
      ),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const PrayerPage(),
      ),
    );
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
            onChanged: (value) {
              setState(() => _isMale = value!);
            },
          ),
          RadioListTile<bool>(
            title: const Text('Perempuan'),
            value: false,
            groupValue: _isMale,
            onChanged: (value) {
              setState(() => _isMale = value!);
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saveAndContinue,
            child: const Text('Mulai dengan Kab. Cianjur'),
          ),
        ],
      ),
    );
  }
}