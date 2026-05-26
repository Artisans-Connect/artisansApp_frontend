import 'package:flutter/material.dart';
import '../theme/worker_colors.dart';
import '../theme/worker_text_styles.dart';

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
            WorkerColors.secondaryFixed.withOpacity(0.5),
            WorkerColors.surfaceContainer,
          ],
        ),
      ),
      child: Stack(
        children: [
          if (!compact)
            Center(
              child: Icon(
                Icons.map_outlined,
                size: 72,
                color: WorkerColors.outline.withOpacity(0.35),
              ),
            ),
          if (showPin && clientPinLabel != null)
            Positioned(
              top: 48,
              right: 32,
              child: Column(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 40,
                    color: WorkerColors.error,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: WorkerColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Text(
                      clientPinLabel!,
                      style: WorkerTextStyles.badge.copyWith(
                        color: WorkerColors.error,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else if (showPin)
            const Center(
              child: Icon(
                Icons.location_on,
                size: 36,
                color: WorkerColors.error,
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
                  color: WorkerColors.surface.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.place_outlined,
                      size: 18,
                      color: WorkerColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        addressLabel!,
                        style: WorkerTextStyles.bodyMd.copyWith(
                          color: WorkerColors.onSurface,
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
        compact ? 12 : WorkerColors.cardRadius,
      ),
      child: map,
    );
  }
}
