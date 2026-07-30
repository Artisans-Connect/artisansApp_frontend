import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/workers_service.dart';
import '../models/worker_job.dart';
import '../models/worker_stats.dart';
import '../state/worker_session_state.dart';
import '../utils/worker_job_mapper.dart';
import '../widgets/skeleton_box.dart';
import '../../../../shared/widgets/app_toast.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../../../shared/widgets/job_requests_map.dart';
import '../../../../shared/widgets/category_icon_badge.dart';
import 'job_request_detail_screen.dart';
import 'worker_application_detail_screen.dart';
import 'worker_booking_history_screen.dart';
import 'worker_earnings_screen.dart';
import 'worker_gallery_screen.dart';
import 'worker_reviews_screen.dart';
import '../utils/worker_application_navigation.dart';
import '../../../../core/session/app_user_session.dart';
import '../../../../core/theme/design_tokens.dart';
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CategoryIconBadge(
              iconName: category is Map ? category['icon_name']?.toString() : null,
              colorHex: category is Map ? category['color_hex']?.toString() : null,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (job['title'] ?? 'Job application').toString(),
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryName · ${job['address_label'] ?? 'Location pending'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                  if (budget != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      'Budget: GHS $budget',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.primary,
                      ),
                    ),
                  ],
                  if (clientEstimate != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      'Client estimate: GHS $clientEstimate',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                  if (totalQuote != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      'Your quote: GHS ${totalQuote.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
 
/// Premium availability toggle card.
class _AvailabilityCard extends StatelessWidget {
  const _AvailabilityCard({
    required this.isAvailable,
    required this.onChanged,
    required this.lastCheckedAt,
    required this.isSilentRefreshing,
    required this.isAvailabilityLoading,
  });
 
  final bool isAvailable;
  final ValueChanged<bool>? onChanged;
  final DateTime? lastCheckedAt;
  final bool isSilentRefreshing;
  final bool isAvailabilityLoading;
 
  String get _checkedLabel {
    if (lastCheckedAt == null) return '';
    final Duration age = DateTime.now().difference(lastCheckedAt!);
    if (age.inSeconds < 5) return 'just now';
    if (age.inSeconds < 60) return '${age.inSeconds}s ago';
    return '${age.inMinutes}m ago';
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(DesignTokens.md),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(
          color: isAvailable ? DesignTokens.primaryTint16 : DesignTokens.borderSubtle,
          width: isAvailable ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Top row — label + toggle
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'AVAILABILITY',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.08,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        isAvailabilityLoading
                            ? 'Checking availability...'
                            : isAvailable
                                ? 'Online & available'
                                : 'Offline',
                        key: ValueKey<String>(
                          '$isAvailabilityLoading-$isAvailable',
                        ),
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isAvailable
                              ? DesignTokens.successGreen
                              : DesignTokens.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isAvailable,
                onChanged: isAvailabilityLoading ? null : onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: DesignTokens.successGreen,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: DesignTokens.offlineSurface,
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Bottom row — pulse dot + meta + last checked
          Row(
            children: <Widget>[
              _PulseDot(online: isAvailable),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  isAvailable
                      ? 'Receiving nearby requests'
                      : 'Not receiving requests',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isAvailable ? DesignTokens.textSecondary : DesignTokens.textMuted,
                  ),
                ),
              ),
              if (isSilentRefreshing)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(DesignTokens.primary),
                  ),
                )
              else if (lastCheckedAt != null)
                Text(
                  _checkedLabel,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11,
                    color: DesignTokens.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
 
/// Section header row with optional count badge.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label, this.count});
  final String label;
  final int? count;
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.08,
            color: DesignTokens.textSecondary,
          ),
        ),
        if (count != null) ...<Widget>[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
            decoration: BoxDecoration(
              color: DesignTokens.primary,
              borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
 
/// Tag chip — small pill label on the job card.
class _JobTag extends StatelessWidget {
  const _JobTag({required this.label, this.isDistance = false});
  final String label;
  final bool isDistance;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDistance ? DesignTokens.warmTint : DesignTokens.surfaceBase,
        borderRadius: BorderRadius.circular(DesignTokens.radiusFull),
        border: Border.all(
          color: isDistance ? DesignTokens.warmBorder : DesignTokens.borderSubtle,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isDistance ? DesignTokens.primaryDark : DesignTokens.textSecondary,
        ),
      ),
    );
  }
}
 
/// Premium job request card.
class _RequestJobCard extends StatelessWidget {
  const _RequestJobCard({
    required this.job,
    required this.onViewDetails,
    required this.onAccept,
  });
 
  final WorkerJob job;
  final VoidCallback onViewDetails;
  final VoidCallback onAccept;
 
  /// Relative time from a DateTime.
  String _relativeTime(DateTime? dt) {
    if (dt == null) return '';
    final Duration age = DateTime.now().difference(dt);
    if (age.inSeconds < 60) return '${age.inSeconds}s ago';
    if (age.inMinutes < 60) return '${age.inMinutes}m ago';
    return '${age.inHours}h ago';
  }
 
  @override
  Widget build(BuildContext context) {
    final double? totalQuote = job.applicationTotalQuote;
    final String clientEstimate = job.estimateDisplay;
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        children: <Widget>[
          // ── Top: avatar + name + description + time ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                CategoryIconBadge(
                  iconName: job.categoryIconName,
                  colorHex: job.categoryColorHex,
                  size: 46,
                ),
                const SizedBox(width: 12),
                // Name + description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        job.clientName,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        job.description,
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 12,
                          color: DesignTokens.textSecondary,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Relative timestamp
                Text(
                  _relativeTime(job.createdAt),
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11,
                    color: DesignTokens.textMuted,
                  ),
                ),
              ],
            ),
          ),
 
          // ── Tags row ──
          if (_tagsFor(job).isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _tagsFor(job),
            ),
          ),
          if (clientEstimate != 'â€”' && clientEstimate.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.request_quote_rounded,
                    size: 16,
                    color: DesignTokens.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Client estimate: $clientEstimate',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (totalQuote != null) ...<Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.payments_rounded,
                    size: 16,
                    color: DesignTokens.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Your proposed quote: ${_formatGhs(totalQuote)}',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
 
          // ── Divider ──
          const Divider(height: 1, thickness: 0.5, color: DesignTokens.borderSubtle),
 
          // ── Actions row ──
          IntrinsicHeight(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: onViewDetails,
                    style: TextButton.styleFrom(
                      foregroundColor: DesignTokens.textSecondary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(DesignTokens.radiusXl),
                        ),
                      ),
                    ),
                    child: const Text(
                      'View details',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(
                  width: 0.5,
                  thickness: 0.5,
                  color: DesignTokens.borderSubtle,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: onAccept,
                    style: TextButton.styleFrom(
                      foregroundColor: DesignTokens.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(DesignTokens.radiusXl),
                        ),
                      ),
                    ),
                    child: const Text(
                      'Accept →',
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
 
  List<Widget> _tagsFor(WorkerJob job) {
    final List<Widget> tags = <Widget>[];
    if (job.trade != null) tags.add(_JobTag(label: job.trade!));
    if (job.distanceKm != null) {
      tags.add(_JobTag(
        label: '${job.distanceKm!.toStringAsFixed(1)} km',
        isDistance: true,
      ));
    }
    if (job.area != null) tags.add(_JobTag(label: job.area!));
    return tags;
  }

  String _formatGhs(double amount) => 'GHS ${amount.toStringAsFixed(2)}';
}
 
class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();
 
  String _firstName() {
    final String fullName = AppUserSession.instance.currentUser?.fullName ?? '';
    final List<String> parts = fullName.trim().split(' ');
    return parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : '';
  }
 
  String _greeting() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
 
  String _subtitle() {
    final int hour = DateTime.now().hour;
    if (hour < 12) return 'Ready to earn today?';
    if (hour < 17) return 'Let\'s find you your next client.';
    return 'Keep up the great work!';
  }
 
  @override
  Widget build(BuildContext context) {
    final String firstName = _firstName();
    final String greeting = _greeting();
    final String subtitle = _subtitle();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          firstName.isNotEmpty ? '$greeting, $firstName' : greeting,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: DesignTokens.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$subtitle',
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 14,
            color: DesignTokens.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
 
class _QuickAccessSection extends StatelessWidget {
  const _QuickAccessSection({
    required this.onOpenEarnings,
    required this.onOpenReviews,
    required this.onOpenGallery,
    required this.onOpenHistory,
  });
 
  final VoidCallback onOpenEarnings;
  final VoidCallback onOpenReviews;
  final VoidCallback onOpenGallery;
  final VoidCallback onOpenHistory;
 
  @override
  Widget build(BuildContext context) {
    final double itemWidth =
        (MediaQuery.of(context).size.width - DesignTokens.gutter * 2 - DesignTokens.md) /
            2;

    return Wrap(
      spacing: DesignTokens.md,
      runSpacing: DesignTokens.md,
      children: <Widget>[
        _QuickAccessTile(
          icon: Icons.payments_rounded,
          label: 'Earnings',
          width: itemWidth,
          onTap: onOpenEarnings,
        ),
        _QuickAccessTile(
          icon: Icons.rate_review,
          label: 'Reviews',
          width: itemWidth,
          onTap: onOpenReviews,
        ),
        _QuickAccessTile(
          icon: Icons.photo_library,
          label: 'Gallery',
          width: itemWidth,
          onTap: onOpenGallery,
        ),
        _QuickAccessTile(
          icon: Icons.history,
          label: 'History',
          width: itemWidth,
          onTap: onOpenHistory,
        ),
      ],
    );
  }
}
 
class _QuickAccessTile extends StatelessWidget {
  const _QuickAccessTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.width,
  });
 
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double width;
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Open',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: DesignTokens.primary.withAlpha(24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: DesignTokens.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
class _PerformanceOverviewCard extends StatelessWidget {
  const _PerformanceOverviewCard({
    required this.stats,
    required this.totalEarnings,
    required this.isLoading,
  });
 
  final WorkerStats? stats;
  final double? totalEarnings;
  final bool isLoading;
 
  @override
  Widget build(BuildContext context) {
    final List<Map<String, Object>> items = <Map<String, Object>>[
      {
        'label': 'Jobs Completed',
        'value': stats != null ? '${stats!.totalJobs}' : '--',
        'color': DesignTokens.primaryContainer.withOpacity(0.16),
      },
      {
        'label': 'Average Rating',
        'value': stats != null ? '⭐ ${stats!.rating.toStringAsFixed(1)}' : '--',
        'color': DesignTokens.accentGold.withOpacity(0.16),
      },
      {
        'label': 'Response Rate',
        'value': stats?.responseLabel ?? '--',
        'color': DesignTokens.accentWarm.withOpacity(0.16),
      },
      {
        'label': 'Acceptance Rate',
        'value': '--',
        'color': DesignTokens.successGreen.withOpacity(0.16),
      },
      {
        'label': 'Completion Rate',
        'value': '--',
        'color': DesignTokens.warmSurface,
      },
      {
        'label': 'Total Earnings',
        'value': totalEarnings != null
            ? 'GH₵${totalEarnings!.toStringAsFixed(2)}'
            : '--',
        'color': DesignTokens.primary.withOpacity(0.12),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(DesignTokens.lg),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: DesignTokens.shadowMid,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Performance Overview',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.sm),
          const Text(
            'Keep your performance metrics live and visible.',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: DesignTokens.md),
          if (isLoading)
            const LinearProgressIndicator(
              minHeight: 3,
            ),
          if (isLoading) const SizedBox(height: DesignTokens.md),
          Wrap(
            spacing: DesignTokens.md,
            runSpacing: DesignTokens.md,
            children: items
                .map(
                  (Map<String, Object> item) => _MetricTile(
                    label: item['label'] as String,
                    value: item['value'] as String,
                    color: item['color'] as Color,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
 
class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });
 
  final String label;
  final String value;
  final Color color;
 
  @override
  Widget build(BuildContext context) {
    final double width = (MediaQuery.of(context).size.width - DesignTokens.gutter * 2 - DesignTokens.md * 2) / 3;

    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 12,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
 
class _NearbyJobsSection extends StatelessWidget {
  const _NearbyJobsSection({
    required this.isOnline,
    required this.isSearching,
    required this.jobs,
    required this.lastCheckedAt,
    required this.onGoOnline,
    required this.onStartMatching,
    required this.onViewDetails,
    required this.onDecline,
  });
 
  final bool isOnline;
  final bool isSearching;
  final List<WorkerJob> jobs;
  final DateTime? lastCheckedAt;
  final VoidCallback onGoOnline;
  final VoidCallback onStartMatching;
  final ValueChanged<WorkerJob> onViewDetails;
  final ValueChanged<WorkerJob> onDecline;
 
  String get _checkedLabel {
    if (lastCheckedAt == null) return '';
    final Duration age = DateTime.now().difference(lastCheckedAt!);
    if (age.inSeconds < 5) return 'Just now';
    if (age.inSeconds < 60) return '${age.inSeconds}s ago';
    return '${age.inMinutes}m ago';
  }
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.lg),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: DesignTokens.shadowMid,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Nearby Job Requests',
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: DesignTokens.textPrimary,
                  ),
                ),
              ),
              if (jobs.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: DesignTokens.primary.withAlpha(18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${jobs.length} active',
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: DesignTokens.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DesignTokens.md),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _buildState(context),
          ),
        ],
      ),
    );
  }
 
  Widget _buildState(BuildContext context) {
    if (!isOnline) {
      return _CardStateContent(
        key: const ValueKey('offline'),
        title: 'You are currently offline.',
        description: 'Enable availability to begin receiving nearby job requests.',
        buttonLabel: 'Go Online',
        buttonEnabled: true,
        onPressed: onGoOnline,
      );
    }

    if (isSearching) {
      return _CardStateContent(
        key: const ValueKey('searching'),
        title: 'Searching for nearby jobs...',
        description: 'We are checking for matching requests near your location.',
        buttonLabel: 'Searching...',
        buttonEnabled: false,
        isLoading: true,
      );
    }

    if (jobs.isNotEmpty) {
      return _NearbyJobRequestFoundCard(
        key: const ValueKey('job_found'),
        job: jobs.first,
        onAccept: () => onViewDetails(jobs.first),
        onDecline: () => onDecline(jobs.first),
      );
    }

    return _CardStateContent(
      key: const ValueKey('online'),
      title: 'Ready to receive nearby job requests.',
      description: 'Turn on availability and start matching with clients close to you.',
      helperText: lastCheckedAt != null ? 'Last checked: $_checkedLabel' : null,
      buttonLabel: 'Start Matching',
      buttonEnabled: true,
      onPressed: onStartMatching,
    );
  }
}
 
class _CardStateContent extends StatelessWidget {
  const _CardStateContent({
    required this.key,
    required this.title,
    required this.description,
    this.helperText,
    required this.buttonLabel,
    required this.buttonEnabled,
    this.onPressed,
    this.isLoading = false,
  }) : super(key: key);
 
  @override
  final Key key;
  final String title;
  final String description;
  final String? helperText;
  final String buttonLabel;
  final bool buttonEnabled;
  final VoidCallback? onPressed;
  final bool isLoading;
 
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: DesignTokens.textPrimary,
          ),
        ),
        const SizedBox(height: DesignTokens.sm),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Satoshi',
            fontSize: 13,
            color: DesignTokens.textSecondary,
            height: 1.55,
          ),
        ),
        if (helperText != null) ...<Widget>[
          const SizedBox(height: DesignTokens.sm),
          Text(
            helperText!,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 12,
              color: DesignTokens.textMuted,
            ),
          ),
        ],
        const SizedBox(height: DesignTokens.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: buttonEnabled ? onPressed : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(buttonLabel),
          ),
        ),
      ],
    );
  }
}
 
class _NearbyJobRequestFoundCard extends StatelessWidget {
  const _NearbyJobRequestFoundCard({
    required Key key,
    required this.job,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);
 
  final WorkerJob job;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CategoryIconBadge(
                iconName: job.categoryIconName,
                colorHex: job.categoryColorHex,
                size: 46,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      job.clientName,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      job.title,
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 13,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              _JobTag(label: job.category),
              if (job.distanceKm != null) _JobTag(label: job.distanceText, isDistance: true),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            job.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              _Badge(label: 'Budget', value: job.estimateDisplay),
              const SizedBox(width: 10),
              _Badge(label: 'Arrival', value: job.urgencyLabel),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Decline Job'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Accept Job'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
 
class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.value});
 
  final String label;
  final String value;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: DesignTokens.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 11,
              color: DesignTokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
 
class _RecentReviewsSection extends StatelessWidget {
  const _RecentReviewsSection({
    required this.reviews,
    required this.onSeeAll,
  });
 
  final List<WorkerReviewSummary> reviews;
  final VoidCallback onSeeAll;
 
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.lg),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: DesignTokens.shadowMid,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Recent Reviews',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: const Text('See All →'),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.md),
          if (reviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DesignTokens.background,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'No recent reviews yet. Complete jobs to receive feedback from clients.',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  color: DesignTokens.textSecondary,
                  height: 1.5,
                ),
              ),
            )
          else
            ...reviews.map(
              (WorkerReviewSummary review) => Padding(
                padding: const EdgeInsets.only(bottom: DesignTokens.md),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: DesignTokens.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Icon(Icons.star, size: 16, color: DesignTokens.primary),
                          const SizedBox(width: 6),
                          Text(
                            review.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: DesignTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            review.reviewerName,
                            style: const TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 13,
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      if (review.comment != null && review.comment!.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          review.comment!,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 13,
                            color: DesignTokens.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (review.createdAt != null) ...<Widget>[
                        const SizedBox(height: 10),
                        Text(
                          _formatDate(review.createdAt),
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 11,
                            color: DesignTokens.textMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
 
class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.tip});
 
  final String tip;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.lg),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: DesignTokens.shadowMid,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Tips for Better Visibility',
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
            ),
          ),
          const SizedBox(height: DesignTokens.sm),
          Text(
            tip,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 13,
              color: DesignTokens.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingApplicationCard extends StatelessWidget {
  const _PendingApplicationCard({
    required this.application,
    required this.onTap,
  });

  final Map<String, dynamic> application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> job =
        Map<String, dynamic>.from(application['job'] as Map? ?? const {});
    final dynamic category = job['categories'];
    final String categoryName = category is Map
        ? (category['name'] ?? 'Service').toString()
        : 'Service';
    final String status = (application['status'] ?? 'pending').toString();
    final bool accepted = status == 'accepted';
    final Object? clientEstimate =
        job['budget_fixed'] ?? job['budget_min'] ?? job['budget_max'];
    final double? totalQuote = (application['total_quote'] as num?)?.toDouble() ??
        (application['proposed_rate'] as num?)?.toDouble();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      child: Container(
        padding: const EdgeInsets.all(DesignTokens.md),
        decoration: BoxDecoration(
          color: DesignTokens.surfaceCard,
          borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
          border: Border.all(color: DesignTokens.borderSubtle),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CategoryIconBadge(
              iconName: category is Map ? category['icon_name']?.toString() : null,
              colorHex: category is Map ? category['color_hex']?.toString() : null,
              size: 42,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    (job['title'] ?? 'Job application').toString(),
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: DesignTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryName · ${job['address_label'] ?? 'Location pending'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 12,
                      color: DesignTokens.textSecondary,
                    ),
                  ),
                  if (budget != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      'Budget: GHS $budget',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.primary,
                      ),
                    ),
                  ],
                  if (clientEstimate != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      'Client estimate: GHS $clientEstimate',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textSecondary,
                      ),
                    ),
                  ],
                  if (totalQuote != null) ...<Widget>[
                    const SizedBox(height: 6),
                    Text(
                      'Your quote: GHS ${totalQuote.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: DesignTokens.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            _JobTag(label: accepted ? 'Accepted' : 'Pending'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// View state
// ─────────────────────────────────────────────────────────────────────────────
enum RequestsViewState { loading, loaded, empty, error }
 
// ─────────────────────────────────────────────────────────────────────────────
// Main screen
// ─────────────────────────────────────────────────────────────────────────────
class WorkerRequestsScreen extends StatefulWidget {
  const WorkerRequestsScreen({super.key});
 
  @override
  State<WorkerRequestsScreen> createState() =>
      _WorkerRequestsScreenState();
}
 
class _WorkerRequestsScreenState extends State<WorkerRequestsScreen>
    with WidgetsBindingObserver {
  final WorkersService _workersService = WorkersService();
 
  RequestsViewState _viewState = RequestsViewState.loading;
  List<WorkerJob> _jobs = <WorkerJob>[];
  List<Map<String, dynamic>> _applications = <Map<String, dynamic>>[];
  String? _errorMessage;
  Timer? _refreshTimer;
  bool _isLoadingRequests = false;
  bool _isSilentRefreshing = false;
  DateTime? _lastCheckedAt;
  WorkerStats? _stats;
  double? _totalEarnings;
  bool _isLoadingOverview = true;
  final List<String> _tips = <String>[
    'Keep your availability ON during busy hours.',
    'Respond quickly to improve your response rate.',
    'Upload more portfolio photos.',
    'Complete jobs promptly to increase your recommendation score.',
    'Maintain a high customer rating.',
  ];
  late final String _tipOfTheDay;
 
  // ── Lifecycle ──────────────────────────────────────────────────────────────
 
  @override
  void initState() {
    super.initState();
    _tipOfTheDay = _tips[Random().nextInt(_tips.length)];
    WidgetsBinding.instance.addObserver(this);
    _load();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 8),
      (_) => _load(silent: true),
    );
  }
 
  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
 
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load(silent: true);
  }
 
  // ── Data loading ───────────────────────────────────────────────────────────
 
  Future<void> _load({bool silent = false}) async {
    if (_isLoadingRequests) return;
    _isLoadingRequests = true;
 
    if (!silent) {
      setState(() {
        _viewState = RequestsViewState.loading;
        _errorMessage = null;
        _isSilentRefreshing = false;
      });
    } else if (mounted) {
      setState(() => _isSilentRefreshing = true);
    }
 
    if (mounted) {
      try {
        final session = WorkerScope.read(context);
        unawaited(session.loadAvailability());
      } catch (_) {}
    }

    try {
      final List<dynamic> results = await Future.wait<dynamic>([
        _workersService.getJobRequests(),
        _workersService.getApplications(),
      ]);
      final List<dynamic> data = results[0] as List<dynamic>;
      final List<dynamic> applications = results[1] as List<dynamic>;
      if (!mounted) return;
      setState(() {
        _jobs = data
            .map((dynamic item) =>
                workerJobFromApi(item as Map<String, dynamic>))
            .toList();
        _applications = applications
            .whereType<Map<dynamic, dynamic>>()
            .map((Map<dynamic, dynamic> item) => Map<String, dynamic>.from(item))
            .toList();
        _viewState = _jobs.isEmpty && _applications.isEmpty
            ? RequestsViewState.empty
            : RequestsViewState.loaded;
        _lastCheckedAt = DateTime.now();
        _isSilentRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (silent) {
        setState(() => _isSilentRefreshing = false);
      } else {
        setState(() {
          _errorMessage =
              userMessageFor(e, fallback: 'Failed to load requests.');
          _viewState = RequestsViewState.error;
        });
      }
    } finally {
      _isLoadingRequests = false;
    }

    if (!silent) {
      await _loadOverview();
    } else {
      unawaited(_loadOverview(silent: true));
    }
  }

  Future<void> _loadOverview({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _isLoadingOverview = true;
      });
    }

    try {
      final List<dynamic> results = await Future.wait<dynamic>([
        _workersService.getStats(),
        _workersService.getEarnings(),
      ]);
      final Map<String, dynamic> statsData =
          Map<String, dynamic>.from(results[0] as Map);
      final Map<String, dynamic> earningsData =
          Map<String, dynamic>.from(results[1] as Map);

      if (!mounted) return;
      setState(() {
        _stats = WorkerStats.fromMap(statsData);
        _totalEarnings = (earningsData['total_earned'] as num?)?.toDouble();
      });
    } catch (_) {
      // Keep the dashboard visible even if overview data fails.
    } finally {
      if (!silent && mounted) {
        setState(() {
          _isLoadingOverview = false;
        });
      }
    }
  }
 
  // ── Navigation ─────────────────────────────────────────────────────────────
 
  void _openDetail(WorkerJob job) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JobRequestDetailScreen(
          job: job,
          onAcceptRequest: (accepted) {
            _load();
          },
          onAcceptResponse: (accepted) {
            _load();
          },
        ),
      ),
    );
  }

  Future<void> _openApplication(Map<String, dynamic> application) async {
    final Map<String, dynamic> job =
        Map<String, dynamic>.from(application['job'] as Map? ?? const {});
    final WorkerApplicationDestination destination =
        workerApplicationDestination(
      (application['status'] ?? '').toString(),
      (job['status'] ?? '').toString(),
    );

    if (destination == WorkerApplicationDestination.activeBooking) {
      final WorkerSessionState session = WorkerScope.of(context);
      await session.loadActiveJob();
      if (session.hasActiveJob || !mounted) return;
    } else if (destination == WorkerApplicationDestination.history) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const WorkerBookingHistoryScreen(),
        ),
      );
      return;
    }

    if (!mounted) return;
    final dynamic updated = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (_) => WorkerApplicationDetailScreen(
          application: application,
        ),
      ),
    );
    if (updated == true && mounted) {
      _load();
    }
  }

  Future<void> _declineJob(WorkerJob job) async {
    try {
      await _workersService.declineJob(job.id);
      if (!mounted) return;
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(
        context,
        e,
        fallback: 'Could not decline the job request.',
      );
    }
  }
 
  // ── Build ──────────────────────────────────────────────────────────────────
 
  @override
  Widget build(BuildContext context) {
    final WorkerSessionState session = WorkerScope.of(context);
 
    return Scaffold(
      backgroundColor: DesignTokens.surfaceBase,
      appBar: _buildAppBar(),
      body: Column(
        children: <Widget>[
          // Slim silent-refresh progress bar at the very top
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2,
            child: _isSilentRefreshing
                ? LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: DesignTokens.surfaceBase,
                    color: DesignTokens.primary.withAlpha((0.45 * 255).round()),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: RefreshIndicator(
              color: DesignTokens.primary,
              backgroundColor: DesignTokens.surfaceCard,
              onRefresh: _load,
              child: _buildBody(session),
            ),
          ),
        ],
      ),
    );
  }
 
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: DesignTokens.surfaceBase,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      title: const Text(
        'Dashboard',
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: DesignTokens.primary,
          letterSpacing: 0.01,
        ),
      ),
    );
  }
 
  // ── Body ───────────────────────────────────────────────────────────────────
 
  Widget _buildBody(WorkerSessionState session) {
    // Loading skeleton
    if (_viewState == RequestsViewState.loading) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.gutter),
        children: const <Widget>[
          SkeletonBox(height: 112),
          SizedBox(height: DesignTokens.md),
          SkeletonBox(height: 170),
          SizedBox(height: DesignTokens.md),
          SkeletonBox(height: 170),
        ],
      );
    }
 
    // Error state
    if (_viewState == RequestsViewState.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          ErrorStateView(
            message: _errorMessage!,
            title: 'Could not load requests',
            onRetry: _load,
          ),
        ],
      );
    }
 
    // Loaded + empty
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.gutter,
        DesignTokens.md,
        DesignTokens.gutter,
        DesignTokens.gutter,
      ),
      children: <Widget>[
        // ── Availability card ──────────────────────────────────
        _AvailabilityCard(
          isAvailable: session.isAvailable,
          isAvailabilityLoading: session.isAvailabilityLoading,
          lastCheckedAt: _lastCheckedAt,
          isSilentRefreshing: _isSilentRefreshing,
          onChanged: (bool value) async {
            if (value) {
              final bool hasLoc =
                  await DeviceLocationService.requestPermissionInteractive(context);
              if (!hasLoc) return;
            }
            final bool ok = await session.setAvailable(value);
            if (ok && mounted) {
              await _load();
            }
            if (!ok && mounted) {
              AppToast.showError(
                context,
                Exception('Could not update availability.'),
                fallback: 'Could not update availability.',
              );
            }
          },
        ),
 
        const SizedBox(height: DesignTokens.lg),
        _DashboardHeader(),
        const SizedBox(height: DesignTokens.lg),
        _QuickAccessSection(
          onOpenEarnings: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerEarningsScreen(),
              ),
            );
          },
          onOpenReviews: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerReviewsScreen(),
              ),
            );
          },
          onOpenGallery: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerGalleryScreen(),
              ),
            );
          },
          onOpenHistory: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerBookingHistoryScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: DesignTokens.lg),
        _PerformanceOverviewCard(
          stats: _stats,
          totalEarnings: _totalEarnings,
          isLoading: _isLoadingOverview,
        ),
        const SizedBox(height: DesignTokens.lg),
        _NearbyJobsSection(
          isOnline: session.isAvailable,
          isSearching: _isLoadingRequests,
          jobs: _jobs,
          lastCheckedAt: _lastCheckedAt,
          onGoOnline: () async {
            if (await DeviceLocationService.requestPermissionInteractive(context)) {
              final bool ok = await session.setAvailable(true);
              if (ok && mounted) {
                await _load();
              }
              if (!ok && mounted) {
                AppToast.showError(
                  context,
                  Exception('Could not update availability.'),
                  fallback: 'Could not update availability.',
                );
              }
            }
          },
          onStartMatching: _load,
          onViewDetails: _openDetail,
          onDecline: _declineJob,
        ),
        const SizedBox(height: DesignTokens.lg),
        if (_applications.isNotEmpty) ...<Widget>[
          _SectionHeader(
            label: 'Pending applications',
            count: _applications.length,
          ),
          const SizedBox(height: DesignTokens.md),
          ..._applications.map(
            (Map<String, dynamic> application) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.md),
              child: _PendingApplicationCard(
                application: application,
                onTap: () => _openApplication(application),
              ),
            ),
          ),
          const SizedBox(height: DesignTokens.sm),
        ],
        if (_jobs.isNotEmpty) ...<Widget>[
          _SectionHeader(
            label: 'Open requests',
            count: _jobs.length,
          ),
          const SizedBox(height: DesignTokens.md),
          JobRequestsMapPreview(
            jobs: _jobs,
            onOpenJob: _openDetail,
          ),
          const SizedBox(height: DesignTokens.md),
          ..._jobs.map(
            (WorkerJob job) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.md),
              child: _RequestJobCard(
                job: job,
                onViewDetails: () => _openDetail(job),
                onAccept: () => _openDetail(job),
              ),
            ),
          ),
        ],
        const SizedBox(height: DesignTokens.lg),
        _RecentReviewsSection(
          reviews: _stats?.recentReviews ?? const <WorkerReviewSummary>[],
          onSeeAll: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const WorkerReviewsScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: DesignTokens.lg),
        _TipsCard(tip: _tipOfTheDay),
      ],
    );
  }
}

