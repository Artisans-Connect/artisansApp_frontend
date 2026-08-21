import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import 'package:artisans_app/core/services/pricing_service.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';

class FeeSummaryCard extends StatelessWidget {
  const FeeSummaryCard({
    super.key,
    required this.estimate,
    required this.estimating,
    required this.estimateFailed,
  });

  final FeeEstimate? estimate;
  final bool estimating;
  final bool estimateFailed;

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
        children: <Widget>[
          const Icon(PhosphorIcons.currencyCircleDollar, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: estimating
                ? Row(
                    children: <Widget>[
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Calculating estimate...',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : estimate != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Estimated minimum: ${estimate!.formatGhs(estimate!.minimumFee)}',
                            style: AppTypography.labelLarge,
                          ),
                          Text(
                            'Final price is confirmed by the artisan\'s quote.',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        estimateFailed
                            ? 'Could not load a fee estimate. A minimum budget will be used.'
                            : 'Select a service to see the fee estimate.',
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
