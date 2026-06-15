class HijriHelper {
  static const List<String> _months = [
    'Muharram',
    'Safar',
    'Rabiul Awal',
    'Rabiul Akhir',
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    'Syaban',
    'Ramadhan',
    'Syawal',
    'Zulkaidah',
    'Zulhijjah',
  ];

  static String fromGregorian(DateTime date) {
    final jd = _gregorianToJulianDay(
      date.year,
      date.month,
      date.day,
    );

    final hijri = _julianDayToHijri(jd);

    final day = hijri[2];
    final month = hijri[1];
    final year = hijri[0];

    return '$day ${_months[month - 1]} $year H';
  }

  static int _gregorianToJulianDay(
    int year,
    int month,
    int day,
  ) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    return day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }

  static List<int> _julianDayToHijri(int jd) {
    final l1 = jd - 1948440 + 10632;
    final n = ((l1 - 1) / 10631).floor();

    var l = l1 -
        10631 * n +
        354;

    final j = (((10985 - l) / 5316).floor()) *
            (((50 * l) / 17719).floor()) +
        ((l / 5670).floor()) *
            (((43 * l) / 15238).floor());

    l = l -
        (((30 - j) / 15).floor()) *
            (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) *
            (((15238 * j) / 43).floor()) +
        29;

    final month = ((24 * l) / 709).floor();
    final day = l - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;

    return [year, month, day];
  }
}