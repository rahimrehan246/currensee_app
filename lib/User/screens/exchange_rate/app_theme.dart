// lib/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color kBg = Color(0xFF070B14);
  static const Color kPurple = Color(0xFF5B2EFF);
  static const Color kPurpleDark = Color(0xFF3A1ACC);
  static const Color kPurpleGlow = Color(0x445B2EFF);
  static const Color kPurpleSoft = Color(0x225B2EFF);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kCardBg = Color(0xFF0D1526);
  static const Color kCardBorder = Color(0xFF1A2540);
  static const Color kTextSecondary = Color(0xFF6B7A99);
  static const Color kTextTertiary = Color(0xFF3D4D6B);
  static const Color kPositive = Color(0xFF00E676);
  static const Color kPositiveBg = Color(0x1500E676);
  static const Color kNegative = Color(0xFFFF4757);
  static const Color kNegativeBg = Color(0x15FF4757);
  static const Color kGold = Color(0xFFFFB347);
  static const Color kNavBg = Color(0xFF0A1020);

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [kPurple, kPurpleDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [Color(0xFF070B14), Color(0xFF0A0F1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF0F1A30), Color(0xFF0D1526)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.kBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.kPurple,
        secondary: AppColors.kPurpleDark,
        surface: AppColors.kCardBg,
        background: AppColors.kBg,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: AppColors.kWhite),
          displayMedium: TextStyle(color: AppColors.kWhite),
          displaySmall: TextStyle(color: AppColors.kWhite),
          headlineLarge: TextStyle(color: AppColors.kWhite),
          headlineMedium: TextStyle(color: AppColors.kWhite),
          headlineSmall: TextStyle(color: AppColors.kWhite),
          titleLarge: TextStyle(color: AppColors.kWhite),
          titleMedium: TextStyle(color: AppColors.kWhite),
          titleSmall: TextStyle(color: AppColors.kWhite),
          bodyLarge: TextStyle(color: AppColors.kWhite),
          bodyMedium: TextStyle(color: AppColors.kTextSecondary),
          bodySmall: TextStyle(color: AppColors.kTextTertiary),
          labelLarge: TextStyle(color: AppColors.kWhite),
          labelMedium: TextStyle(color: AppColors.kTextSecondary),
          labelSmall: TextStyle(color: AppColors.kTextTertiary),
        ),
      ),
      useMaterial3: true,
    );
  }
}
