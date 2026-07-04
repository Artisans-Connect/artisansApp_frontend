import 'package:flutter/material.dart';

import '../../../../../core/theme/design_tokens.dart';
import '../../../../../shared/widgets/worker_tracking_map.dart';
import 'tracking_atoms.dart';

// ---------------------------------------------------------------------------
// TrackingMapCard – live map with worker location
// ---------------------------------------------------------------------------

class TrackingMapCard extends StatelessWidget {
  final String workerId;
  final double jobLat;
  final double jobLng;
  final ValueChanged<String> onEtaChanged;

  const TrackingMapCard({
    super.key,
    required this.workerId,
    required this.jobLat,
    required this.jobLng,
    required this.onEtaChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Icon(Icons.map_rounded, size: 16, color: DesignTokens.primary),
                const SizedBox(width: 6),
                const Text(
                  'Live Location',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const Spacer(),
                const LiveDot(),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: WorkerTrackingMap(
              workerId: workerId,
              jobLat: jobLat,
              jobLng: jobLng,
              onEtaChanged: onEtaChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TrackingMapPlaceholder – shown when worker location is not yet available
// ---------------------------------------------------------------------------

class TrackingMapPlaceholder extends StatelessWidget {
  const TrackingMapPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_searching_rounded,
                size: 36, color: DesignTokens.textSecondary.withValues(alpha: 0.4)),
            const SizedBox(height: 10),
            Text(
              'Waiting for artisan location…',
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 13,
                color: DesignTokens.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
