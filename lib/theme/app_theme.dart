import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../state/app_state.dart';

class AppTheme {
  static const Color graphite = Color(0xFF1C1C1E);
  static const Color deepBlue = Color(0xFF0F172A);
  static const Color accentBlue = Color(0xFF0A84FF); // iOS Accent
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFA1A1AA); // Lighter grey for better contrast

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      fontFamily: GoogleFonts.inter().fontFamily,
      textTheme: const TextTheme(
        // iOS lock screen style
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 80, letterSpacing: -2.5, height: 1.0),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 44, letterSpacing: -1.0),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500, fontSize: 28, letterSpacing: -0.5),
        bodyLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 0),
        bodyMedium: TextStyle(color: textSecondary, fontWeight: FontWeight.w400, fontSize: 14, letterSpacing: 0.1),
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
        // A deep, premium blue-black gradient
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.4, 1.0],
          colors: [Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF000000)],
        );
      case AppMode.focus:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E1065), Color(0xFF000000)],
        );
      case AppMode.aggressive:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7F1D1D), Color(0xFF000000)],
        );
    }
  }
}
