import 'dart:convert';
import 'package:http/http.dart' as http;

class HijriApiService {
  Future<String?> convertMasehiToHijri(DateTime date) async {
    final dateText =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final uri = Uri.parse(
      'https://api.myquran.com/v3/cal/ah/$dateText',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      return 'HTTP ${response.statusCode}: ${response.body}';
    }

    final body = jsonDecode(response.body);

    return body.toString();
  }
}