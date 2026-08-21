import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:artisans_app/core/theme/app_colors.dart';
import 'package:artisans_app/core/theme/app_spacing.dart';
import 'package:artisans_app/core/theme/app_typography.dart';
import 'package:artisans_app/shared/widgets/artisan_logo_avatar.dart';

enum TradeType { electrician, plumber, carpenter, mason, painter, welder, other }

extension TradeTypeX on TradeType {
  String get label {
    switch (this) {
      case TradeType.electrician:
        return 'Electrician';
      case TradeType.plumber:
        return 'Plumber';
      case TradeType.carpenter:
        return 'Carpenter';
      case TradeType.mason:
        return 'Mason';
      case TradeType.painter:
        return 'Painter';
      case TradeType.welder:
        return 'Welder';
      case TradeType.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case TradeType.electrician:
        return Icons.bolt_rounded;
      case TradeType.plumber:
        return Icons.water_drop_rounded;
      case TradeType.carpenter:
        return Icons.handyman_rounded;
      case TradeType.mason:
        return Icons.foundation_rounded;
      case TradeType.painter:
        return Icons.format_paint_rounded;
      case TradeType.welder:
        return Icons.local_fire_department_rounded;
      case TradeType.other:
        return Icons.more_horiz_rounded;
    }
  }

  static TradeType fromString(String raw) {
    final String value = raw.toLowerCase();
    if (value.contains('electric')) return TradeType.electrician;
    if (value.contains('plumb')) return TradeType.plumber;
    if (value.contains('carpent')) return TradeType.carpenter;
    if (value.contains('mason')) return TradeType.mason;
    if (value.contains('paint')) return TradeType.painter;
    if (value.contains('weld')) return TradeType.welder;
    return TradeType.other;
  }
}

class TrustBadge extends StatelessWidget {
  const TrustBadge({
    Key? key,
    required this.label,
    required this.icon,
    required this.color,
  }) : super(key: key);

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class SelectedWorkerPreview extends StatelessWidget {
  const SelectedWorkerPreview({
    Key? key,
    required this.worker,
    required this.statusLabel,
    required this.statusColor,
    required this.statusIcon,
    required this.onOpenProfile,
    required this.onRequestWorker,
  }) : super(key: key);

  final Map<String, dynamic> worker;
  final String statusLabel;
  final Color statusColor;
  final IconData statusIcon;
  final VoidCallback onOpenProfile;
  final VoidCallback onRequestWorker;

  @override
  Widget build(BuildContext context) {
    final double? rating = worker['rating'] as double?;
    final bool isVerified = worker['verified'] == true;
    final bool isFresh = worker['hasFreshLocation'] == true;
    final bool hasMapLocation = worker['hasMapLocation'] == true;
    final TradeType tradeType =
        worker['tradeType'] as TradeType? ?? TradeType.other;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ArtisanLogoAvatar(
                imageUrl: worker['imageUrl'] as String?,
                size: 54,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker['name'].toString(),
                      style: AppTypography.labelLarge,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          tradeType.icon,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            worker['profession'].toString(),
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              TrustBadge(
                label: statusLabel,
                icon: statusIcon,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              TrustBadge(
                label: worker['distance'].toString(),
                icon: PhosphorIcons.mapPin,
                color: AppColors.primary,
              ),
              if (rating != null)
                TrustBadge(
                  label: rating.toStringAsFixed(1),
                  icon: PhosphorIcons.star,
                  color: AppColors.accentGold,
                ),
              if (isVerified)
                TrustBadge(
                  label: 'Verified',
                  icon: PhosphorIcons.sealCheck,
                  color: AppColors.success,
                ),
              TrustBadge(
                label: !hasMapLocation
                    ? 'Location not shared'
                    : isFresh
                        ? 'Fresh location'
                        : 'Stale location',
                icon: PhosphorIcons.mapPin,
                color: hasMapLocation && isFresh
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ],
          ),
          if (!hasMapLocation) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.wifiSlash,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'This artisan is offline and not sharing live location. '
                      'Open their profile to view details and reach out.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              if (hasMapLocation) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onOpenProfile,
                    icon: Icon(PhosphorIcons.user),
                    label: const Text('Profile'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onRequestWorker,
                    icon: Icon(PhosphorIcons.paperPlaneTilt),
                    label: const Text('Request'),
                  ),
                ),
              ] else
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onOpenProfile,
                    icon: Icon(PhosphorIcons.user),
                    label: const Text('View profile & contact'),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
