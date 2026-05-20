import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double? size;
  final bool showCount;

  const RatingWidget({
    Key? key,
    required this.rating,
    required this.reviewCount,
    this.size = 16,
    this.showCount = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star_rounded,
          size: size,
          color: const Color(0xFFFFC107),
        ),
        const SizedBox(width: 4),
        Text(
          rating.toString(),
          style: AppTypography.labelMedium,
        ),
        if (showCount) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            '($reviewCount)',
            style: AppTypography.bodySmall,
          ),
        ],
      ],
    );
  }
}
