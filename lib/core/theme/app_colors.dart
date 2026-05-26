import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFCF8FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFF5F2FE);
  static const Color textPrimary = Color(0xFF1B1B23);
  static const Color textSecondary = Color(0xFF464554);
  static const Color outline = Color(0xFFC7C4D7);
  static const Color primary = Color(0xFF4648D4);
  static const Color secondary = Color(0xFF2170E4);
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFBA1A1A);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF6366F1), Color(0xFF3B82F6)],
  );
}
