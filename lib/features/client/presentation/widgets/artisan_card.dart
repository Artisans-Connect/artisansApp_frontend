import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/artisan_logo_avatar.dart';

class ArtisanCard extends StatelessWidget {
  static const double _imageHeight = 160;

  final String name;
  final String profession;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String location;
  final VoidCallback onTap;

  const ArtisanCard({
    Key? key,
    required this.name,
    required this.profession,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.location,
    required this.onTap,
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
                    height: _imageHeight,
                    width: double.infinity,
                    color: AppColors.surfaceContainer,
                    child: ArtisanLogoPanel(
                      imageUrl: imageUrl,
                      height: _imageHeight,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              // Details
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profession,
                      style: AppTypography.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.star,
                          size: 16,
                          color: const Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: AppTypography.labelMedium,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '($reviewCount)',
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
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
