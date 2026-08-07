import 'package:flutter/material.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/theme/app_typography.dart';
import '../../../../../shared/widgets/artisan_logo_avatar.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class WorkerPreviewCard extends StatelessWidget {
  const WorkerPreviewCard({
    super.key,
    required this.name,
    required this.profession,
    required this.imageUrl,
    required this.isVerified,
  });

  final String name;
  final String profession;
  final String imageUrl;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            ArtisanLogoAvatar(imageUrl: imageUrl, size: 56),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: AppTypography.labelLarge),
                  Text(
                    profession,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isVerified) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _UnverifiedNotice(),
        ],
      ],
    );
  }
}

class _UnverifiedNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(PhosphorIcons.warningCircle, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'This worker has not been verified yet. You can still send the request.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
