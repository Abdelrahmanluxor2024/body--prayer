import 'dart:math' as math;
import 'package:flutter/material.dart';

class PosterTheme {
  const PosterTheme(this.name, this.top, this.bottom, this.panel, this.gold);
  final String name;
  final Color top, bottom, panel, gold;
}

const posterThemes = <PosterTheme>[
  PosterTheme('الملكي الكحلي', Color(0xff10264b), Color(0xff050c1b), Color(0xff101934), Color(0xffffd66b)),
  PosterTheme('الياقوت الأحمر', Color(0xff681b29), Color(0xff1e0710), Color(0xff300e1c), Color(0xffffce69)),
  PosterTheme('الزمرد', Color(0xff0d4e42), Color(0xff061c1b), Color(0xff0b2926), Color(0xffe7ce80)),
  PosterTheme('البنفسج الإمبراطوري', Color(0xff4a2861), Color(0xff170f29), Color(0xff241631), Color(0xffffd787)),
  PosterTheme('الأزرق السلطاني', Color(0xff174e75), Color(0xff08192d), Color(0xff0b2943), Color(0xffffd87d)),
  PosterTheme('الأسود والذهب', Color(0xff393022), Color(0xff0d0b09), Color(0xff1c1915), Color(0xffffd778)),
  PosterTheme('العقيق', Color(0xff7a382d), Color(0xff26100d), Color(0xff371916), Color(0xffffd6a0)),
  PosterTheme('التركواز', Color(0xff146267), Color(0xff072325), Color(0xff0b3435), Color(0xfff4d890)),
  PosterTheme('الوردي الملكي', Color(0xff6a304b), Color(0xff220e20), Color(0xff35182b), Color(0xffffd4ad)),
  PosterTheme('النيلي', Color(0xff353b79), Color(0xff11132c), Color(0xff1d2143), Color(0xffffd987)),
  PosterTheme('النحاسي', Color(0xff76502c), Color(0xff27190e), Color(0xff382719), Color(0xffffdc98)),
  PosterTheme('الأخضر الزيتوني', Color(0xff4a5732), Color(0xff171e10), Color(0xff26301b), Color(0xffead780)),
];

class PosterPrayer {
  const PosterPrayer(this.name, this.icon, this.time);
  final String name, icon, time;
}

/// A fixed logical canvas, so the preview and the exported PNG match exactly.
class SchedulePoster extends StatelessWidget {
  const SchedulePoster({super.key, required this.theme, required this.name,
    required this.month, required this.date, required this.ayah, required this.prayers});
  final PosterTheme theme;
  final String name, month, date, ayah;
  final List<PosterPrayer> prayers;

  TextStyle _cairo(double size, Color color, {FontWeight weight = FontWeight.w800}) =>
      TextStyle(fontFamily: 'Cairo', fontSize: size, color: color, fontWeight: weight, height: 1.15);

  Widget _fit(String value, TextStyle style) => FittedBox(
    fit: BoxFit.scaleDown, child: Text(value, maxLines: 1, textAlign: TextAlign.center, style: style));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SizedBox(width: 400, height: 680, child: DecoratedBox(
        decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft,
          end: Alignment.bottomRight, colors: [theme.top, theme.bottom, theme.bottom])),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _OrnamentPainter(theme.gold))),
          Positioned.fill(child: Container(margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: theme.gold.withOpacity(.8), width: 1.4),
              borderRadius: BorderRadius.circular(22)))),
          Padding(padding: const EdgeInsets.fromLTRB(22, 17, 22, 15), child: Column(children: [
            Text('✦  ☾  ✦', style: _cairo(25, theme.gold)),
            const SizedBox(height: 2),
            SizedBox(height: 37, child: _fit('مواقيت الصلاة - الأقصر', _cairo(32, theme.gold, weight: FontWeight.w900))),
            SizedBox(height: 35, child: _fit('✦  $name  ✦', _cairo(25, theme.gold))),
            const SizedBox(height: 5),
            Container(padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xff103e36), borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xff78d9b4).withOpacity(.6))),
              child: _fit('محافظة الأقصر - شهر $month', _cairo(16, const Color(0xffb9f2d5)))),
            const SizedBox(height: 8),
            Container(width: double.infinity, height: 39, padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: theme.panel.withOpacity(.9), borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.gold.withOpacity(.35))),
              child: _fit(ayah, const TextStyle(fontFamily: 'Amiri', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
            const SizedBox(height: 8),
            Container(height: 35, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: theme.panel, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.gold.withOpacity(.55))),
              child: _fit(date, _cairo(18, theme.gold))),
            const SizedBox(height: 10),
            ...prayers.map((prayer) => Expanded(child: Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: theme.panel.withOpacity(.92), borderRadius: BorderRadius.circular(13),
                border: Border.all(color: theme.gold.withOpacity(.55))),
              child: Row(children: [
                Text(prayer.icon, style: const TextStyle(fontSize: 27)),
                const SizedBox(width: 8),
                Expanded(flex: 6, child: Align(alignment: Alignment.centerRight,
                  child: _fit(prayer.name, _cairo(29, Colors.white, weight: FontWeight.w900)))),
                const SizedBox(width: 8),
                Expanded(flex: 4, child: Align(alignment: Alignment.centerLeft,
                  child: _fit(prayer.time, _cairo(23, theme.gold, weight: FontWeight.w900)))),
              ])))),
            const SizedBox(height: 2),
            SizedBox(height: 22, child: _fit('✦  نسألكم الدعاء  •  $name  ✦', _cairo(15, theme.gold))),
          ])),
        ]),
      )),
    );
  }
}

class _OrnamentPainter extends CustomPainter {
  _OrnamentPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(.09)..style = PaintingStyle.stroke..strokeWidth = 1;
    for (var y = 30.0; y < size.height; y += 74) {
      for (var x = 12.0; x < size.width; x += 74) {
        canvas.save(); canvas.translate(x, y); canvas.rotate(math.pi / 4);
        canvas.drawRect(const Rect.fromLTWH(-14, -14, 28, 28), paint);
        canvas.rotate(math.pi / 4);
        canvas.drawRect(const Rect.fromLTWH(-14, -14, 28, 28), paint);
        canvas.restore();
      }
    }
  }
  @override
  bool shouldRepaint(covariant _OrnamentPainter oldDelegate) => oldDelegate.color != color;
}
