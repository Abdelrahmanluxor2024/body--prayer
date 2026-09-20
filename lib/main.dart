import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مواقيت الصلاة - الأقصر',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A1A),
        textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFF00A86B),
          surface: Color(0xFF14142B),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// -------------------------------------------------------------
// شاشة البداية الاحترافية (Splash Screen)
// -------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  String _ownerName = 'عبد الرحمن ياسر الاسيوطي';

  @override
  void initState() {
    super.initState();
    _loadOwnerName();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('ownerDisplayName');
      if (mounted && saved != null && saved.trim().isNotEmpty) {
        setState(() {
          _ownerName = saved.trim();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1A), Color(0xFF1A0A2E), Color(0xFF0D1117)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: StarsBackground()),
            Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 140,
                              height: 140,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1E1233),
                              ),
                              child: const Center(
                                child: Text('🕌', style: TextStyle(fontSize: 65)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'مواقيت الصلاة',
                        style: GoogleFonts.amiri(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD700),
                          shadows: [
                            Shadow(
                              color: const Color(0xFFFFD700).withOpacity(0.6),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '⭐ $_ownerName ⭐',
                        style: GoogleFonts.amiri(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFE082),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'مواقيت الصلاة - الأقصر',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 35),
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.8,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 25,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'محافظة الأقصر • جمهورية مصر العربية',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white54,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// قاعدة بيانات المواقيت (قابلة لإضافة جميع شهور السنة)
// -------------------------------------------------------------
class PrayerData {
  // شهر january
  static const List<Map<String, dynamic>> januaryTimes = [
    {"day": 1, "fajr": "06:13", "sunrise": "07:41", "dhuhr": "13:09", "asr": "15:57", "maghrib": "18:15", "isha": "19:34"},
    {"day": 2, "fajr": "06:13", "sunrise": "07:41", "dhuhr": "13:10", "asr": "15:58", "maghrib": "18:16", "isha": "19:35"},
    {"day": 3, "fajr": "06:14", "sunrise": "07:42", "dhuhr": "13:10", "asr": "15:59", "maghrib": "18:17", "isha": "19:36"},
    {"day": 4, "fajr": "06:14", "sunrise": "07:42", "dhuhr": "13:10", "asr": "15:59", "maghrib": "18:18", "isha": "19:37"},
    {"day": 5, "fajr": "06:15", "sunrise": "07:43", "dhuhr": "13:10", "asr": "16:00", "maghrib": "18:19", "isha": "19:38"},
    {"day": 6, "fajr": "06:15", "sunrise": "07:43", "dhuhr": "13:10", "asr": "16:00", "maghrib": "18:19", "isha": "19:38"},
    {"day": 7, "fajr": "06:15", "sunrise": "07:43", "dhuhr": "13:11", "asr": "16:01", "maghrib": "18:20", "isha": "19:39"},
    {"day": 8, "fajr": "06:15", "sunrise": "07:43", "dhuhr": "13:11", "asr": "16:01", "maghrib": "18:20", "isha": "19:39"},
    {"day": 9, "fajr": "06:15", "sunrise": "07:43", "dhuhr": "13:12", "asr": "16:02", "maghrib": "18:21", "isha": "19:40"},
    {"day": 10, "fajr": "06:15", "sunrise": "07:43", "dhuhr": "13:12", "asr": "16:03", "maghrib": "18:22", "isha": "19:41"},
    {"day": 11, "fajr": "06:15", "sunrise": "07:43", "dhuhr": "13:12", "asr": "16:03", "maghrib": "18:23", "isha": "19:41"},
    {"day": 12, "fajr": "06:16", "sunrise": "07:43", "dhuhr": "13:12", "asr": "16:04", "maghrib": "18:24", "isha": "19:42"},
    {"day": 13, "fajr": "06:16", "sunrise": "07:43", "dhuhr": "13:12", "asr": "16:06", "maghrib": "18:24", "isha": "19:43"},
    {"day": 14, "fajr": "06:16", "sunrise": "07:43", "dhuhr": "13:12", "asr": "16:06", "maghrib": "18:24", "isha": "19:43"},
    {"day": 15, "fajr": "06:16", "sunrise": "07:43", "dhuhr": "13:13", "asr": "16:07", "maghrib": "18:25", "isha": "19:44"},
    {"day": 16, "fajr": "06:16", "sunrise": "07:43", "dhuhr": "13:13", "asr": "16:08", "maghrib": "18:26", "isha": "19:45"},
    {"day": 17, "fajr": "06:16", "sunrise": "07:43", "dhuhr": "13:14", "asr": "16:09", "maghrib": "18:27", "isha": "19:46"},
    {"day": 18, "fajr": "06:16", "sunrise": "07:42", "dhuhr": "13:15", "asr": "16:10", "maghrib": "18:28", "isha": "19:47"},
    {"day": 19, "fajr": "06:17", "sunrise": "07:42", "dhuhr": "13:15", "asr": "16:10", "maghrib": "18:29", "isha": "19:47"},
    {"day": 20, "fajr": "06:17", "sunrise": "07:42", "dhuhr": "13:16", "asr": "16:11", "maghrib": "18:30", "isha": "19:48"},
    {"day": 21, "fajr": "06:17", "sunrise": "07:42", "dhuhr": "13:16", "asr": "16:12", "maghrib": "18:31", "isha": "19:48"},
    {"day": 22, "fajr": "06:17", "sunrise": "07:42", "dhuhr": "13:16", "asr": "16:13", "maghrib": "18:32", "isha": "19:48"},
    {"day": 23, "fajr": "06:17", "sunrise": "07:42", "dhuhr": "13:16", "asr": "16:13", "maghrib": "18:32", "isha": "19:49"},
    {"day": 24, "fajr": "06:17", "sunrise": "07:41", "dhuhr": "13:16", "asr": "16:14", "maghrib": "18:33", "isha": "19:50"},
    {"day": 25, "fajr": "06:17", "sunrise": "07:41", "dhuhr": "13:16", "asr": "16:15", "maghrib": "18:34", "isha": "19:51"},
    {"day": 26, "fajr": "06:17", "sunrise": "07:41", "dhuhr": "13:16", "asr": "16:15", "maghrib": "18:35", "isha": "19:52"},
    {"day": 27, "fajr": "06:16", "sunrise": "07:41", "dhuhr": "13:16", "asr": "16:15", "maghrib": "18:35", "isha": "19:53"},
    {"day": 28, "fajr": "06:16", "sunrise": "07:40", "dhuhr": "13:16", "asr": "16:16", "maghrib": "18:36", "isha": "19:53"},
    {"day": 29, "fajr": "06:16", "sunrise": "07:40", "dhuhr": "13:16", "asr": "16:17", "maghrib": "18:37", "isha": "19:54"},
    {"day": 30, "fajr": "06:16", "sunrise": "07:39", "dhuhr": "13:16", "asr": "16:17", "maghrib": "18:37", "isha": "19:54"},
    {"day": 31, "fajr": "06:15", "sunrise": "07:39", "dhuhr": "13:15", "asr": "16:18", "maghrib": "18:38", "isha": "19:55"},
  ];

  // شهر february
  static const List<Map<String, dynamic>> februaryTimes = [
    {"day": 1, "fajr": "06:14", "sunrise": "07:38", "dhuhr": "13:15", "asr": "16:18", "maghrib": "18:38", "isha": "19:55"},
    {"day": 2, "fajr": "06:14", "sunrise": "07:38", "dhuhr": "13:15", "asr": "16:18", "maghrib": "18:39", "isha": "19:56"},
    {"day": 3, "fajr": "06:14", "sunrise": "07:38", "dhuhr": "13:15", "asr": "16:19", "maghrib": "18:40", "isha": "19:57"},
    {"day": 4, "fajr": "06:13", "sunrise": "07:37", "dhuhr": "13:15", "asr": "16:19", "maghrib": "18:40", "isha": "19:57"},
    {"day": 5, "fajr": "06:13", "sunrise": "07:37", "dhuhr": "13:15", "asr": "16:20", "maghrib": "18:41", "isha": "19:58"},
    {"day": 6, "fajr": "06:12", "sunrise": "07:36", "dhuhr": "13:15", "asr": "16:21", "maghrib": "18:42", "isha": "19:59"},
    {"day": 7, "fajr": "06:12", "sunrise": "07:36", "dhuhr": "13:15", "asr": "16:21", "maghrib": "18:43", "isha": "20:00"},
    {"day": 8, "fajr": "06:11", "sunrise": "07:35", "dhuhr": "13:15", "asr": "16:21", "maghrib": "18:43", "isha": "20:00"},
    {"day": 9, "fajr": "06:10", "sunrise": "07:35", "dhuhr": "13:15", "asr": "16:22", "maghrib": "18:44", "isha": "20:00"},
    {"day": 10, "fajr": "06:09", "sunrise": "07:34", "dhuhr": "13:15", "asr": "16:22", "maghrib": "18:44", "isha": "20:00"},
    {"day": 11, "fajr": "06:08", "sunrise": "07:33", "dhuhr": "13:15", "asr": "16:22", "maghrib": "18:45", "isha": "20:01"},
    {"day": 12, "fajr": "06:08", "sunrise": "07:32", "dhuhr": "13:14", "asr": "16:23", "maghrib": "18:46", "isha": "20:02"},
    {"day": 13, "fajr": "06:08", "sunrise": "07:32", "dhuhr": "13:14", "asr": "16:24", "maghrib": "18:47", "isha": "20:03"},
    {"day": 14, "fajr": "06:08", "sunrise": "07:31", "dhuhr": "13:14", "asr": "16:24", "maghrib": "18:48", "isha": "20:04"},
    {"day": 15, "fajr": "06:06", "sunrise": "07:30", "dhuhr": "13:14", "asr": "16:25", "maghrib": "18:48", "isha": "20:05"},
    {"day": 16, "fajr": "06:06", "sunrise": "07:29", "dhuhr": "13:14", "asr": "16:25", "maghrib": "18:49", "isha": "20:05"},
    {"day": 17, "fajr": "06:05", "sunrise": "07:29", "dhuhr": "13:13", "asr": "16:25", "maghrib": "18:49", "isha": "20:05"},
    {"day": 18, "fajr": "06:05", "sunrise": "07:28", "dhuhr": "13:13", "asr": "16:25", "maghrib": "18:50", "isha": "20:06"},
    {"day": 19, "fajr": "06:03", "sunrise": "07:28", "dhuhr": "13:13", "asr": "16:26", "maghrib": "18:50", "isha": "20:06"},
    {"day": 20, "fajr": "06:02", "sunrise": "07:27", "dhuhr": "13:13", "asr": "16:27", "maghrib": "18:50", "isha": "20:06"},
    {"day": 21, "fajr": "06:02", "sunrise": "07:26", "dhuhr": "13:13", "asr": "16:27", "maghrib": "18:51", "isha": "20:07"},
    {"day": 22, "fajr": "06:01", "sunrise": "07:25", "dhuhr": "13:13", "asr": "16:27", "maghrib": "18:52", "isha": "20:08"},
    {"day": 23, "fajr": "06:00", "sunrise": "07:24", "dhuhr": "13:13", "asr": "16:28", "maghrib": "18:52", "isha": "20:08"},
    {"day": 24, "fajr": "06:00", "sunrise": "07:23", "dhuhr": "13:12", "asr": "16:28", "maghrib": "18:53", "isha": "20:09"},
    {"day": 25, "fajr": "05:58", "sunrise": "07:22", "dhuhr": "13:12", "asr": "16:28", "maghrib": "18:53", "isha": "20:09"},
    {"day": 26, "fajr": "05:58", "sunrise": "07:21", "dhuhr": "13:12", "asr": "16:28", "maghrib": "18:54", "isha": "20:10"},
    {"day": 27, "fajr": "05:56", "sunrise": "07:19", "dhuhr": "13:12", "asr": "16:28", "maghrib": "18:55", "isha": "20:10"},
    {"day": 28, "fajr": "05:56", "sunrise": "07:18", "dhuhr": "13:12", "asr": "16:28", "maghrib": "18:55", "isha": "20:10"},
    {"day": 29, "fajr": "05:55", "sunrise": "07:18", "dhuhr": "13:12", "asr": "16:28", "maghrib": "18:55", "isha": "20:10"},
  ];

  // شهر march
  static const List<Map<String, dynamic>> marchTimes = [
    {"day": 1, "fajr": "05:55", "sunrise": "07:18", "dhuhr": "13:12", "asr": "16:29", "maghrib": "18:56", "isha": "20:11"},
    {"day": 2, "fajr": "05:54", "sunrise": "07:16", "dhuhr": "13:11", "asr": "16:29", "maghrib": "18:56", "isha": "20:11"},
    {"day": 3, "fajr": "05:53", "sunrise": "07:16", "dhuhr": "13:11", "asr": "16:29", "maghrib": "18:57", "isha": "20:12"},
    {"day": 4, "fajr": "05:52", "sunrise": "07:14", "dhuhr": "13:11", "asr": "16:29", "maghrib": "18:57", "isha": "20:12"},
    {"day": 5, "fajr": "05:51", "sunrise": "07:13", "dhuhr": "13:11", "asr": "16:30", "maghrib": "18:58", "isha": "20:13"},
    {"day": 6, "fajr": "05:50", "sunrise": "07:12", "dhuhr": "13:10", "asr": "16:30", "maghrib": "18:58", "isha": "20:13"},
    {"day": 7, "fajr": "05:49", "sunrise": "07:11", "dhuhr": "13:10", "asr": "16:30", "maghrib": "18:59", "isha": "20:14"},
    {"day": 8, "fajr": "05:49", "sunrise": "07:11", "dhuhr": "13:10", "asr": "16:31", "maghrib": "19:00", "isha": "20:15"},
    {"day": 9, "fajr": "05:47", "sunrise": "07:10", "dhuhr": "13:09", "asr": "16:31", "maghrib": "19:00", "isha": "20:15"},
    {"day": 10, "fajr": "05:46", "sunrise": "07:09", "dhuhr": "13:08", "asr": "16:31", "maghrib": "19:01", "isha": "20:15"},
    {"day": 11, "fajr": "05:45", "sunrise": "07:07", "dhuhr": "13:08", "asr": "16:31", "maghrib": "19:01", "isha": "20:15"},
    {"day": 12, "fajr": "05:44", "sunrise": "07:06", "dhuhr": "13:08", "asr": "16:31", "maghrib": "19:01", "isha": "20:15"},
    {"day": 13, "fajr": "05:42", "sunrise": "07:05", "dhuhr": "13:08", "asr": "16:31", "maghrib": "19:01", "isha": "20:15"},
    {"day": 14, "fajr": "05:41", "sunrise": "07:04", "dhuhr": "13:07", "asr": "16:31", "maghrib": "19:02", "isha": "20:16"},
    {"day": 15, "fajr": "05:40", "sunrise": "07:03", "dhuhr": "13:07", "asr": "16:31", "maghrib": "19:03", "isha": "20:17"},
    {"day": 16, "fajr": "05:39", "sunrise": "07:02", "dhuhr": "13:07", "asr": "16:31", "maghrib": "19:03", "isha": "20:17"},
    {"day": 17, "fajr": "05:37", "sunrise": "07:01", "dhuhr": "13:06", "asr": "16:31", "maghrib": "19:03", "isha": "20:17"},
    {"day": 18, "fajr": "05:37", "sunrise": "07:00", "dhuhr": "13:06", "asr": "16:32", "maghrib": "19:04", "isha": "20:18"},
    {"day": 19, "fajr": "05:35", "sunrise": "06:59", "dhuhr": "13:05", "asr": "16:32", "maghrib": "19:04", "isha": "20:18"},
    {"day": 20, "fajr": "05:34", "sunrise": "06:58", "dhuhr": "13:05", "asr": "16:32", "maghrib": "19:05", "isha": "20:19"},
    {"day": 21, "fajr": "05:32", "sunrise": "06:56", "dhuhr": "13:04", "asr": "16:32", "maghrib": "19:05", "isha": "20:19"},
    {"day": 22, "fajr": "05:32", "sunrise": "06:55", "dhuhr": "13:04", "asr": "16:32", "maghrib": "19:06", "isha": "20:20"},
    {"day": 23, "fajr": "05:30", "sunrise": "06:54", "dhuhr": "13:04", "asr": "16:32", "maghrib": "19:06", "isha": "20:20"},
    {"day": 24, "fajr": "05:29", "sunrise": "06:53", "dhuhr": "13:03", "asr": "16:32", "maghrib": "19:07", "isha": "20:21"},
    {"day": 25, "fajr": "05:29", "sunrise": "06:52", "dhuhr": "13:03", "asr": "16:32", "maghrib": "19:08", "isha": "20:22"},
    {"day": 26, "fajr": "05:27", "sunrise": "06:50", "dhuhr": "13:03", "asr": "16:32", "maghrib": "19:08", "isha": "20:22"},
    {"day": 27, "fajr": "05:27", "sunrise": "06:49", "dhuhr": "13:03", "asr": "16:32", "maghrib": "19:09", "isha": "20:23"},
    {"day": 28, "fajr": "05:26", "sunrise": "06:48", "dhuhr": "13:02", "asr": "16:32", "maghrib": "19:10", "isha": "20:24"},
    {"day": 29, "fajr": "05:24", "sunrise": "06:46", "dhuhr": "13:02", "asr": "16:32", "maghrib": "19:10", "isha": "20:24"},
    {"day": 30, "fajr": "05:23", "sunrise": "06:45", "dhuhr": "13:01", "asr": "16:31", "maghrib": "19:10", "isha": "20:24"},
    {"day": 31, "fajr": "05:21", "sunrise": "06:44", "dhuhr": "13:00", "asr": "16:31", "maghrib": "19:10", "isha": "20:24"},
  ];

  // شهر april
  static const List<Map<String, dynamic>> aprilTimes = [
    {"day": 1, "fajr": "05:20", "sunrise": "06:44", "dhuhr": "13:00", "asr": "16:31", "maghrib": "19:11", "isha": "20:25"},
    {"day": 2, "fajr": "05:19", "sunrise": "06:43", "dhuhr": "13:00", "asr": "16:31", "maghrib": "19:11", "isha": "20:25"},
    {"day": 3, "fajr": "05:17", "sunrise": "06:41", "dhuhr": "12:59", "asr": "16:31", "maghrib": "19:11", "isha": "20:25"},
    {"day": 4, "fajr": "05:16", "sunrise": "06:41", "dhuhr": "12:59", "asr": "16:31", "maghrib": "19:12", "isha": "20:26"},
    {"day": 5, "fajr": "05:14", "sunrise": "06:40", "dhuhr": "12:59", "asr": "16:31", "maghrib": "19:12", "isha": "20:26"},
    {"day": 6, "fajr": "05:13", "sunrise": "06:38", "dhuhr": "12:58", "asr": "16:30", "maghrib": "19:12", "isha": "20:26"},
    {"day": 7, "fajr": "05:12", "sunrise": "06:37", "dhuhr": "12:58", "asr": "16:30", "maghrib": "19:13", "isha": "20:28"},
    {"day": 8, "fajr": "05:10", "sunrise": "06:36", "dhuhr": "12:58", "asr": "16:30", "maghrib": "19:13", "isha": "20:28"},
    {"day": 9, "fajr": "05:10", "sunrise": "06:36", "dhuhr": "12:58", "asr": "16:30", "maghrib": "19:14", "isha": "20:29"},
    {"day": 10, "fajr": "05:08", "sunrise": "06:34", "dhuhr": "12:57", "asr": "16:30", "maghrib": "19:14", "isha": "20:29"},
    {"day": 11, "fajr": "05:07", "sunrise": "06:33", "dhuhr": "12:57", "asr": "16:30", "maghrib": "19:15", "isha": "20:30"},
    {"day": 12, "fajr": "05:06", "sunrise": "06:32", "dhuhr": "12:56", "asr": "16:30", "maghrib": "19:15", "isha": "20:30"},
    {"day": 13, "fajr": "05:04", "sunrise": "06:31", "dhuhr": "12:56", "asr": "16:30", "maghrib": "19:15", "isha": "20:30"},
    {"day": 14, "fajr": "05:03", "sunrise": "06:30", "dhuhr": "12:55", "asr": "16:30", "maghrib": "19:16", "isha": "20:31"},
    {"day": 15, "fajr": "05:01", "sunrise": "06:29", "dhuhr": "12:55", "asr": "16:30", "maghrib": "19:16", "isha": "20:31"},
    {"day": 16, "fajr": "05:01", "sunrise": "06:28", "dhuhr": "12:55", "asr": "16:30", "maghrib": "19:17", "isha": "20:32"},
    {"day": 17, "fajr": "05:00", "sunrise": "06:28", "dhuhr": "12:55", "asr": "16:30", "maghrib": "19:18", "isha": "20:34"},
    {"day": 18, "fajr": "04:59", "sunrise": "06:26", "dhuhr": "12:54", "asr": "16:30", "maghrib": "19:18", "isha": "20:34"},
    {"day": 19, "fajr": "04:58", "sunrise": "06:25", "dhuhr": "12:54", "asr": "16:30", "maghrib": "19:19", "isha": "20:35"},
    {"day": 20, "fajr": "04:57", "sunrise": "06:25", "dhuhr": "12:54", "asr": "16:30", "maghrib": "19:20", "isha": "20:36"},
    {"day": 21, "fajr": "04:55", "sunrise": "06:23", "dhuhr": "12:54", "asr": "16:30", "maghrib": "19:20", "isha": "20:36"},
    {"day": 22, "fajr": "04:55", "sunrise": "06:22", "dhuhr": "12:54", "asr": "16:30", "maghrib": "19:21", "isha": "20:38"},
    {"day": 23, "fajr": "04:53", "sunrise": "06:22", "dhuhr": "12:53", "asr": "16:29", "maghrib": "19:21", "isha": "20:38"},
    {"day": 24, "fajr": "04:51", "sunrise": "06:20", "dhuhr": "12:52", "asr": "16:29", "maghrib": "19:21", "isha": "20:38"},
    {"day": 25, "fajr": "04:50", "sunrise": "06:20", "dhuhr": "12:52", "asr": "16:28", "maghrib": "19:22", "isha": "20:39"},
    {"day": 26, "fajr": "04:49", "sunrise": "06:19", "dhuhr": "12:52", "asr": "16:28", "maghrib": "19:22", "isha": "20:39"},
    {"day": 27, "fajr": "04:48", "sunrise": "06:18", "dhuhr": "12:52", "asr": "16:28", "maghrib": "19:23", "isha": "20:39"},
    {"day": 28, "fajr": "04:46", "sunrise": "06:17", "dhuhr": "12:52", "asr": "16:28", "maghrib": "19:23", "isha": "20:41"},
    {"day": 29, "fajr": "04:45", "sunrise": "06:16", "dhuhr": "12:52", "asr": "16:28", "maghrib": "19:24", "isha": "20:42"},
    {"day": 30, "fajr": "04:44", "sunrise": "06:15", "dhuhr": "12:52", "asr": "16:27", "maghrib": "19:24", "isha": "20:42"},
  ];

  // شهر may
  static const List<Map<String, dynamic>> mayTimes = [
    {"day": 1, "fajr": "04:43", "sunrise": "06:15", "dhuhr": "12:52", "asr": "16:27", "maghrib": "19:25", "isha": "20:43"},
    {"day": 2, "fajr": "04:42", "sunrise": "06:14", "dhuhr": "12:52", "asr": "16:27", "maghrib": "19:25", "isha": "20:43"},
    {"day": 3, "fajr": "04:41", "sunrise": "06:13", "dhuhr": "12:52", "asr": "16:27", "maghrib": "19:26", "isha": "20:45"},
    {"day": 4, "fajr": "04:40", "sunrise": "06:13", "dhuhr": "12:52", "asr": "16:26", "maghrib": "19:26", "isha": "20:45"},
    {"day": 5, "fajr": "04:38", "sunrise": "06:11", "dhuhr": "12:52", "asr": "16:25", "maghrib": "19:27", "isha": "20:46"},
    {"day": 6, "fajr": "04:38", "sunrise": "06:11", "dhuhr": "12:52", "asr": "16:25", "maghrib": "19:27", "isha": "20:46"},
    {"day": 7, "fajr": "04:37", "sunrise": "06:10", "dhuhr": "12:51", "asr": "16:25", "maghrib": "19:27", "isha": "20:46"},
    {"day": 8, "fajr": "04:36", "sunrise": "06:10", "dhuhr": "12:51", "asr": "16:25", "maghrib": "19:28", "isha": "20:48"},
    {"day": 9, "fajr": "04:35", "sunrise": "06:08", "dhuhr": "12:51", "asr": "16:25", "maghrib": "19:29", "isha": "20:50"},
    {"day": 10, "fajr": "04:34", "sunrise": "06:08", "dhuhr": "12:51", "asr": "16:25", "maghrib": "19:30", "isha": "20:51"},
    {"day": 11, "fajr": "04:34", "sunrise": "06:08", "dhuhr": "12:51", "asr": "16:25", "maghrib": "19:30", "isha": "20:52"},
    {"day": 12, "fajr": "04:33", "sunrise": "06:07", "dhuhr": "12:51", "asr": "16:25", "maghrib": "19:30", "isha": "20:52"},
    {"day": 13, "fajr": "04:32", "sunrise": "06:07", "dhuhr": "12:50", "asr": "16:25", "maghrib": "19:31", "isha": "20:52"},
    {"day": 14, "fajr": "04:31", "sunrise": "06:06", "dhuhr": "12:51", "asr": "16:25", "maghrib": "19:31", "isha": "20:54"},
    {"day": 15, "fajr": "04:29", "sunrise": "06:05", "dhuhr": "12:51", "asr": "16:24", "maghrib": "19:31", "isha": "20:54"},
    {"day": 16, "fajr": "04:29", "sunrise": "06:05", "dhuhr": "12:51", "asr": "16:24", "maghrib": "19:32", "isha": "20:55"},
    {"day": 17, "fajr": "04:28", "sunrise": "06:04", "dhuhr": "12:51", "asr": "16:24", "maghrib": "19:32", "isha": "20:55"},
    {"day": 18, "fajr": "04:27", "sunrise": "06:04", "dhuhr": "12:51", "asr": "16:23", "maghrib": "19:32", "isha": "20:56"},
    {"day": 19, "fajr": "04:27", "sunrise": "06:03", "dhuhr": "12:51", "asr": "16:23", "maghrib": "19:33", "isha": "20:57"},
    {"day": 20, "fajr": "04:26", "sunrise": "06:03", "dhuhr": "12:51", "asr": "16:22", "maghrib": "19:33", "isha": "20:57"},
    {"day": 21, "fajr": "04:25", "sunrise": "06:02", "dhuhr": "12:51", "asr": "16:22", "maghrib": "19:33", "isha": "20:57"},
    {"day": 22, "fajr": "04:25", "sunrise": "06:02", "dhuhr": "12:51", "asr": "16:22", "maghrib": "19:34", "isha": "20:58"},
    {"day": 23, "fajr": "04:24", "sunrise": "06:02", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:34", "isha": "20:59"},
    {"day": 24, "fajr": "04:23", "sunrise": "06:01", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:34", "isha": "20:59"},
    {"day": 25, "fajr": "04:22", "sunrise": "06:01", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:35", "isha": "21:00"},
    {"day": 26, "fajr": "04:21", "sunrise": "06:01", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:35", "isha": "21:00"},
    {"day": 27, "fajr": "04:21", "sunrise": "06:01", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:36", "isha": "21:01"},
    {"day": 28, "fajr": "04:20", "sunrise": "06:00", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:36", "isha": "21:01"},
    {"day": 29, "fajr": "04:20", "sunrise": "06:00", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:37", "isha": "21:02"},
    {"day": 30, "fajr": "04:20", "sunrise": "06:00", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:38", "isha": "21:03"},
    {"day": 31, "fajr": "04:19", "sunrise": "05:59", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:38", "isha": "21:04"},
  ];

  // شهر june
  static const List<Map<String, dynamic>> juneTimes = [
    {"day": 1, "fajr": "04:19", "sunrise": "05:59", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:38", "isha": "21:05"},
    {"day": 2, "fajr": "04:18", "sunrise": "05:59", "dhuhr": "12:52", "asr": "16:21", "maghrib": "19:39", "isha": "21:05"},
    {"day": 3, "fajr": "04:18", "sunrise": "05:59", "dhuhr": "12:52", "asr": "16:22", "maghrib": "19:39", "isha": "21:05"},
    {"day": 4, "fajr": "04:18", "sunrise": "05:59", "dhuhr": "12:52", "asr": "16:22", "maghrib": "19:40", "isha": "21:05"},
    {"day": 5, "fajr": "04:18", "sunrise": "05:59", "dhuhr": "12:52", "asr": "16:22", "maghrib": "19:40", "isha": "21:06"},
    {"day": 6, "fajr": "04:18", "sunrise": "05:59", "dhuhr": "12:52", "asr": "16:22", "maghrib": "19:40", "isha": "21:07"},
    {"day": 7, "fajr": "04:18", "sunrise": "05:59", "dhuhr": "12:53", "asr": "16:23", "maghrib": "19:41", "isha": "21:08"},
    {"day": 8, "fajr": "04:18", "sunrise": "05:58", "dhuhr": "12:53", "asr": "16:23", "maghrib": "19:41", "isha": "21:08"},
    {"day": 9, "fajr": "04:18", "sunrise": "05:58", "dhuhr": "12:53", "asr": "16:23", "maghrib": "19:42", "isha": "21:09"},
    {"day": 10, "fajr": "04:18", "sunrise": "05:58", "dhuhr": "12:53", "asr": "16:23", "maghrib": "19:42", "isha": "21:09"},
    {"day": 11, "fajr": "04:18", "sunrise": "05:58", "dhuhr": "12:53", "asr": "16:23", "maghrib": "19:42", "isha": "21:09"},
    {"day": 12, "fajr": "04:18", "sunrise": "05:58", "dhuhr": "12:54", "asr": "16:23", "maghrib": "19:43", "isha": "21:10"},
    {"day": 13, "fajr": "04:18", "sunrise": "05:58", "dhuhr": "12:54", "asr": "16:23", "maghrib": "19:43", "isha": "21:10"},
    {"day": 14, "fajr": "04:19", "sunrise": "05:58", "dhuhr": "12:54", "asr": "16:24", "maghrib": "19:44", "isha": "21:11"},
    {"day": 15, "fajr": "04:19", "sunrise": "05:58", "dhuhr": "12:54", "asr": "16:24", "maghrib": "19:44", "isha": "21:11"},
    {"day": 16, "fajr": "04:19", "sunrise": "05:58", "dhuhr": "12:54", "asr": "16:24", "maghrib": "19:44", "isha": "21:12"},
    {"day": 17, "fajr": "04:20", "sunrise": "05:59", "dhuhr": "12:55", "asr": "16:24", "maghrib": "19:45", "isha": "21:13"},
    {"day": 18, "fajr": "04:20", "sunrise": "05:59", "dhuhr": "12:55", "asr": "16:24", "maghrib": "19:45", "isha": "21:13"},
    {"day": 19, "fajr": "04:20", "sunrise": "05:59", "dhuhr": "12:55", "asr": "16:24", "maghrib": "19:45", "isha": "21:13"},
    {"day": 20, "fajr": "04:20", "sunrise": "05:59", "dhuhr": "12:55", "asr": "16:24", "maghrib": "19:45", "isha": "21:13"},
    {"day": 21, "fajr": "04:20", "sunrise": "05:59", "dhuhr": "12:55", "asr": "16:24", "maghrib": "19:45", "isha": "21:13"},
    {"day": 22, "fajr": "04:21", "sunrise": "06:00", "dhuhr": "12:56", "asr": "16:25", "maghrib": "19:46", "isha": "21:14"},
    {"day": 23, "fajr": "04:21", "sunrise": "06:00", "dhuhr": "12:56", "asr": "16:25", "maghrib": "19:46", "isha": "21:14"},
    {"day": 24, "fajr": "04:21", "sunrise": "06:00", "dhuhr": "12:56", "asr": "16:25", "maghrib": "19:46", "isha": "21:14"},
    {"day": 25, "fajr": "04:21", "sunrise": "06:00", "dhuhr": "12:56", "asr": "16:25", "maghrib": "19:46", "isha": "21:14"},
    {"day": 26, "fajr": "04:21", "sunrise": "06:00", "dhuhr": "12:56", "asr": "16:26", "maghrib": "19:46", "isha": "21:15"},
    {"day": 27, "fajr": "04:23", "sunrise": "06:01", "dhuhr": "12:57", "asr": "16:27", "maghrib": "19:47", "isha": "21:15"},
    {"day": 28, "fajr": "04:23", "sunrise": "06:01", "dhuhr": "12:57", "asr": "16:27", "maghrib": "19:47", "isha": "21:15"},
    {"day": 29, "fajr": "04:23", "sunrise": "06:01", "dhuhr": "12:57", "asr": "16:27", "maghrib": "19:47", "isha": "21:15"},
    {"day": 30, "fajr": "04:23", "sunrise": "06:02", "dhuhr": "12:57", "asr": "16:27", "maghrib": "19:47", "isha": "21:15"},
  ];

  // شهر july
  static const List<Map<String, dynamic>> julyTimes = [
    {"day": 1, "fajr": "04:23", "sunrise": "06:02", "dhuhr": "12:58", "asr": "16:27", "maghrib": "19:47", "isha": "21:15"},
    {"day": 2, "fajr": "04:24", "sunrise": "06:03", "dhuhr": "12:58", "asr": "16:28", "maghrib": "19:47", "isha": "21:15"},
    {"day": 3, "fajr": "04:25", "sunrise": "06:03", "dhuhr": "12:58", "asr": "16:28", "maghrib": "19:47", "isha": "21:15"},
    {"day": 4, "fajr": "04:26", "sunrise": "06:04", "dhuhr": "12:58", "asr": "16:28", "maghrib": "19:47", "isha": "21:15"},
    {"day": 5, "fajr": "04:26", "sunrise": "06:04", "dhuhr": "12:58", "asr": "16:28", "maghrib": "19:47", "isha": "21:14"},
    {"day": 6, "fajr": "04:26", "sunrise": "06:04", "dhuhr": "12:58", "asr": "16:29", "maghrib": "19:47", "isha": "21:14"},
    {"day": 7, "fajr": "04:27", "sunrise": "06:04", "dhuhr": "12:59", "asr": "16:29", "maghrib": "19:47", "isha": "21:14"},
    {"day": 8, "fajr": "04:28", "sunrise": "06:04", "dhuhr": "13:00", "asr": "16:29", "maghrib": "19:47", "isha": "21:14"},
    {"day": 9, "fajr": "04:29", "sunrise": "06:05", "dhuhr": "13:00", "asr": "16:29", "maghrib": "19:47", "isha": "21:14"},
    {"day": 10, "fajr": "04:30", "sunrise": "06:05", "dhuhr": "13:00", "asr": "16:29", "maghrib": "19:47", "isha": "21:14"},
    {"day": 11, "fajr": "04:30", "sunrise": "06:05", "dhuhr": "13:00", "asr": "16:29", "maghrib": "19:46", "isha": "21:14"},
    {"day": 12, "fajr": "04:30", "sunrise": "06:06", "dhuhr": "13:00", "asr": "16:29", "maghrib": "19:46", "isha": "21:13"},
    {"day": 13, "fajr": "04:30", "sunrise": "06:06", "dhuhr": "13:00", "asr": "16:30", "maghrib": "19:46", "isha": "21:13"},
    {"day": 14, "fajr": "04:31", "sunrise": "06:07", "dhuhr": "13:01", "asr": "16:30", "maghrib": "19:46", "isha": "21:13"},
    {"day": 15, "fajr": "04:32", "sunrise": "06:08", "dhuhr": "13:01", "asr": "16:31", "maghrib": "19:46", "isha": "21:13"},
    {"day": 16, "fajr": "04:33", "sunrise": "06:08", "dhuhr": "13:01", "asr": "16:31", "maghrib": "19:46", "isha": "21:12"},
    {"day": 17, "fajr": "04:34", "sunrise": "06:09", "dhuhr": "13:01", "asr": "16:31", "maghrib": "19:46", "isha": "21:12"},
    {"day": 18, "fajr": "04:34", "sunrise": "06:09", "dhuhr": "13:01", "asr": "16:31", "maghrib": "19:45", "isha": "21:11"},
    {"day": 19, "fajr": "04:35", "sunrise": "06:10", "dhuhr": "13:01", "asr": "16:31", "maghrib": "19:45", "isha": "21:11"},
    {"day": 20, "fajr": "04:35", "sunrise": "06:10", "dhuhr": "13:01", "asr": "16:31", "maghrib": "19:44", "isha": "21:10"},
    {"day": 21, "fajr": "04:36", "sunrise": "06:10", "dhuhr": "13:01", "asr": "16:31", "maghrib": "19:44", "isha": "21:10"},
    {"day": 22, "fajr": "04:37", "sunrise": "06:11", "dhuhr": "13:01", "asr": "16:32", "maghrib": "19:44", "isha": "21:10"},
    {"day": 23, "fajr": "04:38", "sunrise": "06:12", "dhuhr": "13:01", "asr": "16:32", "maghrib": "19:44", "isha": "21:10"},
    {"day": 24, "fajr": "04:38", "sunrise": "06:12", "dhuhr": "13:01", "asr": "16:33", "maghrib": "19:43", "isha": "21:09"},
    {"day": 25, "fajr": "04:39", "sunrise": "06:13", "dhuhr": "13:01", "asr": "16:33", "maghrib": "19:43", "isha": "21:08"},
    {"day": 26, "fajr": "04:40", "sunrise": "06:14", "dhuhr": "13:01", "asr": "16:34", "maghrib": "19:43", "isha": "21:08"},
    {"day": 27, "fajr": "04:41", "sunrise": "06:14", "dhuhr": "13:01", "asr": "16:34", "maghrib": "19:43", "isha": "21:08"},
    {"day": 28, "fajr": "04:42", "sunrise": "06:15", "dhuhr": "13:01", "asr": "16:35", "maghrib": "19:43", "isha": "21:08"},
    {"day": 29, "fajr": "04:42", "sunrise": "06:15", "dhuhr": "13:01", "asr": "16:35", "maghrib": "19:42", "isha": "21:07"},
    {"day": 30, "fajr": "04:43", "sunrise": "06:16", "dhuhr": "13:01", "asr": "16:35", "maghrib": "19:42", "isha": "21:07"},
    {"day": 31, "fajr": "04:43", "sunrise": "06:17", "dhuhr": "13:01", "asr": "16:35", "maghrib": "19:41", "isha": "21:05"},
  ];

  // شهر august
  static const List<Map<String, dynamic>> augustTimes = [
    {"day": 1, "fajr": "04:44", "sunrise": "06:17", "dhuhr": "13:01", "asr": "16:36", "maghrib": "19:41", "isha": "21:05"},
    {"day": 2, "fajr": "04:45", "sunrise": "06:18", "dhuhr": "13:01", "asr": "16:36", "maghrib": "19:41", "isha": "21:05"},
    {"day": 3, "fajr": "04:46", "sunrise": "06:18", "dhuhr": "13:01", "asr": "16:36", "maghrib": "19:40", "isha": "21:03"},
    {"day": 4, "fajr": "04:47", "sunrise": "06:18", "dhuhr": "13:01", "asr": "16:36", "maghrib": "19:39", "isha": "21:02"},
    {"day": 5, "fajr": "04:48", "sunrise": "06:19", "dhuhr": "13:01", "asr": "16:36", "maghrib": "19:39", "isha": "21:02"},
    {"day": 6, "fajr": "04:48", "sunrise": "06:20", "dhuhr": "13:01", "asr": "16:36", "maghrib": "19:38", "isha": "21:02"},
    {"day": 7, "fajr": "04:50", "sunrise": "06:20", "dhuhr": "13:00", "asr": "16:36", "maghrib": "19:38", "isha": "21:00"},
    {"day": 8, "fajr": "04:51", "sunrise": "06:21", "dhuhr": "13:00", "asr": "16:36", "maghrib": "19:37", "isha": "20:59"},
    {"day": 9, "fajr": "04:52", "sunrise": "06:22", "dhuhr": "13:00", "asr": "16:36", "maghrib": "19:37", "isha": "20:59"},
    {"day": 10, "fajr": "04:53", "sunrise": "06:22", "dhuhr": "13:00", "asr": "16:36", "maghrib": "19:36", "isha": "20:58"},
    {"day": 11, "fajr": "04:54", "sunrise": "06:23", "dhuhr": "13:00", "asr": "16:36", "maghrib": "19:35", "isha": "20:57"},
    {"day": 12, "fajr": "04:54", "sunrise": "06:23", "dhuhr": "13:00", "asr": "16:36", "maghrib": "19:34", "isha": "20:56"},
    {"day": 13, "fajr": "04:54", "sunrise": "06:24", "dhuhr": "13:00", "asr": "16:36", "maghrib": "19:33", "isha": "20:54"},
    {"day": 14, "fajr": "04:55", "sunrise": "06:24", "dhuhr": "13:00", "asr": "16:35", "maghrib": "19:32", "isha": "20:53"},
    {"day": 15, "fajr": "04:56", "sunrise": "06:24", "dhuhr": "13:00", "asr": "16:35", "maghrib": "19:31", "isha": "20:52"},
    {"day": 16, "fajr": "04:56", "sunrise": "06:25", "dhuhr": "13:00", "asr": "16:35", "maghrib": "19:30", "isha": "20:51"},
    {"day": 17, "fajr": "04:58", "sunrise": "06:25", "dhuhr": "13:00", "asr": "16:35", "maghrib": "19:30", "isha": "20:51"},
    {"day": 18, "fajr": "04:59", "sunrise": "06:25", "dhuhr": "13:00", "asr": "16:35", "maghrib": "19:29", "isha": "20:49"},
    {"day": 19, "fajr": "05:00", "sunrise": "06:26", "dhuhr": "13:00", "asr": "16:35", "maghrib": "19:29", "isha": "20:49"},
    {"day": 20, "fajr": "05:01", "sunrise": "06:26", "dhuhr": "12:59", "asr": "16:35", "maghrib": "19:28", "isha": "20:48"},
    {"day": 21, "fajr": "05:02", "sunrise": "06:27", "dhuhr": "12:59", "asr": "16:34", "maghrib": "19:27", "isha": "20:47"},
    {"day": 22, "fajr": "05:02", "sunrise": "06:27", "dhuhr": "12:59", "asr": "16:34", "maghrib": "19:26", "isha": "20:46"},
    {"day": 23, "fajr": "05:03", "sunrise": "06:28", "dhuhr": "12:59", "asr": "16:34", "maghrib": "19:25", "isha": "20:44"},
    {"day": 24, "fajr": "05:04", "sunrise": "06:29", "dhuhr": "12:58", "asr": "16:33", "maghrib": "19:24", "isha": "20:43"},
    {"day": 25, "fajr": "05:04", "sunrise": "06:29", "dhuhr": "12:58", "asr": "16:33", "maghrib": "19:23", "isha": "20:42"},
    {"day": 26, "fajr": "05:05", "sunrise": "06:29", "dhuhr": "12:58", "asr": "16:33", "maghrib": "19:22", "isha": "20:41"},
    {"day": 27, "fajr": "05:05", "sunrise": "06:30", "dhuhr": "12:57", "asr": "16:32", "maghrib": "19:21", "isha": "20:40"},
    {"day": 28, "fajr": "05:06", "sunrise": "06:30", "dhuhr": "12:57", "asr": "16:32", "maghrib": "19:20", "isha": "20:38"},
    {"day": 29, "fajr": "05:07", "sunrise": "06:31", "dhuhr": "12:57", "asr": "16:32", "maghrib": "19:19", "isha": "20:37"},
    {"day": 30, "fajr": "05:08", "sunrise": "06:31", "dhuhr": "12:57", "asr": "16:32", "maghrib": "19:18", "isha": "20:36"},
    {"day": 31, "fajr": "05:08", "sunrise": "06:31", "dhuhr": "12:56", "asr": "16:31", "maghrib": "19:16", "isha": "20:34"},
  ];

  // شهر سبتمبر (الشهر 9) - محافظة الأقصر (توقيت صيفي معتمد)
  static const List<Map<String, dynamic>> septemberTimes = [
    {"day": 1, "fajr": "05:08", "sunrise": "06:32", "dhuhr": "12:56", "asr": "16:30", "maghrib": "19:15", "isha": "20:33"},
    {"day": 2, "fajr": "05:08", "sunrise": "06:32", "dhuhr": "12:56", "asr": "16:29", "maghrib": "19:14", "isha": "20:31"},
    {"day": 3, "fajr": "05:09", "sunrise": "06:33", "dhuhr": "12:56", "asr": "16:29", "maghrib": "19:13", "isha": "20:30"},
    {"day": 4, "fajr": "05:10", "sunrise": "06:33", "dhuhr": "12:56", "asr": "16:28", "maghrib": "19:12", "isha": "20:29"},
    {"day": 5, "fajr": "05:11", "sunrise": "06:34", "dhuhr": "12:56", "asr": "16:27", "maghrib": "19:11", "isha": "20:28"},
    {"day": 6, "fajr": "05:12", "sunrise": "06:34", "dhuhr": "12:55", "asr": "16:27", "maghrib": "19:10", "isha": "20:27"},
    {"day": 7, "fajr": "05:13", "sunrise": "06:35", "dhuhr": "12:55", "asr": "16:27", "maghrib": "19:09", "isha": "20:25"},
    {"day": 8, "fajr": "05:14", "sunrise": "06:35", "dhuhr": "12:55", "asr": "16:26", "maghrib": "19:08", "isha": "20:24"},
    {"day": 9, "fajr": "05:14", "sunrise": "06:36", "dhuhr": "12:55", "asr": "16:26", "maghrib": "19:07", "isha": "20:23"},
    {"day": 10, "fajr": "05:15", "sunrise": "06:37", "dhuhr": "12:54", "asr": "16:25", "maghrib": "19:06", "isha": "20:22"},
    {"day": 11, "fajr": "05:16", "sunrise": "06:37", "dhuhr": "12:54", "asr": "16:25", "maghrib": "19:05", "isha": "20:22"},
    {"day": 12, "fajr": "05:17", "sunrise": "06:37", "dhuhr": "12:54", "asr": "16:25", "maghrib": "19:05", "isha": "20:20"},
    {"day": 13, "fajr": "05:19", "sunrise": "06:37", "dhuhr": "12:54", "asr": "16:25", "maghrib": "19:04", "isha": "20:19"},
    {"day": 14, "fajr": "05:19", "sunrise": "06:37", "dhuhr": "12:53", "asr": "16:23", "maghrib": "19:02", "isha": "20:17"},
    {"day": 15, "fajr": "05:19", "sunrise": "06:38", "dhuhr": "12:53", "asr": "16:22", "maghrib": "19:01", "isha": "20:16"},
    {"day": 16, "fajr": "05:20", "sunrise": "06:38", "dhuhr": "12:53", "asr": "16:22", "maghrib": "19:00", "isha": "20:15"},
    {"day": 17, "fajr": "05:20", "sunrise": "06:39", "dhuhr": "12:52", "asr": "16:21", "maghrib": "18:59", "isha": "20:14"},
    {"day": 18, "fajr": "05:20", "sunrise": "06:39", "dhuhr": "12:52", "asr": "16:20", "maghrib": "18:57", "isha": "20:12"},
    {"day": 19, "fajr": "05:20", "sunrise": "06:39", "dhuhr": "12:52", "asr": "16:20", "maghrib": "18:56", "isha": "20:11"},
    {"day": 20, "fajr": "05:21", "sunrise": "06:40", "dhuhr": "12:51", "asr": "16:20", "maghrib": "18:55", "isha": "20:10"},
    {"day": 21, "fajr": "05:21", "sunrise": "06:40", "dhuhr": "12:51", "asr": "16:18", "maghrib": "18:53", "isha": "20:08"},
    {"day": 22, "fajr": "05:21", "sunrise": "06:40", "dhuhr": "12:51", "asr": "16:18", "maghrib": "18:52", "isha": "20:06"},
    {"day": 23, "fajr": "05:21", "sunrise": "06:41", "dhuhr": "12:51", "asr": "16:17", "maghrib": "18:51", "isha": "20:05"},
    {"day": 24, "fajr": "05:21", "sunrise": "06:41", "dhuhr": "12:50", "asr": "16:16", "maghrib": "18:50", "isha": "20:04"},
    {"day": 25, "fajr": "05:22", "sunrise": "06:42", "dhuhr": "12:50", "asr": "16:16", "maghrib": "18:49", "isha": "20:03"},
    {"day": 26, "fajr": "05:22", "sunrise": "06:42", "dhuhr": "12:50", "asr": "16:16", "maghrib": "18:48", "isha": "20:02"},
    {"day": 27, "fajr": "05:22", "sunrise": "06:43", "dhuhr": "12:50", "asr": "16:15", "maghrib": "18:47", "isha": "20:01"},
    {"day": 28, "fajr": "05:23", "sunrise": "06:43", "dhuhr": "12:49", "asr": "16:14", "maghrib": "18:46", "isha": "20:00"},
    {"day": 29, "fajr": "05:23", "sunrise": "06:43", "dhuhr": "12:49", "asr": "16:13", "maghrib": "18:45", "isha": "19:59"},
    {"day": 30, "fajr": "05:23", "sunrise": "06:44", "dhuhr": "12:49", "asr": "16:12", "maghrib": "18:44", "isha": "19:58"},
  ];

  // شهر أكتوبر (الشهر 10) - محافظة الأقصر (توقيت صيفي معتمد)
  static const List<Map<String, dynamic>> octoberTimes = [
    {"day": 1, "fajr": "05:24", "sunrise": "06:44", "dhuhr": "12:49", "asr": "16:11", "maghrib": "18:43", "isha": "19:57"},
    {"day": 2, "fajr": "05:24", "sunrise": "06:44", "dhuhr": "12:48", "asr": "16:11", "maghrib": "18:42", "isha": "19:56"},
    {"day": 3, "fajr": "05:25", "sunrise": "06:45", "dhuhr": "12:48", "asr": "16:10", "maghrib": "18:41", "isha": "19:55"},
    {"day": 4, "fajr": "05:26", "sunrise": "06:45", "dhuhr": "12:48", "asr": "16:10", "maghrib": "18:40", "isha": "19:54"},
    {"day": 5, "fajr": "05:26", "sunrise": "06:46", "dhuhr": "12:47", "asr": "16:09", "maghrib": "18:39", "isha": "19:53"},
    {"day": 6, "fajr": "05:26", "sunrise": "06:47", "dhuhr": "12:47", "asr": "16:08", "maghrib": "18:38", "isha": "19:52"},
    {"day": 7, "fajr": "05:27", "sunrise": "06:47", "dhuhr": "12:47", "asr": "16:08", "maghrib": "18:37", "isha": "19:51"},
    {"day": 8, "fajr": "05:28", "sunrise": "06:48", "dhuhr": "12:47", "asr": "16:07", "maghrib": "18:36", "isha": "19:50"},
    {"day": 9, "fajr": "05:28", "sunrise": "06:48", "dhuhr": "12:47", "asr": "16:06", "maghrib": "18:35", "isha": "19:49"},
    {"day": 10, "fajr": "05:30", "sunrise": "06:49", "dhuhr": "12:47", "asr": "16:06", "maghrib": "18:35", "isha": "19:49"},
    {"day": 11, "fajr": "05:31", "sunrise": "06:49", "dhuhr": "12:47", "asr": "16:05", "maghrib": "18:34", "isha": "19:48"},
    {"day": 12, "fajr": "05:31", "sunrise": "06:49", "dhuhr": "12:47", "asr": "16:05", "maghrib": "18:32", "isha": "19:47"},
    {"day": 13, "fajr": "05:31", "sunrise": "06:50", "dhuhr": "12:46", "asr": "16:04", "maghrib": "18:31", "isha": "19:46"},
    {"day": 14, "fajr": "05:32", "sunrise": "06:51", "dhuhr": "12:46", "asr": "16:03", "maghrib": "18:31", "isha": "19:45"},
    {"day": 15, "fajr": "05:33", "sunrise": "06:52", "dhuhr": "12:46", "asr": "16:03", "maghrib": "18:30", "isha": "19:44"},
    {"day": 16, "fajr": "05:33", "sunrise": "06:52", "dhuhr": "12:46", "asr": "16:02", "maghrib": "18:29", "isha": "19:43"},
    {"day": 17, "fajr": "05:33", "sunrise": "06:54", "dhuhr": "12:46", "asr": "16:01", "maghrib": "18:28", "isha": "19:43"},
    {"day": 18, "fajr": "05:33", "sunrise": "06:54", "dhuhr": "12:46", "asr": "16:01", "maghrib": "18:27", "isha": "19:42"},
    {"day": 19, "fajr": "05:33", "sunrise": "06:55", "dhuhr": "12:46", "asr": "16:00", "maghrib": "18:26", "isha": "19:41"},
    {"day": 20, "fajr": "05:34", "sunrise": "06:55", "dhuhr": "12:46", "asr": "16:00", "maghrib": "18:25", "isha": "19:40"},
    {"day": 21, "fajr": "05:35", "sunrise": "06:56", "dhuhr": "12:46", "asr": "15:59", "maghrib": "18:24", "isha": "19:39"},
    {"day": 22, "fajr": "05:36", "sunrise": "06:56", "dhuhr": "12:46", "asr": "15:59", "maghrib": "18:24", "isha": "19:39"},
    {"day": 23, "fajr": "05:37", "sunrise": "06:57", "dhuhr": "12:46", "asr": "15:58", "maghrib": "18:23", "isha": "19:38"},
    {"day": 24, "fajr": "05:37", "sunrise": "06:57", "dhuhr": "12:46", "asr": "15:57", "maghrib": "18:22", "isha": "19:37"},
    {"day": 25, "fajr": "05:38", "sunrise": "06:58", "dhuhr": "12:46", "asr": "15:56", "maghrib": "18:21", "isha": "19:36"},
    {"day": 26, "fajr": "05:38", "sunrise": "06:58", "dhuhr": "12:46", "asr": "15:56", "maghrib": "18:20", "isha": "19:35"},
    {"day": 27, "fajr": "05:38", "sunrise": "06:59", "dhuhr": "12:46", "asr": "15:55", "maghrib": "18:19", "isha": "19:34"},
    {"day": 28, "fajr": "05:40", "sunrise": "07:00", "dhuhr": "12:46", "asr": "15:54", "maghrib": "18:19", "isha": "19:34"},
    {"day": 29, "fajr": "05:40", "sunrise": "07:00", "dhuhr": "12:46", "asr": "15:54", "maghrib": "18:18", "isha": "19:33"},
    {"day": 30, "fajr": "05:41", "sunrise": "07:01", "dhuhr": "12:46", "asr": "15:54", "maghrib": "18:17", "isha": "19:32"},
    {"day": 31, "fajr": "05:41", "sunrise": "07:02", "dhuhr": "12:46", "asr": "15:53", "maghrib": "18:16", "isha": "19:31"},
  ];

  // شهر نوفمبر (الشهر 11) - محافظة الأقصر (توقيت صيفي معتمد)
  static const List<Map<String, dynamic>> novemberTimes = [
    {"day": 1, "fajr": "05:41", "sunrise": "07:03", "dhuhr": "12:46", "asr": "15:52", "maghrib": "18:15", "isha": "19:30"},
    {"day": 2, "fajr": "05:42", "sunrise": "07:03", "dhuhr": "12:46", "asr": "15:52", "maghrib": "18:15", "isha": "19:30"},
    {"day": 3, "fajr": "05:42", "sunrise": "07:04", "dhuhr": "12:46", "asr": "15:52", "maghrib": "18:14", "isha": "19:29"},
    {"day": 4, "fajr": "05:42", "sunrise": "07:04", "dhuhr": "12:46", "asr": "15:51", "maghrib": "18:13", "isha": "19:28"},
    {"day": 5, "fajr": "05:43", "sunrise": "07:05", "dhuhr": "12:46", "asr": "15:50", "maghrib": "18:12", "isha": "19:27"},
    {"day": 6, "fajr": "05:44", "sunrise": "07:05", "dhuhr": "12:46", "asr": "15:50", "maghrib": "18:12", "isha": "19:27"},
    {"day": 7, "fajr": "05:44", "sunrise": "07:05", "dhuhr": "12:46", "asr": "15:49", "maghrib": "18:11", "isha": "19:26"},
    {"day": 8, "fajr": "05:45", "sunrise": "07:06", "dhuhr": "12:47", "asr": "15:49", "maghrib": "18:11", "isha": "19:26"},
    {"day": 9, "fajr": "05:45", "sunrise": "07:07", "dhuhr": "12:47", "asr": "15:48", "maghrib": "18:10", "isha": "19:25"},
    {"day": 10, "fajr": "05:46", "sunrise": "07:08", "dhuhr": "12:48", "asr": "15:48", "maghrib": "18:10", "isha": "19:25"},
    {"day": 11, "fajr": "05:48", "sunrise": "07:09", "dhuhr": "12:48", "asr": "15:48", "maghrib": "18:10", "isha": "19:25"},
    {"day": 12, "fajr": "05:48", "sunrise": "07:10", "dhuhr": "12:48", "asr": "15:48", "maghrib": "18:09", "isha": "19:24"},
    {"day": 13, "fajr": "05:49", "sunrise": "07:11", "dhuhr": "12:49", "asr": "15:47", "maghrib": "18:09", "isha": "19:24"},
    {"day": 14, "fajr": "05:49", "sunrise": "07:11", "dhuhr": "12:49", "asr": "15:47", "maghrib": "18:08", "isha": "19:23"},
    {"day": 15, "fajr": "05:50", "sunrise": "07:12", "dhuhr": "12:49", "asr": "15:47", "maghrib": "18:08", "isha": "19:23"},
    {"day": 16, "fajr": "05:50", "sunrise": "07:13", "dhuhr": "12:49", "asr": "15:47", "maghrib": "18:07", "isha": "19:22"},
    {"day": 17, "fajr": "05:51", "sunrise": "07:14", "dhuhr": "12:49", "asr": "15:47", "maghrib": "18:07", "isha": "19:22"},
    {"day": 18, "fajr": "05:52", "sunrise": "07:15", "dhuhr": "12:50", "asr": "15:47", "maghrib": "18:07", "isha": "19:22"},
    {"day": 19, "fajr": "05:52", "sunrise": "07:16", "dhuhr": "12:51", "asr": "15:47", "maghrib": "18:07", "isha": "19:22"},
    {"day": 20, "fajr": "05:53", "sunrise": "07:16", "dhuhr": "12:51", "asr": "15:47", "maghrib": "18:07", "isha": "19:22"},
    {"day": 21, "fajr": "05:53", "sunrise": "07:17", "dhuhr": "12:51", "asr": "15:46", "maghrib": "18:06", "isha": "19:22"},
    {"day": 22, "fajr": "05:54", "sunrise": "07:18", "dhuhr": "12:51", "asr": "15:46", "maghrib": "18:06", "isha": "19:22"},
    {"day": 23, "fajr": "05:54", "sunrise": "07:18", "dhuhr": "12:52", "asr": "15:46", "maghrib": "18:06", "isha": "19:22"},
    {"day": 24, "fajr": "05:54", "sunrise": "07:18", "dhuhr": "12:52", "asr": "15:46", "maghrib": "18:05", "isha": "19:21"},
    {"day": 25, "fajr": "05:55", "sunrise": "07:19", "dhuhr": "12:52", "asr": "15:46", "maghrib": "18:05", "isha": "19:21"},
    {"day": 26, "fajr": "05:56", "sunrise": "07:20", "dhuhr": "12:53", "asr": "15:46", "maghrib": "18:05", "isha": "19:21"},
    {"day": 27, "fajr": "05:57", "sunrise": "07:21", "dhuhr": "12:53", "asr": "15:46", "maghrib": "18:05", "isha": "19:21"},
    {"day": 28, "fajr": "05:57", "sunrise": "07:22", "dhuhr": "12:53", "asr": "15:46", "maghrib": "18:05", "isha": "19:21"},
    {"day": 29, "fajr": "05:58", "sunrise": "07:22", "dhuhr": "12:54", "asr": "15:46", "maghrib": "18:05", "isha": "19:21"},
    {"day": 30, "fajr": "05:58", "sunrise": "07:23", "dhuhr": "12:54", "asr": "15:46", "maghrib": "18:05", "isha": "19:22"},
  ];

  // شهر ديسمبر (الشهر 12) - محافظة الأقصر (توقيت صيفي معتمد)
  static const List<Map<String, dynamic>> decemberTimes = [
    {"day": 1, "fajr": "05:59", "sunrise": "07:23", "dhuhr": "12:54", "asr": "15:46", "maghrib": "18:05", "isha": "19:22"},
    {"day": 2, "fajr": "05:59", "sunrise": "07:24", "dhuhr": "12:55", "asr": "15:46", "maghrib": "18:05", "isha": "19:22"},
    {"day": 3, "fajr": "06:00", "sunrise": "07:25", "dhuhr": "12:55", "asr": "15:46", "maghrib": "18:05", "isha": "19:22"},
    {"day": 4, "fajr": "06:00", "sunrise": "07:26", "dhuhr": "12:56", "asr": "15:46", "maghrib": "18:05", "isha": "19:22"},
    {"day": 5, "fajr": "06:01", "sunrise": "07:26", "dhuhr": "12:56", "asr": "15:46", "maghrib": "18:05", "isha": "19:22"},
    {"day": 6, "fajr": "06:02", "sunrise": "07:27", "dhuhr": "12:57", "asr": "15:46", "maghrib": "18:05", "isha": "19:22"},
    {"day": 7, "fajr": "06:02", "sunrise": "07:28", "dhuhr": "12:57", "asr": "15:47", "maghrib": "18:05", "isha": "19:22"},
    {"day": 8, "fajr": "06:02", "sunrise": "07:29", "dhuhr": "12:57", "asr": "15:47", "maghrib": "18:05", "isha": "19:22"},
    {"day": 9, "fajr": "06:03", "sunrise": "07:30", "dhuhr": "12:58", "asr": "15:47", "maghrib": "18:05", "isha": "19:22"},
    {"day": 10, "fajr": "06:04", "sunrise": "07:31", "dhuhr": "12:59", "asr": "15:48", "maghrib": "18:06", "isha": "19:24"},
    {"day": 11, "fajr": "06:04", "sunrise": "07:31", "dhuhr": "12:59", "asr": "15:48", "maghrib": "18:06", "isha": "19:24"},
    {"day": 12, "fajr": "06:04", "sunrise": "07:31", "dhuhr": "12:59", "asr": "15:48", "maghrib": "18:06", "isha": "19:24"},
    {"day": 13, "fajr": "06:05", "sunrise": "07:32", "dhuhr": "13:00", "asr": "15:48", "maghrib": "18:06", "isha": "19:24"},
    {"day": 14, "fajr": "06:06", "sunrise": "07:33", "dhuhr": "13:01", "asr": "15:49", "maghrib": "18:07", "isha": "19:25"},
    {"day": 15, "fajr": "06:06", "sunrise": "07:33", "dhuhr": "13:01", "asr": "15:49", "maghrib": "18:07", "isha": "19:25"},
    {"day": 16, "fajr": "06:07", "sunrise": "07:34", "dhuhr": "13:01", "asr": "15:49", "maghrib": "18:07", "isha": "19:25"},
    {"day": 17, "fajr": "06:08", "sunrise": "07:35", "dhuhr": "13:02", "asr": "15:50", "maghrib": "18:08", "isha": "19:26"},
    {"day": 18, "fajr": "06:08", "sunrise": "07:35", "dhuhr": "13:03", "asr": "15:50", "maghrib": "18:08", "isha": "19:26"},
    {"day": 19, "fajr": "06:08", "sunrise": "07:35", "dhuhr": "13:03", "asr": "15:50", "maghrib": "18:08", "isha": "19:26"},
    {"day": 20, "fajr": "06:08", "sunrise": "07:35", "dhuhr": "13:03", "asr": "15:51", "maghrib": "18:08", "isha": "19:27"},
    {"day": 21, "fajr": "06:09", "sunrise": "07:36", "dhuhr": "13:04", "asr": "15:51", "maghrib": "18:09", "isha": "19:28"},
    {"day": 22, "fajr": "06:09", "sunrise": "07:36", "dhuhr": "13:04", "asr": "15:51", "maghrib": "18:09", "isha": "19:28"},
    {"day": 23, "fajr": "06:10", "sunrise": "07:37", "dhuhr": "13:05", "asr": "15:52", "maghrib": "18:10", "isha": "19:29"},
    {"day": 24, "fajr": "06:10", "sunrise": "07:37", "dhuhr": "13:05", "asr": "15:52", "maghrib": "18:10", "isha": "19:29"},
    {"day": 25, "fajr": "06:11", "sunrise": "07:38", "dhuhr": "13:05", "asr": "15:53", "maghrib": "18:11", "isha": "19:30"},
    {"day": 26, "fajr": "06:12", "sunrise": "07:39", "dhuhr": "13:06", "asr": "15:54", "maghrib": "18:12", "isha": "19:31"},
    {"day": 27, "fajr": "06:12", "sunrise": "07:39", "dhuhr": "13:06", "asr": "15:54", "maghrib": "18:12", "isha": "19:31"},
    {"day": 28, "fajr": "06:12", "sunrise": "07:40", "dhuhr": "13:07", "asr": "15:55", "maghrib": "18:13", "isha": "19:32"},
    {"day": 29, "fajr": "06:13", "sunrise": "07:40", "dhuhr": "13:08", "asr": "15:56", "maghrib": "18:14", "isha": "19:33"},
    {"day": 30, "fajr": "06:13", "sunrise": "07:40", "dhuhr": "13:08", "asr": "15:56", "maghrib": "18:14", "isha": "19:33"},
    {"day": 31, "fajr": "06:13", "sunrise": "07:41", "dhuhr": "13:09", "asr": "15:57", "maghrib": "18:15", "isha": "19:34"},
  ];

  // خريطة لتخزين شهور السنة كاملة (12 شهراً)
  static const Map<int, List<Map<String, dynamic>>> allMonthsTimes = {
    1: januaryTimes,
    2: februaryTimes,
    3: marchTimes,
    4: aprilTimes,
    5: mayTimes,
    6: juneTimes,
    7: julyTimes,
    8: augustTimes,
    9: septemberTimes,
    10: octoberTimes,
    11: novemberTimes,
    12: decemberTimes,
  };

  static const Map<int, String> monthNames = {
    1: "يناير",
    2: "فبراير",
    3: "مارس",
    4: "إبريل",
    5: "مايو",
    6: "يونيو",
    7: "يوليو",
    8: "أغسطس",
    9: "سبتمبر",
    10: "أكتوبر",
    11: "نوفمبر",
    12: "ديسمبر",
  };

  static const Map<String, int> iqamaMinutes = {
    "fajr": 20,
    "sunrise": 0,
    "dhuhr": 15,
    "asr": 15,
    "maghrib": 5,
    "isha": 15,
  };

  static const List<Map<String, String>> prayerMeta = [
    {"key": "fajr", "name": "صلاة الفجر", "icon": "🌙"},
    {"key": "sunrise", "name": "الشروق", "icon": "🌅"},
    {"key": "dhuhr", "name": "صلاة الظهر", "icon": "☀️"},
    {"key": "asr", "name": "صلاة العصر", "icon": "🌤️"},
    {"key": "maghrib", "name": "صلاة المغرب", "icon": "🌇"},
    {"key": "isha", "name": "صلاة العشاء", "icon": "🌃"},
  ];
}

// -------------------------------------------------------------
// الشاشة الرئيسية HomeScreen
// -------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const MethodChannel _audioChannel =
      MethodChannel('com.abdelrahman.prayertimes/audio');

  late Timer _timer;
  DateTime _now = DateTime.now();
  bool _isSummerTime = true;
  bool _showIqama = true;
  bool _athanNotifications = true;
  bool _reminder15Min = true;
  int _selectedMonth = 9;
  String _displayName = 'عبد الرحمن ياسر الاسيوطي';

  bool _isPlayingAudio = false;
  String _lastTriggeredAthanKey = '';
  String _lastTriggered15MinKey = '';
  bool _isAlarmScreenOpen = false;
  bool _isDownloadingImage = false;
  final GlobalKey _scheduleRepaintKey = GlobalKey();

  bool _isNotificationGranted = false;
  bool _isOverlayGranted = false;
  bool _isBatteryOptimized = false;
  bool _hasPromptedPermissionsOnLaunch = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  Future<void> _playAthanSound() async {
    try {
      await _audioChannel.invokeMethod('playAthan');
      if (mounted) setState(() => _isPlayingAudio = true);
    } catch (_) {}
  }

  Future<void> _stopAthanSound() async {
    try {
      await _audioChannel.invokeMethod('stopAthan');
      if (mounted) setState(() => _isPlayingAudio = false);
    } catch (_) {}
  }

  Future<void> _checkPermissions() async {
    try {
      final notif = await _audioChannel.invokeMethod<bool>('checkNotificationPermission') ?? false;
      final overlay = await _audioChannel.invokeMethod<bool>('checkOverlayPermission') ?? false;
      final battery = await _audioChannel.invokeMethod<bool>('checkBatteryPermission') ?? false;
      if (mounted) {
        setState(() {
          _isNotificationGranted = notif;
          _isOverlayGranted = overlay;
          _isBatteryOptimized = battery;
        });
      }
    } catch (_) {}
  }

  Future<void> _requestNotificationPermission() async {
    try {
      await _audioChannel.invokeMethod('requestNotificationPermission');
      await Future.delayed(const Duration(milliseconds: 600));
      await _checkPermissions();
      _scheduleBackgroundAlarms();
    } catch (_) {
      _showSnackBar('تعذر طلب إذن الإشعارات');
    }
  }

  Future<void> _openOverlaySettings() async {
    try {
      await _audioChannel.invokeMethod('openOverlaySettings');
    } catch (_) {
      _showSnackBar('تعذر فتح إعدادات الظهور فوق التطبيقات');
    }
  }

  Future<void> _openBatterySettings() async {
    try {
      await _audioChannel.invokeMethod('openBatterySettings');
    } catch (_) {
      _showSnackBar('تعذر فتح إعدادات البطارية');
    }
  }

  Future<void> _scheduleBackgroundAlarms() async {
    try {
      final todayData = _getTodayData();
      final now = DateTime.now();
      final List<Map<String, dynamic>> alarms = [];

      for (var meta in PrayerData.prayerMeta) {
        final key = meta['key']!;
        if (key == 'sunrise') continue;

        final adjusted = _adjustTime(key, todayData[key]!);
        final parts = adjusted.split(':');
        final pHour = int.parse(parts[0]);
        final pMinute = int.parse(parts[1]);

        final prayerDateTime = DateTime(now.year, now.month, now.day, pHour, pMinute);

        // 1. منبه الأذان
        if (_athanNotifications && prayerDateTime.isAfter(now)) {
          alarms.add({
            'id': (key.hashCode.abs() % 100000),
            'timestamp': prayerDateTime.millisecondsSinceEpoch,
            'type': 'athan',
            'prayerName': meta['name'],
            'title': '🕌 حان الآن موعد الصلاة',
            'message': 'الله أكبر.. حان الآن موعد أذان ${meta['name']}',
          });
        }

        // 2. تنبيه اقتراب الوقت بـ 15 دقيقة
        if (_reminder15Min) {
          final reminderDateTime = prayerDateTime.subtract(const Duration(minutes: 15));
          if (reminderDateTime.isAfter(now)) {
            alarms.add({
              'id': ((key.hashCode.abs() + 50000) % 100000),
              'timestamp': reminderDateTime.millisecondsSinceEpoch,
              'type': 'reminder',
              'prayerName': meta['name'],
              'title': '🕌 اقتراب موعد الصلاة',
              'message': 'متبقي 15 دقيقة على موعد ${meta['name']}',
            });
          }
        }
      }

      if (alarms.isNotEmpty) {
        await _audioChannel.invokeMethod('schedulePrayerAlarms', {'alarms': alarms});
      }
    } catch (_) {}
  }

  void _showAthanAlarmScreen(String prayerName, String prayerIcon, String prayerTime12) {
    if (_isAlarmScreenOpen) return;
    _isAlarmScreenOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F1235), Color(0xFF0F231A), Color(0xFF0A0A1A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFFFD700), width: 2.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.35),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      border: Border.all(color: const Color(0xFFFFD700), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        prayerIcon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    '🕌 حان الآن موعد أذان',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    prayerName,
                    style: GoogleFonts.amiri(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D68F).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00D68F)),
                    ),
                    child: Text(
                      'الوقت: $prayerTime12',
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00D68F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '﴿ حَافِظُوا عَلَى الصَّلَوَاتِ وَالصَّلَاةِ الْوُسْطَىٰ وَقُومُوا لِلَّهِ قَانِتِينَ ﴾',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.amiri(
                      fontSize: 14,
                      color: const Color(0xFFFFECB3),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _stopAthanSound();
                        _isAlarmScreenOpen = false;
                        Navigator.pop(dialogCtx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.stop_circle_outlined, size: 28),
                      label: Text(
                        'إيقاف الأذان',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'دعاء بعد الأذان:\n«اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ القَائِمَةِ، آتِ مُحَمَّداً الوَسِيلَةَ وَالفَضِيلَةَ، وَابْعَثْهُ مَقَاماً مَحمُوداً الَّذِي وَعَدْتَهُ»',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _isAlarmScreenOpen = false;
    });
  }

  void _checkAndTriggerAthan(Map<String, dynamic> todayData) {
    if (!_athanNotifications) return;

    final currentHour = _now.hour;
    final currentMinute = _now.minute;
    final currentSecond = _now.second;

    for (var meta in PrayerData.prayerMeta) {
      final key = meta['key']!;
      if (key == 'sunrise') continue;

      final adjusted = _adjustTime(key, todayData[key]!);
      final parts = adjusted.split(':');
      final pHour = int.parse(parts[0]);
      final pMinute = int.parse(parts[1]);

      // 1. تنبيه اقتراب وقت الصلاة (باقي 15 دقيقة) - إشعار نظام حقيقي + رسالة
      if (_reminder15Min) {
        var remHour = pHour;
        var remMinute = pMinute - 15;
        if (remMinute < 0) {
          remMinute += 60;
          remHour = (remHour - 1 + 24) % 24;
        }

        if (currentHour == remHour && currentMinute == remMinute && currentSecond <= 2) {
          final reminderToken = 'rem15_${_now.month}_${_now.day}_$key';
          if (_lastTriggered15MinKey != reminderToken) {
            _lastTriggered15MinKey = reminderToken;
            _audioChannel.invokeMethod('showNotification', {
              'title': '🕌 اقتراب موعد الصلاة',
              'message': 'متبقي 15 دقيقة على موعد ${meta['name']}',
              'isAthan': false,
            });
            _showSnackBar('📢 اقترب موعد ${meta['name']} (متبقي 15 دقيقة)');
          }
        }
      }

      // 2. انطلاق الأذان وشاشة المنبه بالثانية عند دخول الوقت بالضبط
      if (currentHour == pHour && currentMinute == pMinute && currentSecond <= 3) {
        final triggerToken = '${_now.month}_${_now.day}_$key';
        if (_lastTriggeredAthanKey != triggerToken) {
          _lastTriggeredAthanKey = triggerToken;
          _audioChannel.invokeMethod('showNotification', {
            'title': '🕌 حان الآن موعد الصلاة',
            'message': 'الله أكبر.. حان الآن موعد أذان ${meta['name']}',
            'isAthan': true,
          });
          _playAthanSound();
          _showAthanAlarmScreen(
            meta['name']!,
            meta['icon']!,
            _format12Hour(adjusted),
          );
        }
      }
    }
  }

  void _showPermissionSetupDialog([bool forceShow = false]) {
    if (!forceShow && _isNotificationGranted && _isBatteryOptimized && _isOverlayGranted) {
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF14122E),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                border: Border(
                  top: BorderSide(color: Color(0xFFFFD700), width: 1.5),
                  left: BorderSide(color: Color(0xFFFFD700), width: 0.5),
                  right: BorderSide(color: Color(0xFFFFD700), width: 0.5),
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🕌', style: TextStyle(fontSize: 26)),
                        const SizedBox(width: 10),
                        Text(
                          'تفعيل أنماط الأذان والتنبيهات',
                          style: GoogleFonts.amiri(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFFFD700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'لضمان وصول إشعار التذكير قبل الصلاة بـ 15 دقيقة وانطلاق صوت الأذان في موعده بالثانية، يُرجى تفعيل الصلاحيات التالية:',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12.5,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildPermissionItemInModal(
                      icon: Icons.notifications_active_rounded,
                      title: 'إذن الإشعارات',
                      desc: 'إرسال إشعار التنبيه قبل الصلاة بـ 15 دقيقة والأذان',
                      isGranted: _isNotificationGranted,
                      onTap: () async {
                        await _requestNotificationPermission();
                        await _checkPermissions();
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildPermissionItemInModal(
                      icon: Icons.battery_charging_full_rounded,
                      title: 'إيقاف تحسين البطارية',
                      desc: 'يمنع النظام من إيقاف أو تأخير الأذان في الخلفية',
                      isGranted: _isBatteryOptimized,
                      onTap: () async {
                        await _openBatterySettings();
                        await Future.delayed(const Duration(milliseconds: 600));
                        await _checkPermissions();
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildPermissionItemInModal(
                      icon: Icons.layers_outlined,
                      title: 'الظهور فوق التطبيقات',
                      desc: 'لعرض شاشة ومنبه الأذان الكبيرة عند دخول وقت الصلاة',
                      isGranted: _isOverlayGranted,
                      onTap: () async {
                        await _openOverlaySettings();
                        await Future.delayed(const Duration(milliseconds: 600));
                        await _checkPermissions();
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(bottomCtx);
                          _scheduleBackgroundAlarms();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD700),
                          foregroundColor: const Color(0xFF0F0B1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'حفظ ومتابعة التطبيق',
                          style: GoogleFonts.cairo(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionItemInModal({
    required IconData icon,
    required String title,
    required String desc,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isGranted ? const Color(0xFF00A86B).withOpacity(0.15) : const Color(0xFF1E1A3C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGranted ? const Color(0xFF00D68F) : const Color(0xFFFFD700).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle_rounded : icon,
            color: isGranted ? const Color(0xFF00D68F) : const Color(0xFFFFD700),
            size: 26,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  desc,
                  style: GoogleFonts.cairo(
                    fontSize: 10.5,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: isGranted ? const Color(0xFF00D68F) : const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isGranted ? 'مفعّل ✓' : 'تفعيل',
              style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initSelectedMonth();
    _loadSettings();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
        _checkAndTriggerAthan(_getTodayData());
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkPermissions();
      _scheduleBackgroundAlarms();
      if (!_hasPromptedPermissionsOnLaunch && (!_isNotificationGranted || !_isBatteryOptimized || !_isOverlayGranted)) {
        _hasPromptedPermissionsOnLaunch = true;
        _showPermissionSetupDialog();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
      _scheduleBackgroundAlarms();
    }
  }

  void _initSelectedMonth() {
    final curM = DateTime.now().month;
    if (PrayerData.allMonthsTimes.containsKey(curM)) {
      _selectedMonth = curM;
    } else {
      _selectedMonth = 9;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    _stopAthanSound();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isSummerTime = prefs.getBool('isSummerTime') ?? true;
        _showIqama = prefs.getBool('showIqama') ?? true;
        _athanNotifications = prefs.getBool('athanNotifications') ?? true;
        _reminder15Min = prefs.getBool('reminder15Min') ?? true;
        final savedName = prefs.getString('ownerDisplayName');
        if (savedName != null && savedName.trim().isNotEmpty) {
          _displayName = savedName.trim();
        }
      });
    } catch (_) {}
  }

  Future<void> _saveSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (_) {}
  }

  // -----------------------------------------------------------
  // تعديل وحفظ الاسم المعروض (✏️) في الذاكرة
  // -----------------------------------------------------------
  Future<void> _editDisplayName() async {
    final controller = TextEditingController(text: _displayName);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14122E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFFFD700), width: 1),
        ),
        title: Text(
          '✏️ تعديل الاسم المعروض',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textAlign: TextAlign.center,
          maxLength: 40,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            counterStyle: GoogleFonts.cairo(color: Colors.white38),
            hintText: 'اكتب الاسم الجديد هنا',
            hintStyle: GoogleFonts.cairo(color: Colors.white38),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFFFD700), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFFFFD700), width: 1.8),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: const Color(0xFF0A0A1A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'حفظ',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final newName = controller.text.trim();
      if (newName.isNotEmpty && newName != _displayName) {
        setState(() {
          _displayName = newName;
        });
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('ownerDisplayName', newName);
        } catch (_) {}
        _showSnackBar('تم حفظ الاسم: $newName ✨');
      }
    }
    controller.dispose();
  }

  String _adjustTime(String prayerKey, String time24) {
    if (!_isSummerTime && prayerKey != 'dhuhr') {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      hour = (hour - 1 + 24) % 24;
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }
    return time24;
  }

  String _format12Hour(String time24) {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'م' : 'ص';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    return '$hour:$minute $period';
  }

  Map<String, dynamic> _getTodayData() {
    final monthList =
        PrayerData.allMonthsTimes[_selectedMonth] ?? PrayerData.septemberTimes;
    int currentDay = _now.day;
    if (currentDay < 1 || currentDay > monthList.length) {
      currentDay = 1;
    }
    return monthList.firstWhere(
      (element) => element['day'] == currentDay,
      orElse: () => monthList.first,
    );
  }

  String _getTomorrowFajr() {
    final monthList =
        PrayerData.allMonthsTimes[_selectedMonth] ?? PrayerData.septemberTimes;
    int tomorrowDay = _now.day + 1;
    if (tomorrowDay > monthList.length) {
      final nextMonth = _selectedMonth == 12 ? 9 : _selectedMonth + 1;
      final nextMonthList =
          PrayerData.allMonthsTimes[nextMonth] ?? PrayerData.septemberTimes;
      return _adjustTime('fajr', nextMonthList.first['fajr']);
    }
    final tomorrowData = monthList.firstWhere(
      (element) => element['day'] == tomorrowDay,
      orElse: () => monthList.first,
    );
    return _adjustTime('fajr', tomorrowData['fajr']);
  }

  Map<String, dynamic> _getNextPrayerInfo() {
    final todayData = _getTodayData();
    final nowMinutes = _now.hour * 60 + _now.minute;
    final nowSeconds = _now.second;

    for (var meta in PrayerData.prayerMeta) {
      final key = meta['key']!;
      final adjusted = _adjustTime(key, todayData[key]!);
      final parts = adjusted.split(':');
      final pMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);

      if (pMinutes * 60 > (nowMinutes * 60 + nowSeconds)) {
        final totalSecondsRemaining =
            (pMinutes * 60) - (nowMinutes * 60 + nowSeconds);
        return {
          "key": meta['key'],
          "name": meta['name'],
          "icon": meta['icon'],
          "time24": adjusted,
          "remainingSeconds": totalSecondsRemaining,
          "isTomorrow": false,
        };
      }
    }

    final tomorrowFajr = _getTomorrowFajr();
    final parts = tomorrowFajr.split(':');
    final fajrMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final secondsUntilMidnight = (24 * 3600) - (nowMinutes * 60 + nowSeconds);
    final totalSecondsRemaining = secondsUntilMidnight + (fajrMinutes * 60);

    return {
      "key": "fajr",
      "name": "صلاة الفجر (غداً)",
      "icon": "🌙",
      "time24": tomorrowFajr,
      "remainingSeconds": totalSecondsRemaining,
      "isTomorrow": true,
    };
  }

  String _formatDuration(int totalSeconds) {
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        _showSnackBar('الرقم: $phoneNumber');
      }
    } catch (_) {
      _showSnackBar('الرقم: $phoneNumber');
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final nativeUri = Uri.parse("whatsapp://send?phone=$cleanPhone");
    final webUri = Uri.parse("https://api.whatsapp.com/send?phone=$cleanPhone");

    try {
      if (await canLaunchUrl(nativeUri)) {
        await launchUrl(nativeUri, mode: LaunchMode.externalNonBrowserApplication);
        return;
      }
    } catch (_) {}

    try {
      if (await canLaunchUrl(webUri)) {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {}

    _showSnackBar('الرقم: $phone');
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: const Color(0xFF1E1233),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nextPrayer = _getNextPrayerInfo();
    final todayData = _getTodayData();
    final tomorrowFajr = _getTomorrowFajr();
    final arabicDate = DateFormat('EEEE d MMMM yyyy', 'ar_EG').format(_now);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0A1A), Color(0xFF160B28), Color(0xFF0D1117)],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: StarsBackground()),
            SafeArea(
              child: RefreshIndicator(
                color: const Color(0xFFFFD700),
                backgroundColor: const Color(0xFF14142B),
                onRefresh: () async {
                  setState(() {
                    _now = DateTime.now();
                  });
                },
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      _buildHeaderSection(),
                      const SizedBox(height: 16),
                      _buildLiveClockAndDate(arabicDate),
                      const SizedBox(height: 16),
                      _buildNextPrayerCard(nextPrayer),
                      const SizedBox(height: 18),
                      _buildPrayerCardsList(todayData, nextPrayer['key']),
                      const SizedBox(height: 14),
                      _buildDownloadScheduleButton(todayData, arabicDate),
                      const SizedBox(height: 14),
                      _buildTomorrowFajrCard(tomorrowFajr),
                      const SizedBox(height: 18),
                      _buildSettingsCard(),
                      const SizedBox(height: 18),
                      _buildMonthTableButton(),
                      const SizedBox(height: 18),
                      _buildContactSection(),
                      const SizedBox(height: 20),
                      _buildFooter(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
            // Offscreen RepaintBoundary for generating prayer schedule card image
            Positioned(
              left: -9999,
              top: -9999,
              child: RepaintBoundary(
                key: _scheduleRepaintKey,
                child: _buildShareableScheduleCard(todayData, arabicDate),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🕌', style: TextStyle(fontSize: 18)),
              SizedBox(width: 8),
              Text('✨', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('🌙', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('✨', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text('🕌', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'مواقيت الصلاة - الأقصر',
            style: GoogleFonts.amiri(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700),
              shadows: [
                Shadow(
                  color: const Color(0xFFFFD700).withOpacity(0.5),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 22, color: Color(0xFFFFD700))),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _displayName,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFE082),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text('⭐', style: TextStyle(fontSize: 22, color: Color(0xFFFFD700))),
              const SizedBox(width: 2),
              IconButton(
                tooltip: 'تعديل الاسم',
                onPressed: _editDisplayName,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
                splashRadius: 20,
                icon: const Text('✏️', style: TextStyle(fontSize: 17)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          PopupMenuButton<int>(
            initialValue: _selectedMonth,
            onSelected: (int month) {
              setState(() {
                _selectedMonth = month;
              });
            },
            color: const Color(0xFF1E1738),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: Color(0xFFFFD700), width: 1),
            ),
            itemBuilder: (BuildContext context) {
              return PrayerData.monthNames.entries.map((entry) {
                final isCurrent = entry.key == _selectedMonth;
                return PopupMenuItem<int>(
                  value: entry.key,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'شهر ${entry.value}',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? const Color(0xFFFFD700) : Colors.white,
                        ),
                      ),
                      if (isCurrent)
                        const Icon(Icons.check_circle_rounded, color: Color(0xFF00D68F), size: 18),
                    ],
                  ),
                );
              }).toList();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF003B2B).withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF00A86B).withOpacity(0.8), width: 1.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF00D68F), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'محافظة الأقصر - شهر ${PrayerData.monthNames[_selectedMonth] ?? "سبتمبر"}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0xFF00D68F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Text(
              '﴿ إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا ﴾',
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFECB3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveClockAndDate(String arabicDate) {
    int hour = _now.hour;
    final period = hour >= 12 ? 'م' : 'ص';
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final minute = _now.minute.toString().padLeft(2, '0');
    final second = _now.second.toString().padLeft(2, '0');
    final liveTime = '$hour:$minute:$second';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B).withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(
            arabicDate,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                liveTime,
                style: GoogleFonts.cairo(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFD700),
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                period,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard(Map<String, dynamic> nextPrayer) {
    final totalSec = nextPrayer['remainingSeconds'] as int;
    final countdownStr = _formatDuration(totalSec);

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0C2B1C), Color(0xFF1E1738)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF00D68F), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D68F).withOpacity(0.25),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⏰', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  'الوقت المتبقي للصلاة القادمة',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${nextPrayer['icon']} ${nextPrayer['name']}',
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              countdownStr,
              style: GoogleFonts.cairo(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF00D68F),
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCardsList(
      Map<String, dynamic> todayData, String nextPrayerKey) {
    return Column(
      children: PrayerData.prayerMeta.map((meta) {
        final key = meta['key']!;
        final name = meta['name']!;
        final icon = meta['icon']!;
        final rawTime = todayData[key]!;
        final adjusted = _adjustTime(key, rawTime);
        final formatted12 = _format12Hour(adjusted);
        final isNext = (nextPrayerKey == key);
        final iqama = PrayerData.iqamaMinutes[key] ?? 0;

        return _buildPrayerCardItem(
          name: name,
          icon: icon,
          time12: formatted12,
          isNext: isNext,
          iqamaMinutes: iqama,
        );
      }).toList(),
    );
  }

  Widget _buildPrayerCardItem({
    required String name,
    required String icon,
    required String time12,
    required bool isNext,
    required int iqamaMinutes,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNext
            ? const Color(0xFF00A86B).withOpacity(0.22)
            : const Color(0xFFFFD700).withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext
              ? const Color(0xFF00D68F)
              : const Color(0xFFFFD700).withOpacity(0.2),
          width: isNext ? 1.8 : 1,
        ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: const Color(0xFF00D68F).withOpacity(0.25),
                  blurRadius: 15,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                name,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                  color: isNext ? const Color(0xFFFFD700) : Colors.white,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (_showIqama && iqamaMinutes > 0)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'إقامة $iqamaMinutes د',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFFFFE082),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Text(
                time12,
                style: GoogleFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isNext
                      ? const Color(0xFF00D68F)
                      : const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowFajrCard(String tomorrowFajr24) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF14243B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF64B5F6).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text('🌅', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Text(
                'فجر الغد',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF90CAF9),
                ),
              ),
            ],
          ),
          Text(
            _format12Hour(tomorrowFajr24),
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('⚙️', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'الإعدادات',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 16),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFFFFD700),
            title: Text(
              '☀️ التوقيت الصيفي',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.white),
            ),
            subtitle: Text(
              _isSummerTime
                  ? 'مفعل (التوقيت الصيفي المعتمد بالجدول)'
                  : 'غير مفعل (التوقيت الشتوي - تأخير ساعة)',
              style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
            ),
            value: _isSummerTime,
            onChanged: (val) {
              setState(() => _isSummerTime = val);
              _saveSetting('isSummerTime', val);
            },
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFFFFD700),
            title: Text(
              '🕐 إظهار وقت الإقامة',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.white),
            ),
            subtitle: Text(
              'عرض دقائق الإقامة بجوار كل صلاة',
              style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
            ),
            value: _showIqama,
            onChanged: (val) {
              setState(() => _showIqama = val);
              _saveSetting('showIqama', val);
            },
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFFFFD700),
            title: Text(
              '🔔 تنبيهات وصوت الأذان',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.white),
            ),
            subtitle: Text(
              'تشغيل صوت الأذان بصوت المؤذن وشاشة المنبه عند حلول وقت الصلاة',
              style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
            ),
            value: _athanNotifications,
            onChanged: (val) {
              setState(() => _athanNotifications = val);
              _saveSetting('athanNotifications', val);
            },
          ),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            activeColor: const Color(0xFF00D68F),
            title: Text(
              '⏰ التنبيه قبل الصلاة بـ 15 دقيقة',
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.white),
            ),
            subtitle: Text(
              'إشعار وتنبيه هادئ باقتراب وقت الصلاة قبل دخولها بربع ساعة',
              style: GoogleFonts.cairo(fontSize: 11, color: Colors.white54),
            ),
            value: _reminder15Min,
            onChanged: (val) {
              setState(() => _reminder15Min = val);
              _saveSetting('reminder15Min', val);
            },
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              if (_isPlayingAudio) {
                _stopAthanSound();
              } else {
                _playAthanSound();
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: _isPlayingAudio
                    ? const Color(0xFFE53935).withOpacity(0.18)
                    : const Color(0xFFFFD700).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPlayingAudio
                      ? const Color(0xFFEF5350)
                      : const Color(0xFFFFD700).withOpacity(0.35),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isPlayingAudio ? Icons.stop_circle_outlined : Icons.volume_up_rounded,
                    color: _isPlayingAudio ? const Color(0xFFEF5350) : const Color(0xFFFFD700),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPlayingAudio
                        ? 'إيقاف تشغيل صوت الأذان'
                        : 'تجربة واستماع لصوت الأذان (المؤذن)',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _isPlayingAudio ? const Color(0xFFEF5350) : const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Notification permission button with live checkmark
          InkWell(
            onTap: _requestNotificationPermission,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: _isNotificationGranted
                    ? const Color(0xFF00A86B).withOpacity(0.18)
                    : const Color(0xFF9C27B0).withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isNotificationGranted
                      ? const Color(0xFF00D68F)
                      : const Color(0xFFBA68C8).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isNotificationGranted ? Icons.check_circle : Icons.notifications_active_outlined,
                    color: _isNotificationGranted ? const Color(0xFF00D68F) : const Color(0xFFBA68C8),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '🔔 السماح بإرسال الإشعارات',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isNotificationGranted ? const Color(0xFF00D68F) : const Color(0xFFBA68C8),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: _isNotificationGranted ? const Color(0xFF00D68F) : Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _isNotificationGranted ? 'مفعل ✓' : 'اضغط للتفعيل',
                                style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'مطلوب لإرسال إشعار التنبيه قبل الصلاة بـ 15 دقيقة',
                          style: GoogleFonts.cairo(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Overlay permission button with live checkmark
          InkWell(
            onTap: _openOverlaySettings,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: _isOverlayGranted
                    ? const Color(0xFF00A86B).withOpacity(0.18)
                    : const Color(0xFF1565C0).withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isOverlayGranted
                      ? const Color(0xFF00D68F)
                      : const Color(0xFF42A5F5).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isOverlayGranted ? Icons.check_circle : Icons.layers_outlined,
                    color: _isOverlayGranted ? const Color(0xFF00D68F) : const Color(0xFF42A5F5),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '🪟 السماح بالظهور فوق التطبيقات',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isOverlayGranted ? const Color(0xFF00D68F) : const Color(0xFF42A5F5),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: _isOverlayGranted ? const Color(0xFF00D68F) : Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _isOverlayGranted ? 'مفعل ✓' : 'اضغط للتفعيل',
                                style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'مطلوب لعرض شاشة الأذان فوق التطبيقات الأخرى',
                          style: GoogleFonts.cairo(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Battery optimization button with live checkmark
          InkWell(
            onTap: _openBatterySettings,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: _isBatteryOptimized
                    ? const Color(0xFF00A86B).withOpacity(0.18)
                    : const Color(0xFF4CAF50).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isBatteryOptimized
                      ? const Color(0xFF00D68F)
                      : const Color(0xFF66BB6A).withOpacity(0.5),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isBatteryOptimized ? Icons.check_circle : Icons.battery_charging_full,
                    color: _isBatteryOptimized ? const Color(0xFF00D68F) : const Color(0xFF66BB6A),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '🔋 إيقاف تحسين البطارية للتطبيق',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isBatteryOptimized ? const Color(0xFF00D68F) : const Color(0xFF66BB6A),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: _isBatteryOptimized ? const Color(0xFF00D68F) : Colors.orange,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _isBatteryOptimized ? 'مفعل ✓' : 'اضغط للتفعيل',
                                style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'يمنع نظام Android من إيقاف التطبيق في الخلفية',
                          style: GoogleFonts.cairo(fontSize: 10, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Prominent all-modes setup button
          InkWell(
            onTap: () => _showPermissionSetupDialog(true),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E1F4D), Color(0xFF1B3326)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('✨', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    'تفعيل كل الأنماط والصلاحيات دفعة واحدة',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadScheduleButton(Map<String, dynamic> todayData, String arabicDate) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isDownloadingImage ? null : () => _captureAndSaveScheduleImage(todayData, arabicDate),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A86B),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF00A86B).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF00D68F).withOpacity(0.4),
        ),
        icon: _isDownloadingImage
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : const Icon(Icons.download_rounded, size: 22),
        label: Text(
          _isDownloadingImage ? 'جاري إنشاء وحفظ الصورة...' : 'تحميل ميعاد صلاة اليوم',
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _captureAndSaveScheduleImage(Map<String, dynamic> todayData, String arabicDate) async {
    setState(() => _isDownloadingImage = true);

    try {
      await Future.delayed(const Duration(milliseconds: 150));
      final boundary = _scheduleRepaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showSnackBar('تعذر تجهيز الصورة، حاول مجدداً');
        setState(() => _isDownloadingImage = false);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showSnackBar('تعذر إنشاء ملف الصورة');
        setState(() => _isDownloadingImage = false);
        return;
      }

      final pngBytes = byteData.buffer.asUint8List();
      final fileName = 'prayer_times_${_now.year}_${_now.month}_${_now.day}_${DateTime.now().millisecondsSinceEpoch}.png';

      final success = await _audioChannel.invokeMethod<bool>('saveImageToGallery', {
        'bytes': pngBytes,
        'fileName': fileName,
      });

      if (success == true) {
        _showSnackBar('✅ تم حفظ ميعاد صلاة اليوم في المعرض بنجاح');
      } else {
        _showSnackBar('تعذر حفظ الصورة');
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء حفظ الصورة');
    } finally {
      if (mounted) {
        setState(() => _isDownloadingImage = false);
      }
    }
  }

  Widget _buildShareableScheduleCard(Map<String, dynamic> todayData, String arabicDate) {
    return Container(
      width: 500,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B1C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row of crescent and mosques
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🕌', style: TextStyle(fontSize: 22)),
              SizedBox(width: 10),
              Text('✨', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Text('🌙', style: TextStyle(fontSize: 26)),
              SizedBox(width: 10),
              Text('✨', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Text('🕌', style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'مواقيت الصلاة - الأقصر',
            style: GoogleFonts.amiri(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⭐', style: TextStyle(fontSize: 24, color: Color(0xFFFFD700))),
              const SizedBox(width: 8),
              Text(
                _displayName,
                style: GoogleFonts.amiri(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFE082),
                ),
              ),
              const SizedBox(width: 8),
              const Text('⭐', style: TextStyle(fontSize: 24, color: Color(0xFFFFD700))),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF003B2B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00A86B), width: 1.5),
            ),
            child: Text(
              'محافظة الأقصر - شهر ${PrayerData.monthNames[_selectedMonth] ?? "سبتمبر"}',
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF00D68F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
            ),
            child: Text(
              '﴿ إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَّوْقُوتًا ﴾',
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFECB3),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Date Badge (Enlarged & Elegant)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF191636),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.35), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              arabicDate,
              style: GoogleFonts.cairo(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFFD700),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Prayer Cards List (Enlarged Prayer Names & Times)
          ...PrayerData.prayerMeta.map((meta) {
            final key = meta['key']!;
            final name = meta['name']!;
            final icon = meta['icon']!;
            final rawTime = todayData[key]!;
            final adjusted = _adjustTime(key, rawTime);
            final formatted12 = _format12Hour(adjusted);
            final iqama = PrayerData.iqamaMinutes[key] ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFF14122E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFFFD700).withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(icon, style: const TextStyle(fontSize: 25)),
                      const SizedBox(width: 12),
                      Text(
                        name,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_showIqama && iqama > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withOpacity(0.4),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'إقامة $iqama د',
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              color: const Color(0xFFFFE082),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Text(
                        formatted12,
                        style: GoogleFonts.cairo(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🤲 نسألكم الدعاء 🤲',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.white54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthTableButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => _openMonthTableDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDAA520),
          foregroundColor: const Color(0xFF0A0A1A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: const Color(0xFFFFD700).withOpacity(0.5),
        ),
        icon: const Text('📋', style: TextStyle(fontSize: 20)),
        label: Text(
          'عرض جدول شهر ${PrayerData.monthNames[_selectedMonth] ?? "سبتمبر"} كاملاً',
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _openMonthTableDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF100C1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final monthData =
            PrayerData.allMonthsTimes[_selectedMonth] ?? PrayerData.septemberTimes;
        final todayDay = _now.day;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PopupMenuButton<int>(
                        initialValue: _selectedMonth,
                        onSelected: (int m) {
                          setState(() {
                            _selectedMonth = m;
                          });
                          Navigator.pop(ctx);
                          _openMonthTableDialog();
                        },
                        color: const Color(0xFF1E1738),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: Color(0xFFFFD700), width: 1),
                        ),
                        itemBuilder: (BuildContext context) {
                          return PrayerData.monthNames.entries.map((entry) {
                            final isCurrent = entry.key == _selectedMonth;
                            return PopupMenuItem<int>(
                              value: entry.key,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'شهر ${entry.value}',
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                      color: isCurrent ? const Color(0xFFFFD700) : Colors.white,
                                    ),
                                  ),
                                  if (isCurrent)
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00D68F), size: 18),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'الأقصر - شهر ${PrayerData.monthNames[_selectedMonth] ?? "سبتمبر"}',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFD700),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_drop_down, color: Color(0xFFFFD700), size: 22),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: monthData.length,
                    itemBuilder: (_, index) {
                      final item = monthData[index];
                      final isToday =
                          (item['day'] == todayDay && _now.month == _selectedMonth);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF00A86B).withOpacity(0.25)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isToday
                                ? const Color(0xFF00D68F)
                                : Colors.white10,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'اليوم: ${item['day']}',
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.bold,
                                    color: isToday
                                        ? const Color(0xFFFFD700)
                                        : Colors.white,
                                  ),
                                ),
                                if (isToday)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00D68F),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'اليوم الحالي',
                                      style: GoogleFonts.cairo(
                                          fontSize: 10, color: Colors.black),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _tableTimeItem('فجر', _adjustTime('fajr', item['fajr'])),
                                _tableTimeItem(
                                    'شروق', _adjustTime('sunrise', item['sunrise'])),
                                _tableTimeItem('ظهر', _adjustTime('dhuhr', item['dhuhr'])),
                                _tableTimeItem('عصر', _adjustTime('asr', item['asr'])),
                                _tableTimeItem(
                                    'مغرب', _adjustTime('maghrib', item['maghrib'])),
                                _tableTimeItem('عشاء', _adjustTime('isha', item['isha'])),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _tableTimeItem(String label, String time24) {
    final parts = time24.split(':');
    int hour = int.parse(parts[0]);
    final minute = parts[1];
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final time12 = '$hour:$minute';

    return Column(
      children: [
        Text(label,
            style: GoogleFonts.cairo(fontSize: 11, color: Colors.white60)),
        Text(
          time12,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    const phone = '+201064106070';
    const displayPhone = '01064106070';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B).withOpacity(0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📞', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'للتواصل مع $_displayName',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '\u202A$displayPhone\u202C',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFE082),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makePhoneCall(phone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.phone, size: 18),
                  label: Text(
                    'اتصال مباشر',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openWhatsApp(phone),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Text('💬', style: TextStyle(fontSize: 16)),
                  label: Text(
                    'واتساب',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          '🤲 نسألكم الدعاء 🤲',
          style: GoogleFonts.amiri(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'جميع الحقوق محفوظة © 2026',
          style: GoogleFonts.cairo(
            fontSize: 10,
            color: Colors.white30,
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------
// خلفية النجوم المتلألئة (Stars Particles Background)
// -------------------------------------------------------------
class StarsBackground extends StatefulWidget {
  const StarsBackground({super.key});

  @override
  State<StarsBackground> createState() => _StarsBackgroundState();
}

class _StarsBackgroundState extends State<StarsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: StarsPainter(_controller.value),
        );
      },
    );
  }
}

class StarsPainter extends CustomPainter {
  final double animationVal;
  StarsPainter(this.animationVal);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFD700).withOpacity(0.15 + (animationVal * 0.15))
      ..style = PaintingStyle.fill;

    final points = [
      Offset(size.width * 0.15, size.height * 0.12),
      Offset(size.width * 0.82, size.height * 0.18),
      Offset(size.width * 0.35, size.height * 0.32),
      Offset(size.width * 0.70, size.height * 0.45),
      Offset(size.width * 0.20, size.height * 0.65),
      Offset(size.width * 0.85, size.height * 0.75),
      Offset(size.width * 0.45, size.height * 0.88),
    ];

    for (var p in points) {
      canvas.drawCircle(p, 1.6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarsPainter oldDelegate) => true;
}
