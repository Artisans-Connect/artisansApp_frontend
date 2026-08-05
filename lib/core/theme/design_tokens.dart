import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class DesignTokens {
  const DesignTokens._();

  static const Color background = AppColors.background;
  static const Color surfaceBase = AppColors.surface;
  static const Color surfaceCard = AppColors.surfaceContainerLowest;
  static const Color surfaceHighlight = Color(0xFFF8F2E8);
  static const Color primary = AppColors.primary;
  static const Color primaryDark = AppColors.primaryContainer;
  static const Color accentGold = AppColors.accentGold;
  static const Color accentWarm = AppColors.secondaryContainer;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textMuted = Color(0xFF9B8F83);
  static const Color borderSubtle = AppColors.borderSubtle;
  static const Color successGreen = AppColors.success;
  static const Color error = AppColors.error;

  static const Color primaryContainer = AppColors.primaryFixed;
  static const Color primaryTint08 = Color(0x14C15A3D);
  static const Color primaryTint12 = Color(0x1FC15A3D);
  static const Color primaryTint16 = Color(0x29C15A3D);
  static const Color goldTint12 = Color(0x1FE6A017);
  static const Color warmTint = Color(0xFFF4EDE6);
  static const Color warmSurface = Color(0xFFFAF2EA);
  static const Color warmBorder = Color(0xFFE8D5CB);
  static const Color offlineSurface = Color(0xFFE8DDD4);
  static const Color shadowMid = Color(0x0A2C2418);
  static const Color shadowDeep = Color(0x142C2418);
  static const Color shadow = Color(0x0D2C2418);

  static const double radiusSm = AppSpacing.radiusSmall;
  static const double radiusMd = AppSpacing.radiusLarge;
  static const double radiusLg = AppSpacing.radiusXLarge;
  static const double radiusXl = 20;
  static const double radiusFull = AppSpacing.radiusCircle;

  static const double xs = AppSpacing.xs;
  static const double sm = AppSpacing.sm;
  static const double md = AppSpacing.md;
  static const double lg = AppSpacing.lg;
  static const double xl = AppSpacing.xl;
  static const double gutter = AppSpacing.gutter;
}
