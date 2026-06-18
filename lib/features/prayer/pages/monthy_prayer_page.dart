import 'package:flutter/material.dart';
import '../models/prayer_day.dart';
import '../models/prayer_settings.dart';

class MonthlyPrayerPage extends StatelessWidget {
  final List<PrayerDay> days;
  final PrayerSettings settings;

  const MonthlyPrayerPage({
    super.key,
    required this.days,
    required this.settings,
  });

  String _middayLabel(PrayerDay day) {
    final isFriday = day.hari.toLowerCase() == 'jumat';

    if (isFriday && settings.isMale) {
      return 'Jmt';
    }

    return 'Dz';
  }

  String _applyOffset(String time) {
    final offset = settings.minuteOffset;
    final parts = time.split(':');
    final now = DateTime.now();

    final adjusted = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    ).add(Duration(minutes: offset));

    return '${adjusted.hour.toString().padLeft(2, '0')}:${adjusted.minute.toString().padLeft(2, '0')}';
  }

  bool _isToday(PrayerDay day) {
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return day.tanggalLengkap == today;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Bulanan'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              12,
              12,
              12,
              MediaQuery.of(context).padding.bottom + 20,
            ),
            child: DataTable(
            columnSpacing: 12,
            horizontalMargin: 8,
            headingRowHeight: 32,
            dataRowMinHeight: 30,
            dataRowMaxHeight: 34,
            columns: const [
              DataColumn(label: Text('Tgl')),
              DataColumn(label: Text('Hari')),
              DataColumn(label: Text('Subuh')),
              DataColumn(label: Text('Dz/Jmt')),
              DataColumn(label: Text('Ashar')),
              DataColumn(label: Text('Maghrib')),
              DataColumn(label: Text('Isya')),
            ],
            rows: days.map((day) {
              final isToday = _isToday(day);

              return DataRow(
                selected: isToday,
                cells: [
                  DataCell(Text(day.tanggal.toString(),style: const TextStyle(fontSize: 11))),
                  DataCell(Text(day.hari, style: const TextStyle(fontSize: 11))),
                  DataCell(Text(_applyOffset(day.subuh), style: const TextStyle(fontSize: 11))),
                  DataCell(
                    Text(
                      '${_middayLabel(day)} ${_applyOffset(day.dzuhur)}',
                      style: const TextStyle(fontSize: 11)
                    ),
                  ),
                  DataCell(Text(_applyOffset(day.ashar), style: const TextStyle(fontSize: 11))),
                  DataCell(Text(_applyOffset(day.maghrib), style: const TextStyle(fontSize: 11))),
                  DataCell(Text(_applyOffset(day.isya), style: const TextStyle(fontSize: 11))),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}