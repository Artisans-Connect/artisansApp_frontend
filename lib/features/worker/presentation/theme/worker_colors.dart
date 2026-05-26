import 'package:flutter/material.dart';

/// Design tokens from Artisans_Organized_ui/DESIGN.md (worker-local until core/theme).
abstract final class WorkerColors {
  static const background = Color(0xFFFCF8FF);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFEFECF8);
  static const surfaceContainerLow = Color(0xFFF5F2FE);
  static const surfaceContainerHigh = Color(0xFFE9E6F3);
  static const surfaceVariant = Color(0xFFE4E1ED);

  static const primary = Color(0xFF4648D4);
  static const primaryContainer = Color(0xFF6063EE);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryFixed = Color(0xFFE1E0FF);

  static const secondary = Color(0xFF0058BE);
  static const secondaryContainer = Color(0xFF2170E4);
  static const secondaryFixed = Color(0xFFD8E2FF);
  static const onSecondary = Color(0xFFFFFFFF);

  static const tertiary = Color(0xFF904900);
  static const tertiaryContainer = Color(0xFFB55D00);

  static const onSurface = Color(0xFF1B1B23);
  static const onSurfaceVariant = Color(0xFF464554);
  static const outline = Color(0xFF767586);
  static const outlineVariant = Color(0xFFC7C4D7);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF374151);
  static const accentBlue = Color(0xFF1D4ED8);

  static const success = Color(0xFF00E676);
  static const successDark = Color(0xFF34C759);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);

  static const gradientStart = Color(0xFF6366F1);
  static const gradientEnd = Color(0xFF3B82F6);

  static const cardRadius = 20.0;
  static const inputRadius = 24.0;

  static LinearGradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      );
}
