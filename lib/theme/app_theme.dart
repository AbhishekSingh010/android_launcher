import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';

class AppTheme {
  static const Color graphite = Color(0xFF1C1C1E);
  static const Color deepBlue = Color(0xFF0F172A);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w300, fontSize: 64, letterSpacing: -1.5),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w300, fontSize: 48, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w400, fontSize: 24, letterSpacing: 0),
        bodyLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 0.15),
        bodyMedium: TextStyle(color: textSecondary, fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.25),
      ),
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        surface: graphite,
      ),
    );
  }

  static LinearGradient getBackgroundGradient(AppMode mode) {
    switch (mode) {
      case AppMode.calm:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF000000)],
        );
      case AppMode.focus:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E1B4B), Color(0xFF000000)],
        );
      case AppMode.aggressive:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF450A0A), Color(0xFF000000)],
        );
    }
  }
}
