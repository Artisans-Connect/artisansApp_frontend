import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// Maps icon name strings (from the database) to PhosphorIcons constants.
/// 
/// This utility converts database icon_name values to their corresponding
/// PhosphorIcons icon constants for use throughout the frontend.
class PhosphorIconMapper {
  PhosphorIconMapper._();

  /// Maps a string icon name to a PhosphorIcons constant.
  /// 
  /// Returns [PhosphorIcons.smiley] as a safe default if the icon name is not recognized.
  /// 
  /// Example:
  /// ```dart
  /// final icon = PhosphorIconMapper.fromString('drop');
  /// // Returns PhosphorIcons.drop
  /// ```
  static IconData fromString(String? iconName) {
    if (iconName == null || iconName.isEmpty) {
      return PhosphorIcons.smiley;
    }

    switch (iconName.toLowerCase().trim()) {
      // Plumbing
      case 'drop':
        return PhosphorIcons.drop;

      // Electrical
      case 'lightning':
        return PhosphorIcons.lightning;

      // Carpentry
      case 'wrench':
        return PhosphorIcons.wrench;

      // Cleaning
      case 'broom':
        return PhosphorIcons.broom;

      // Painting
      case 'palette':
        return PhosphorIcons.palette;

      // Construction
      case 'barricade':
        return PhosphorIcons.barricade;

      // HVAC
      case 'snowflake':
        return PhosphorIcons.snowflake;

      // Landscaping
      case 'mountains':
        return PhosphorIcons.mountains;

      // Additional common icons for future use
      case 'gear':
        return PhosphorIcons.gear;
      case 'hammer':
        return PhosphorIcons.hammer;
      // case 'wrench-screwdriver':
      //   return PhosphorIcons.wrenchScrewdriver;
      case 'leaf':
        return PhosphorIcons.leaf;
      case 'plant':
        return PhosphorIcons.plant;

      // Default fallback
      default:
        return PhosphorIcons.smiley;
    }
  }

  /// All supported icon names.
  static const Set<String> supportedIcons = <String>{
    'drop',
    'lightning',
    'wrench',
    'broom',
    'palette',
    'barricade',
    'snowflake',
    'mountains',
    'gear',
    'hammer',
    'wrench-screwdriver',
    'leaf',
    'plant',
  };

  /// Checks if an icon name is supported.
  static bool isSupported(String? iconName) {
    if (iconName == null || iconName.isEmpty) return false;
    return supportedIcons.contains(iconName.toLowerCase().trim());
  }
}
