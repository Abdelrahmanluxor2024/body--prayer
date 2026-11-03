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

/// A fixed-size canvas: preview and exported image always use the same layout.
class SchedulePoster extends StatelessWidget {
  const SchedulePoster({super.key, required this.theme, required this.name,
    required this.month, required this.date, required this.ayah, required this.prayers});
  final PosterTheme theme;
  final String name, month, date, ayah;
  final List<PosterPrayer> prayers;

  static const double canvasWidth = 400;
  static const double canvasHeight = 720;

  TextStyle _cairo(double size, Color color, {FontWeight weight = FontWeight.w800}) =>
      TextStyle(fontFamily: 'Cairo', fontSize: size, color: color,
          fontWeight: weight, height: 1.15);

  Widget _fit(String value, TextStyle style, {Alignment alignment = Alignment.center}) =>
      FittedBox(fit: BoxFit.scaleDown, alignment: alignment,
        child: Text(value, maxLines: 1, textAlign: TextAlign.center, style: style));

  Widget _prayerRow(PosterPrayer prayer) {
    return Expanded(child: Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color.lerp(theme.panel, Colors.white, .07)!, theme.panel]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.gold.withOpacity(.55)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(.28), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(width: 4, margin: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(color: theme.gold, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 9),
        SizedBox(width: 36, child: Text(prayer.icon, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 28, height: 1))),
        const SizedBox(width: 7),
        Expanded(flex: 6, child: _fit(prayer.name, _cairo(30, Colors.white, weight: FontWeight.w900),
          alignment: Alignment.centerRight)),
        const SizedBox(width: 8),
        Container(width: 1, height: 32, color: theme.gold.withOpacity(.3)),
        const SizedBox(width: 8),
        Expanded(flex: 4, child: _fit(prayer.time, _cairo(29, theme.gold, weight: FontWeight.w900),
          alignment: Alignment.centerLeft)),
        const SizedBox(width: 12),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    // Accessibility settings on the phone must not distort the exported poster.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Directionality(textDirection: TextDirection.rtl,
        child: SizedBox(width: canvasWidth, height: canvasHeight, child: DecoratedBox(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft,
            end: Alignment.bottomRight, colors: [theme.top, theme.bottom, theme.bottom])),
          child: Stack(children: [
            Positioned.fill(child: CustomPaint(painter: _OrnamentPainter(theme.gold))),
            Positioned.fill(child: Container(margin: const EdgeInsets.all(7),
              decoration: BoxDecoration(border: Border.all(color: theme.gold.withOpacity(.85), width: 1.3),
                borderRadius: BorderRadius.circular(22)))),
            Positioned.fill(child: Container(margin: const EdgeInsets.all(11),
              decoration: BoxDecoration(border: Border.all(color: theme.gold.withOpacity(.20)),
                borderRadius: BorderRadius.circular(19)))),
            Padding(padding: const EdgeInsets.fromLTRB(20, 15, 20, 14), child: Column(children: [
              SizedBox(height: 29, child: _fit('✦   ☾   ✦', _cairo(25, theme.gold))),
              SizedBox(height: 40, child: _fit('مواقيت الصلاة', _cairo(35, theme.gold, weight: FontWeight.w900))),
              SizedBox(height: 30, child: _fit('محافظة الأقصر  •  شهر $month', _cairo(20, Colors.white))),
              const SizedBox(height: 4),
              SizedBox(height: 31, child: _fit('✦  $name  ✦', _cairo(23, theme.gold))),
              const SizedBox(height: 8),
              Container(width: double.infinity, height: 41, padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: Colors.black.withOpacity(.28), borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.gold.withOpacity(.35))),
                child: _fit(ayah, const TextStyle(fontFamily: 'Amiri', fontSize: 22,
                  fontWeight: FontWeight.bold, color: Colors.white, height: 1.1))),
              const SizedBox(height: 8),
              Container(height: 37, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                decoration: BoxDecoration(color: theme.panel, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: theme.gold.withOpacity(.6))),
                child: _fit(date, _cairo(20, theme.gold, weight: FontWeight.w900))),
              const SizedBox(height: 12),
              ...prayers.map(_prayerRow),
              const SizedBox(height: 1),
              SizedBox(height: 22, child: _fit('✦  نسألكم الدعاء  ✦', _cairo(16, theme.gold))),
            ])),
          ]),
        ))),
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
