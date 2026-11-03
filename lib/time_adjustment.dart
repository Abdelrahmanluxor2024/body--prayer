/// The timetable is stored in summer time. In winter, all entries, including
/// sunrise and Dhuhr, are one hour earlier.
String adjustPrayerTime(String time24, {required bool isSummerTime}) {
  if (isSummerTime) return time24;

  final parts = time24.split(':');
  final hour = (int.parse(parts[0]) + 23) % 24;
  return '${hour.toString().padLeft(2, '0')}:${parts[1]}';
}
