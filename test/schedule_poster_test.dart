import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prayer_times_abdelrahman/schedule_poster.dart';

void main() {
  const prayers = [
    PosterPrayer('صلاة الفجر', '🌙', '5:21 ص'),
    PosterPrayer('الشروق', '🌅', '6:41 ص'),
    PosterPrayer('صلاة الظهر', '☀️', '12:51 م'),
    PosterPrayer('صلاة العصر', '🌤️', '4:17 م'),
    PosterPrayer('صلاة المغرب', '🌇', '6:51 م'),
    PosterPrayer('صلاة العشاء', '🌃', '8:05 م'),
  ];

  testWidgets('all twelve themes render the six daily times without overflow', (tester) async {
    expect(posterThemes.length, greaterThan(10));
    for (final theme in posterThemes) {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: SchedulePoster(
        theme: theme, name: 'اسم طويل للتجربة', month: 'سبتمبر',
        date: 'الأربعاء 23 سبتمبر 2026', ayah: 'إن الصلاة كانت على المؤمنين كتابا موقوتا',
        prayers: prayers,
      )))));
      expect(find.text('الشروق'), findsOneWidget);
      expect(find.text('صلاة الظهر'), findsOneWidget);
      expect(find.text('12:51 م'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
