import 'package:flutter/material.dart';

import 'package:artisans_app/core/theme/design_tokens.dart';

// ---------------------------------------------------------------------------
// Status pill helpers
// ---------------------------------------------------------------------------

String statusPillLabel(String? statusRaw) {
  return switch ((statusRaw ?? '').toLowerCase()) {
    'on_the_way' => 'On the Way',
    'arrived' => 'Arrived',
    'in_progress' => 'In Progress',
    'termination_requested' => 'Termination Requested',
    'pending_client_approval' => 'Pending Approval',
    'completed' => 'Completed',
    'cancelled' => 'Cancelled',
    'matched' => 'Matched',
    'scheduled_confirmed' => 'Scheduled',
    _ => 'Pending',
  };
}

Color statusPillColor(String? statusRaw) {
  return switch ((statusRaw ?? '').toLowerCase()) {
    'completed' => DesignTokens.accentGold.withAlpha((0.2 * 255).round()),
    'pending_client_approval' => DesignTokens.accentGold.withAlpha((0.2 * 255).round()),
    'termination_requested' => DesignTokens.error.withAlpha((0.2 * 255).round()),
    'in_progress' => Colors.white.withAlpha((0.18 * 255).round()),
    _ => Colors.white.withAlpha((0.14 * 255).round()),
  };
}

Color statusPillTextColor(String? statusRaw) {
  return switch ((statusRaw ?? '').toLowerCase()) {
    'completed' => DesignTokens.accentGold,
    'pending_client_approval' => DesignTokens.accentGold,
    'termination_requested' => DesignTokens.error,
    _ => Colors.white,
  };
}

// ---------------------------------------------------------------------------
// TrackingJobInfoCard
// ---------------------------------------------------------------------------

class TrackingJobInfoCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final String etaLabel;

  const TrackingJobInfoCard({
    super.key,
    required this.job,
    required this.etaLabel,
  });

  @override
  Widget build(BuildContext context) {
    final String pillLabel = statusPillLabel(job['status'] as String?);
    final Color pillBg = statusPillColor(job['status'] as String?);
    final Color pillText = statusPillTextColor(job['status'] as String?);

    Widget infoText(IconData icon, String label, String value) {
      return Expanded(
        child: Row(
          children: [
            Icon(icon, size: 14, color: Colors.white70),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$label: $value',
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [DesignTokens.primary, DesignTokens.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: DesignTokens.primary.withAlpha((0.16 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24,
            right: -22,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha((0.06 * 255).round()),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (job['title'] as String? ?? 'Your Job')
                                .toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            job['artisan'] as String? ?? 'Artisan',
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            job['profession'] as String? ?? 'Service provider',
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        pillLabel,
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: pillText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    infoText(Icons.access_time_rounded, 'ETA', etaLabel),
                    const SizedBox(width: 12),
                    if (job['phone'] != null)
                      infoText(
                          Icons.phone_rounded, 'Phone', job['phone'] as String),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
