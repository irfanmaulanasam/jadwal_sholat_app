import 'dart:convert';
import 'package:http/http.dart' as http;

class HijriApiService {
  Future<String> fetchTodayHijriDate() async {
    final now = DateTime.now();

    return fetchHijriDate(now);
  }

  Future<String> fetchHijriDate(DateTime date) async {
    final dateText =
        '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';

    final uri = Uri.parse(
      'https://api.aladhan.com/v1/gToH/$dateText',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil tanggal Hijriah: ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body);
    final hijri = body['data']['hijri'];

    final day = hijri['day'];
    final month = hijri['month']['en'];
    final year = hijri['year'];

    return '$day $month $year H';
  }
}