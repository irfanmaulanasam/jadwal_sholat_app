import 'package:flutter/material.dart';
import '../services/prayer_notification_service.dart';

class DebugNotificationPage extends StatefulWidget {
  const DebugNotificationPage({super.key});

  @override
  State<DebugNotificationPage> createState() => _DebugNotificationPageState();
}

class _DebugNotificationPageState extends State<DebugNotificationPage> {
  final _notificationService = PrayerNotificationService();
  String _log = 'Belum ada test';

  Future<void> _testInstant() async {
    await _notificationService.init();
    await _notificationService.showInstantTestNotification();

    setState(() {
      _log = 'Instant notification dikirim.';
    });
  }

  Future<void> _testScheduled() async {
    await _notificationService.init();
    await _notificationService.showTestNotificationInSeconds(seconds: 10);

    setState(() {
      _log = 'Scheduled notification dijadwalkan 10 detik.';
    });
  }

  Future<void> _showPending() async {
    await _notificationService.init();

    final pending = await _notificationService.getPendingDebugText();

    setState(() {
      _log = pending;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Notifikasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: _testInstant,
            child: const Text('Test Notifikasi Langsung'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _testScheduled,
            child: const Text('Test Notifikasi 10 Detik'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _showPending,
            child: const Text('Lihat Notifikasi Terjadwal'),
          ),
          const SizedBox(height: 24),
          SelectableText(_log),
          FilledButton(
            onPressed: () async {
              await _notificationService.showTestNotificationInMinutes(
                minutes: 1,
              );
            },
            child: const Text('Test +1 Menit'),
          ),

          FilledButton(
            onPressed: () async {
              await _notificationService.showTestNotificationInMinutes(
                minutes: 2,
              );
            },
            child: const Text('Test +2 Menit'),
          ),

          FilledButton(
            onPressed: () async {
              await _notificationService.showTestNotificationInMinutes(
                minutes: 5,
              );
            },
            child: const Text('Test +5 Menit'),
          ),
        ],
      ),
    );
  }
}