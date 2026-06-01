import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFC15A3D);
  static const Color primaryContainer = Color(0xFF8B3A2A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color inversePrimary = Color(0xFFFCDFD7);
  static const Color primaryFixed = Color(0xFFFCDFD7);
  static const Color secondaryFixed = Color(0xFFFDE4B5);
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[primary, primary],
  );

  // Secondary Colors (Using Kente Gold / Accent)
  static const Color secondary = Color(0xFFE6A017);
  static const Color secondaryContainer = Color(0xFFD97706);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Tertiary Colors
  static const Color tertiary = Color(0xFF8B3A2A);
  static const Color tertiaryContainer = Color(0xFFC15A3D);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Surface Colors (Warm off-white base)
  static const Color surface = Color(0xFFFFF8F0);
  static const Color surfaceContainer = Color(0xFFF9F2EA);
  static const Color surfaceContainerHigh = Color(0xFFEFE8E0);
  static const Color surfaceContainerHighest = Color(0xFFE5DDD5);
  static const Color surfaceContainerLow = Color(0xFFFFFDFB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFFFFDFB);
  static const Color onSurface = Color(0xFF2C2418);
  static const Color onSurfaceVariant = Color(0xFF5C5243);
  static const Color inverseSurface = Color(0xFF3C3224);
  static const Color inverseOnSurface = Color(0xFFFFF8F0);

  // Status Colors
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C2418);
  static const Color textSecondary = Color(0xFF5C5243);
  
  // Accent Colors
  static const Color accentBlue = Color(0xFF0058BE);
  static const Color accentGold = Color(0xFFE6A017);

  // Neutral Colors
  static const Color outline = Color(0xFF8C8273);
  static const Color outlineVariant = Color(0xFFDDD5C9);
  static const Color borderSubtle = Color(0x0F000000); // rgba(0, 0, 0, 0.06)

  // Background
  static const Color background = Color(0xFFFFF8F0);
  static const Color onBackground = Color(0xFF2C2418);
}
