import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'notification_service.dart';
import 'splash_view.dart';
// import 'firebase_options.dart';
import 'theme_app.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // ⚡ Enregistrer le handler de messages en arrière-plan
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  */
  
  // 🔔 Initialiser NotificationService
  await NotificationService.initialize();

  runApp(const ParkingAlertApp());
}

class ParkingAlertApp extends StatefulWidget {
  const ParkingAlertApp({super.key});

  @override
  State<ParkingAlertApp> createState() => ParkingAlertAppState();

  static ParkingAlertAppState of(BuildContext context) {
    return context.findAncestorStateOfType<ParkingAlertAppState>()!;
  }
}

class ParkingAlertAppState extends State<ParkingAlertApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    final isDark = prefs.getBool('isDarkMode') ?? false;
    
    // Load Locale
    final languageCode = prefs.getString('languageCode');
    
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      if (languageCode != null && (languageCode == 'en' || languageCode == 'fr')) {
        _locale = Locale(languageCode);
      } else {
        _locale = const Locale('en'); // Default to English if invalid
      }
    });
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Locale? get locale => _locale;

  void toggleTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  void setLocale(Locale locale) async {
    setState(() {
      _locale = locale;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Parking Alert',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      home: const SplashView(), // 🚀 Toujours démarrer sur SplashView
    );
  }
}