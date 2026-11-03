import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  Widget poster(PosterTheme theme, {Key? key}) => RepaintBoundary(
    key: key,
    child: SchedulePoster(
      theme: theme, name: 'اسم طويل للتجربة', month: 'سبتمبر',
      date: 'الأربعاء 23 سبتمبر 2026', ayah: 'إن الصلاة كانت على المؤمنين كتابا موقوتا',
      prayers: prayers,
    ),
  );

  testWidgets('all twelve themes render six times without overflow at large text settings', (tester) async {
    expect(posterThemes.length, greaterThan(10));
    for (final theme in posterThemes) {
      await tester.pumpWidget(MaterialApp(home: MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: Scaffold(body: Center(child: FittedBox(child: poster(theme)))),
      )));
      expect(find.text('الشروق'), findsOneWidget);
      expect(find.text('صلاة الظهر'), findsOneWidget);
      expect(find.text('12:51 م'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('preview boundary exports the full poster at 1440 pixels wide', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: Center(child: FittedBox(child: poster(posterThemes.first, key: key))),
    )));
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    expect(boundary.size, const Size(SchedulePoster.canvasWidth, SchedulePoster.canvasHeight));
    final image = await boundary.toImage(pixelRatio: 3.6);
    expect(image.width, 1440);
    expect(image.height, 2592);
    image.dispose();
  });
}
