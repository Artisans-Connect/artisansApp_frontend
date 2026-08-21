import 'package:flutter/material.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? textColor;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected 
        ? (backgroundColor ?? AppColors.primary)
        : (backgroundColor ?? AppColors.surfaceContainerLow);
    
    final txtColor = isSelected
        ? (textColor ?? AppColors.onPrimary)
        : (textColor ?? AppColors.textPrimary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          border: !isSelected
              ? Border.all(color: AppColors.outlineVariant)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSpacing.iconSmall, color: txtColor),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: txtColor),
            ),
          ],
        ),
      ),
    );
  }
}
