import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import 'artisan_detail_sheet.dart'; // For TradeTypeX

class MapContextPill extends StatelessWidget {
  const MapContextPill({
    Key? key,
    required this.selectedCategoryId,
    required this.categories,
    required this.locationUnavailable,
    required this.radiusKm,
  }) : super(key: key);

  final String? selectedCategoryId;
  final List<Map<String, dynamic>> categories;
  final bool locationUnavailable;
  final double radiusKm;

  @override
  Widget build(BuildContext context) {
    String categoryLabel = 'All services';
    if (selectedCategoryId != null) {
      for (final category in categories) {
        if (category['id'].toString() == selectedCategoryId) {
          categoryLabel = category['name'].toString();
          break;
        }
      }
    }
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmShadow,
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(PhosphorIcons.crosshair, color: AppColors.primary, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              locationUnavailable
                  ? 'Enable location to find nearby artisans'
                  : '$categoryLabel within ${radiusKm.toStringAsFixed(0)} km',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapOverlayControls extends StatelessWidget {
  const MapOverlayControls({
    Key? key,
    required this.selectedCategoryId,
    required this.selectedCategoryName,
    required this.categories,
    required this.loadingCategories,
    required this.radiusKm,
    required this.onCategorySelected,
    required this.onRadiusSelected,
  }) : super(key: key);

  final String? selectedCategoryId;
  final String selectedCategoryName;
  final List<Map<String, dynamic>> categories;
  final bool loadingCategories;
  final double radiusKm;
  final ValueChanged<String?> onCategorySelected;
  final ValueChanged<double> onRadiusSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        border: Border.all(color: AppColors.warmBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.warmShadow,
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.primaryTint08,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PhosphorIcons.magnifyingGlass,
                  size: 17,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  selectedCategoryId == null
                      ? 'Search services nearby'
                      : selectedCategoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                MapControlChip(
                  label: 'All',
                  icon: Icons.more_horiz_rounded,
                  selected: selectedCategoryId == null,
                  onTap: () => onCategorySelected(null),
                ),
                ...categories.map(
                  (category) {
                    final id = category['id'].toString();
                    return MapControlChip(
                      label: category['name'].toString(),
                      icon: TradeTypeX.fromString(
                        category['name'].toString(),
                      ).icon,
                      selected: selectedCategoryId == id,
                      onTap: () => onCategorySelected(id),
                    );
                  },
                ),
                if (loadingCategories)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: <double>[5, 10, 15].map((radius) {
              return MapControlChip(
                label: '${radius.toStringAsFixed(0)} km',
                icon: PhosphorIcons.crosshair,
                selected: radiusKm == radius,
                dense: true,
                onTap: () => onRadiusSelected(radius),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class MapControlChip extends StatelessWidget {
  const MapControlChip({
    Key? key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.dense = false,
  }) : super(key: key);

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: dense ? AppSpacing.xs : AppSpacing.sm),
      child: ChoiceChip(
        avatar: Icon(
          icon,
          size: 15,
          color: selected ? AppColors.onPrimary : AppColors.textSecondary,
        ),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: selected ? AppColors.onPrimary : AppColors.textSecondary,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.surfaceContainerLowest,
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : AppColors.borderSubtle,
        ),
        visualDensity: dense ? VisualDensity.compact : VisualDensity.standard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
