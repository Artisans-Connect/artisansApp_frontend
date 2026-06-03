import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';

class ArtisanCard extends StatelessWidget {
  final String name;
  final String profession;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String location;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ArtisanCard({
    Key? key,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.location,
    required this.onTap,
    this.isFavorite = false,
    this.onFavoriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXLarge),
            border: Border.all(color: AppColors.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image Container
              Stack(
                children: [
                  Container(
                    height: 180,
                    width: double.infinity,
                    color: AppColors.surfaceContainer,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surfaceContainer,
                          child: Icon(
                            PhosphorIcons.user,
                            size: 80,
                            color: AppColors.outlineVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  // Favorite Button
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: GestureDetector(
                      onTap: onFavoriteTap,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          isFavorite ? PhosphorIcons.heart : PhosphorIcons.heart,
                          color: isFavorite ? Colors.red : AppColors.outlineVariant,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      profession,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.star,
                          size: 16,
                          color: const Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: AppTypography.labelMedium,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '($reviewCount)',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.mapPin,
                          size: 14,
                          color: AppColors.outlineVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: AppTypography.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
