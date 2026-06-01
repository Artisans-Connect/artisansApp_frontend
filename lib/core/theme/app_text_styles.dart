import 'package:flutter/material.dart';
import 'app_typography.dart';

/// Backward compatibility layer forwarding legacy style definitions to [AppTypography].
/// This allows screens using AppTextStyles to compile unmodified with the new Satoshi/Clash Display font theme.
abstract final class AppTextStyles {
  static const TextStyle displayLg = AppTypography.displayLarge;
  static const TextStyle displayMd = AppTypography.displayMedium;
  static const TextStyle bodyLg = AppTypography.bodyLarge;
  static const TextStyle bodyMd = AppTypography.bodyMedium;
  static const TextStyle labelCaps = AppTypography.labelCaps;
}
