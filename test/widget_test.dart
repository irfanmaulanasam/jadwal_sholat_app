import 'package:flutter_test/flutter_test.dart';
import 'package:jadwal_sholat_app/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const JadwalSholatApp());
    expect(find.text('Jadwal Sholat'), findsOneWidget);
  });
}