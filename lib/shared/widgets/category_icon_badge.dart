import 'package:flutter/material.dart';

import 'package:artisans_app/core/utils/color_mapper.dart';
import 'package:artisans_app/core/utils/icon_mapper.dart';

class CategoryIconBadge extends StatelessWidget {
  const CategoryIconBadge({
    super.key,
    required this.iconName,
    required this.colorHex,
    this.size = 44,
  });

  final String? iconName;
  final String? colorHex;
  final double size;

  @override
  Widget build(BuildContext context) {
    final Color color = ColorMapper.fromHex(colorHex);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        PhosphorIconMapper.fromString(iconName),
        color: color,
        size: size * 0.52,
      ),
    );
  }
}
