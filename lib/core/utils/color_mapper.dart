import 'package:flutter/material.dart';

/// Maps hex color strings (from the database) to Flutter Color objects.
/// 
/// This utility converts database color_hex values to their corresponding
/// Flutter Color objects for use throughout the frontend.
class ColorMapper {
  ColorMapper._();

  /// Default color to use when color conversion fails.
  static const Color defaultColor = Color(0xFF4648D4);

  /// Converts a hex color string to a Flutter Color object.
  /// 
  /// Accepts hex strings in the following formats:
  /// - '#RRGGBB' (e.g., '#FF5733')
  /// - '#AARRGGBB' (e.g., '#80FF5733')
  /// - 'RRGGBB' (e.g., 'FF5733')
  /// 
  /// Returns [defaultColor] if the string is invalid or null.
  /// 
  /// Example:
  /// ```dart
  /// final color = ColorMapper.fromHex('#4648D4');
  /// // Returns Color(0xFF4648D4)
  /// ```
  static Color fromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) {
      return defaultColor;
    }

    try {
      // Remove '#' if present
      String hex = hexString.replaceFirst('#', '');

      // Pad to 8 characters (AARRGGBB) if necessary
      if (hex.length == 6) {
        hex = 'FF$hex';
      }

      // Validate hex format
      if (hex.length != 8 || !_isValidHex(hex)) {
        return defaultColor;
      }

      // Convert hex string to Color
      return Color(int.parse('0x$hex'));
    } catch (e) {
      return defaultColor;
    }
  }

  /// Checks if a string contains only valid hex characters (0-9, A-F).
  static bool _isValidHex(String hex) {
    return RegExp(r'^[0-9A-Fa-f]{8}$').hasMatch(hex);
  }

  /// Validates a hex color string without converting it.
  /// 
  /// Returns true if the string is a valid hex color format.
  static bool isValidHexColor(String? hexString) {
    if (hexString == null || hexString.isEmpty) return false;

    String hex = hexString.replaceFirst('#', '');

    if (hex.length != 6 && hex.length != 8) return false;

    return _isValidHex(hex.length == 6 ? 'FF$hex' : hex);
  }

  /// Common category colors (for reference).
  static const Map<String, String> categoryColors = <String, String>{
    'plumbing': '#4648D4',
    'electrical': '#0058BE',
    'carpentry': '#B55D00',
    'masonry': '#8B5E3C',
    'welding': '#607D8B',
    'construction': '#FF9800',
    'automotive': '#795548',
    'painting': '#F44336',
    'tiling': '#009688',
    'roofing': '#9C27B0',
    'hvac': '#2196F3',
    'appliance_repair': '#3F51B5',
    'cleaning': '#00A86B',
    'landscaping': '#4CAF50',
    'fashion': '#E91E63',
    'beauty': '#AD1457',
    'catering': '#C15A3D',
    'upholstery': '#6D4C41',
    'security': '#455A64',
    'ict_support': '#1565C0',
  };

  /// Gets the color for a specific category slug.
  /// 
  /// Returns a Color object for the given category slug.
  /// Returns [defaultColor] if the category is not found.
  static Color forCategory(String? categorySlug) {
    if (categorySlug == null) return defaultColor;
    
    final String? hexColor = categoryColors[categorySlug.toLowerCase()];
    return fromHex(hexColor);
  }
}
