import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 Couleurs Personnalisées
  static const Color asphaltNavy = Color(0xFF2C3E50);
  static const Color alertGold = Color(0xFFF39C12);
  static const Color lightSurface = Color(0xFFF8FAFC);
  static const Color deepNight = Color(0xFF0F172A);
  static const Color darkAccent = Color(0xFF3498DB);
  static const Color darkSecondary = Color(0xFFF1C40F);
  static const Color appBarDark = Color(0xFF1E293B);

  // 🎭 Couleurs de Branding (Intro & Register)
  static const Color introBlueTop = Color(0xFF0D47A1);
  static const Color introBlueBottom = Color(0xFF1976D2);
  static const Color introAccent = Color(0xFF64B5F6);
  static const Color registerPrimary = Color(0xFF1565C0);
  static const Color registerPrimaryLight = Color(0xFF42A5F5);
  static const Color textMuted = Color(0xFF78909C);

  // 🌈 Dégradés Uniformes
  static Widget getAppBarGradient(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [appBarDark, deepNight]
              : [asphaltNavy, const Color(0xFF4CA1AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  static BoxDecoration getIntroGradient() {
    return const BoxDecoration(
      gradient: LinearGradient(
        colors: [introBlueTop, introBlueBottom],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  static BoxDecoration getRegisterBtnGradient(bool isLoading) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isLoading
            ? [Colors.grey.shade400, Colors.grey.shade500]
            : [registerPrimary, registerPrimaryLight],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: isLoading
          ? []
          : [
              BoxShadow(
                color: registerPrimary.withAlpha(102),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
    );
  }

  // ☀️ Thème Clair
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: asphaltNavy,
          primary: asphaltNavy,
          secondary: alertGold,
          surface: lightSurface,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: asphaltNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: alertGold, width: 2),
          ),
          prefixIconColor: asphaltNavy,
        ),
        fontFamily: 'Roboto',
      );

  // 🌙 Thème Sombre
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: asphaltNavy,
          primary: darkAccent,
          secondary: darkSecondary,
          surface: deepNight,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: appBarDark,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: appBarDark,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: appBarDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: darkSecondary, width: 2),
          ),
        ),
        fontFamily: 'Roboto',
      );
}
