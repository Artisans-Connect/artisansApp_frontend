import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    this.height = 200,
    this.addressLabel,
    this.showPin = true,
    this.compact = false,
    this.clientPinLabel,
    this.fillHeight = false,
  });
  final double height;
  final String? addressLabel;
  final bool showPin;
  final bool compact;
  final String? clientPinLabel;
  final bool fillHeight;
  @override
  Widget build(BuildContext context) {
    final map = Container(
      height: fillHeight ? null : height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.secondaryFixed.withValues(alpha: 0.5),
            AppColors.surfaceContainer,
          ],
        ),
      ),
      child: Stack(
        children: [
          if (!compact)
            Center(
              child: Icon(
                PhosphorIcons.mapTrifold,
                size: 72,
                color: AppColors.outline.withValues(alpha: 0.35),
              ),
            ),
          if (showPin && clientPinLabel != null)
            Positioned(
              top: 48,
              right: 32,
              child: Column(
                children: [
                  Icon(
                    PhosphorIcons.mapPin,
                    size: 40,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      clientPinLabel!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (showPin)
            Center(child: Icon(PhosphorIcons.mapPin,
                size: 36,
                color: AppColors.error,
              ),
            ),
          if (addressLabel != null && clientPinLabel == null)
            Positioned(
              bottom: compact ? 8 : 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.mapPin,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        addressLabel!,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
    if (fillHeight) {
      return map;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(
        compact ? 12 : 16.0,
      ),
      child: map,
    );
  }
}