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
      case 'plumbing':
        return PhosphorIcons.drop;

      // Electrical
      case 'lightning':
      case 'electrical':
      case 'electrical_services':
        return PhosphorIcons.lightning;

      // Carpentry
      case 'carpenter':
      case 'wrench':
        return PhosphorIcons.wrench;

      // Cleaning
      case 'broom':
      case 'cleaning':
      case 'cleaning_services':
        return PhosphorIcons.broom;

      // Painting
      case 'format_paint':
      case 'palette':
        return PhosphorIcons.palette;

      // Construction
      case 'barricade':
      case 'construction':
        return PhosphorIcons.barricade;

      // Masonry
      case 'bricks':
      case 'masonry':
      case 'blockwork':
        return PhosphorIcons.wall;

      // Welding
      case 'fire':
      case 'welding':
        return PhosphorIcons.fire;

      // Automotive
      case 'car':
      case 'automotive':
        return PhosphorIcons.car;

      // Tiling
      case 'squares_four':
      case 'squaresfour':
      case 'tiling':
        return PhosphorIcons.squaresFour;

      // Roofing
      case 'house_line':
      case 'houseline':
      case 'roofing':
        return PhosphorIcons.houseLine;

      // HVAC
      case 'hvac':
      case 'snowflake':
        return PhosphorIcons.snowflake;

      // Appliance and electronics repair
      case 'plug':
      case 'appliance_repair':
      case 'appliance repair':
        return PhosphorIcons.plug;

      // Landscaping
      case 'grass':
      case 'landscaping':
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
      case 'scissors':
      case 'fashion':
      case 'beauty':
        return PhosphorIcons.scissors;
      case 'fork_knife':
      case 'forkknife':
      case 'catering':
        return PhosphorIcons.forkKnife;
      case 'armchair':
      case 'upholstery':
        return PhosphorIcons.armchair;
      case 'lock_key':
      case 'lockkey':
      case 'security':
        return PhosphorIcons.lockKey;
      case 'desktop_tower':
      case 'desktoptower':
      case 'ict_support':
        return PhosphorIcons.desktopTower;

      // Default fallback
      default:
        return PhosphorIcons.smiley;
    }
  }

  /// All supported icon names.
  static const Set<String> supportedIcons = <String>{
    'drop',
    'plumbing',
    'lightning',
    'electrical',
    'electrical_services',
    'carpenter',
    'wrench',
    'broom',
    'cleaning',
    'cleaning_services',
    'format_paint',
    'palette',
    'barricade',
    'construction',
    'bricks',
    'masonry',
    'blockwork',
    'fire',
    'welding',
    'car',
    'automotive',
    'squares_four',
    'squaresfour',
    'tiling',
    'house_line',
    'houseline',
    'roofing',
    'hvac',
    'snowflake',
    'plug',
    'appliance_repair',
    'grass',
    'landscaping',
    'mountains',
    'gear',
    'hammer',
    'wrench-screwdriver',
    'leaf',
    'plant',
    'scissors',
    'fashion',
    'beauty',
    'fork_knife',
    'forkknife',
    'catering',
    'armchair',
    'upholstery',
    'lock_key',
    'lockkey',
    'security',
    'desktop_tower',
    'desktoptower',
    'ict_support',
  };

  /// Checks if an icon name is supported.
  static bool isSupported(String? iconName) {
    if (iconName == null || iconName.isEmpty) return false;
    return supportedIcons.contains(iconName.toLowerCase().trim());
  }
}
