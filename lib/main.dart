import 'package:flutter/material.dart';

import 'features/prayer/pages/prayer_page.dart';
import 'features/prayer/pages/prayer_onboarding_page.dart';
import 'features/prayer/services/prayer_settings_service.dart';

void main() {
  runApp(const JadwalSholatApp());
}

class JadwalSholatApp extends StatelessWidget {
  const JadwalSholatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jadwal Sholat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const AppLauncher(),
    );
  }
}

class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  final _settingsService = PrayerSettingsService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _settingsService.load(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final settings = snapshot.data!;

        if (!settings.onboardingDone) {
          return const PrayerOnboardingPage();
        }

        return const PrayerPage();
      },
    );
  }
}