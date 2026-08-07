import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';

class ExploreEmptyState extends StatelessWidget {
  const ExploreEmptyState({
    super.key,
    required this.hasCategory,
    required this.onClearFilters,
    required this.onShowAll,
  });

  final bool hasCategory;
  final VoidCallback onClearFilters;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(PhosphorIcons.magnifyingGlass, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Text('No matching artisans yet', style: AppTypography.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasCategory
                ? 'Try clearing filters or browsing all artisans while more workers add this service.'
                : 'Try clearing filters or refreshing the list.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(PhosphorIcons.x, size: 16),
                label: const Text('Clear filters'),
              ),
              FilledButton.icon(
                onPressed: onShowAll,
                icon: const Icon(PhosphorIcons.users, size: 16),
                label: const Text('Show all'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
