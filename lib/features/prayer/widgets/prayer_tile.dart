import 'package:flutter/material.dart';

class PrayerTile extends StatelessWidget {
  final String name;
  final String time;
  final bool isActive;
  final bool isNext;

  const PrayerTile({
    super.key,
    required this.name,
    required this.time,
    this.isActive = false,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isActive
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: ListTile(
        leading: isNext
            ? const Icon(Icons.notifications_active)
            : null,
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: isActive ? const Text('Sedang berlangsung') : null,
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 20,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}