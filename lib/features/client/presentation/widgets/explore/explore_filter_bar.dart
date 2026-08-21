import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/filter_chip.dart';

class ExploreFilterBar extends StatelessWidget {
  const ExploreFilterBar({
    super.key,
    required this.selectedCategory,
    required this.selectedDistance,
    required this.selectedRating,
    required this.onClearCategory,
    required this.onDistanceSelected,
    required this.onRatingSelected,
    required this.onClearFilters,
    required this.onShowAll,
  });

  final String selectedCategory;
  final String selectedDistance;
  final String selectedRating;
  final VoidCallback onClearCategory;
  final ValueChanged<String> onDistanceSelected;
  final ValueChanged<String> onRatingSelected;
  final VoidCallback onClearFilters;
  final VoidCallback onShowAll;

  bool get _hasFilters =>
      selectedCategory.isNotEmpty ||
      selectedDistance.isNotEmpty ||
      selectedRating.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Refine results',
                style: AppTypography.labelLarge,
              ),
            ),
            if (_hasFilters)
              TextButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(PhosphorIcons.x, size: 16),
                label: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: <Widget>[
            if (selectedCategory.isNotEmpty)
              AppFilterChip(
                label: selectedCategory,
                isSelected: true,
                icon: PhosphorIcons.funnel,
                onTap: onClearCategory,
              )
            else
              AppFilterChip(
                label: 'All services',
                isSelected: true,
                icon: PhosphorIcons.squaresFour,
                onTap: onShowAll,
              ),
            ...<String>['Nearby', '< 5 km', '< 10 km', '< 30 km', '< 50 km']
                .map(
              (String distance) => AppFilterChip(
                label: distance,
                isSelected: selectedDistance == distance,
                icon: PhosphorIcons.mapPin,
                onTap: () => onDistanceSelected(distance),
              ),
            ),
            ...<String>['4.5+', '4.7+', '4.9+'].map(
              (String rating) => AppFilterChip(
                label: rating,
                isSelected: selectedRating == rating,
                icon: PhosphorIcons.star,
                onTap: () => onRatingSelected(rating),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
