import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_times_abdelrahman/time_adjustment.dart';

void main() {
  const timetable = {
    'fajr': '06:13',
    'sunrise': '07:41',
    'dhuhr': '13:09',
    'asr': '15:57',
    'maghrib': '18:15',
    'isha': '19:34',
  };

  test('summer keeps every timetable entry unchanged', () {
    for (final time in timetable.values) {
      expect(adjustPrayerTime(time, isSummerTime: true), time);
    }
  });

  test('winter moves every entry including sunrise and Dhuhr back one hour', () {
    const expected = {
      'fajr': '05:13',
      'sunrise': '06:41',
      'dhuhr': '12:09',
      'asr': '14:57',
      'maghrib': '17:15',
      'isha': '18:34',
    };
    for (final entry in timetable.entries) {
      expect(adjustPrayerTime(entry.value, isSummerTime: false), expected[entry.key]);
    }
  });

  test('winter adjustment wraps around midnight', () {
    expect(adjustPrayerTime('00:05', isSummerTime: false), '23:05');
  });
}
