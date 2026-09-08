import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_typography.dart';

class RoleOptionCard extends StatelessWidget {
  const RoleOptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isSelected = false,
    this.isDisabled = false,
    this.statusBadge,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDisabled;
  final String? statusBadge;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      height: 180,
      decoration: BoxDecoration(
        color: isDisabled ? AppColors.surfaceDim.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDisabled
              ? AppColors.outline.withValues(alpha: 0.15)
              : isSelected
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.outline.withValues(alpha: 0.2),
          width: isSelected && !isDisabled ? 1.5 : 1.0,
        ),
        boxShadow: isDisabled
            ? const <BoxShadow>[]
            : <BoxShadow>[
                BoxShadow(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.03),
                  blurRadius: isSelected ? 24 : 10,
                  spreadRadius: isSelected ? 2 : 0,
                  offset: Offset(0, isSelected ? 8 : 4),
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: isDisabled ? 0.6 : 1.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDisabled
                                ? AppColors.surfaceDim
                                : isSelected
                                    ? AppColors.primary
                                    : AppColors.surfaceDim,
                          ),
                          child: Icon(
                            icon,
                            color: isDisabled
                                ? AppColors.textSecondary
                                : isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        style: AppTypography.displayMedium.copyWith(
                          fontSize: 32 * 0.75,
                          color: isDisabled
                              ? AppColors.textSecondary
                              : isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                        ),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOutCubic,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDisabled
                              ? AppColors.textSecondary
                              : isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary,
                        ),
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (statusBadge != null)
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDisabled
                          ? AppColors.textSecondary.withValues(alpha: 0.12)
                          : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusBadge!,
                      style: AppTypography.labelCaps.copyWith(
                        color: isDisabled ? AppColors.textSecondary : AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
                )
              else if (isSelected && !isDisabled)
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIcons.check,
                      color: AppColors.primary,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
