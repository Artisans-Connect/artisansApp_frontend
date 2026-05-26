import 'package:flutter/material.dart';
import 'worker_colors.dart';

abstract final class WorkerTextStyles {
  static const _fontFamily = 'Inter';

  static TextStyle get displayLg => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: WorkerColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get displayMd => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: WorkerColors.onSurface,
        height: 1.2,
      );

  static TextStyle get titleMd => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: WorkerColors.onSurface,
      );

  static TextStyle get bodyLg => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: WorkerColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodyMd => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: WorkerColors.onSurfaceVariant,
        height: 1.5,
      );

  static TextStyle get labelCaps => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: WorkerColors.onSurfaceVariant,
      );

  static TextStyle get priceTag => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: WorkerColors.accentBlue,
      );

  static TextStyle get badge => const TextStyle(
        fontFamily: _fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: WorkerColors.onPrimary,
      );
}
