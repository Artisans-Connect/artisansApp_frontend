import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/location/device_location_service.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/services/notification_service.dart';
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
import '../../../../shared/utils/greeting_utils.dart';
class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: online ? DesignTokens.successGreen : DesignTokens.textMuted,
        shape: BoxShape.circle,
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
              if (lastCheckedAt != null)
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
    required this.onTap,
    required this.onViewDetails,
    required this.onAccept,
    required this.isSelected,
  });
 
  final WorkerJob job;
  final VoidCallback onTap;
  final VoidCallback onViewDetails;
  final VoidCallback onAccept;
  final bool isSelected;
 
  double? _parseAmount(String value) {
    final RegExp match = RegExp(r'[0-9]+(?:[.,][0-9]+)?');
    final RegExpMatch? result = match.firstMatch(value.replaceAll(' ', ''));
    if (result == null) return null;
    return double.tryParse(result.group(0)!.replaceAll(',', '.'));
  }
 
  @override
  Widget build(BuildContext context) {
    final double? quote = job.applicationTotalQuote;
    final double? estimate = _parseAmount(job.estimateDisplay);
    final double? difference = (estimate != null && quote != null) ? estimate - quote : null;
    final bool isUnderEstimate = difference != null && difference > 0;
    final Color diffColor = isUnderEstimate ? DesignTokens.successGreen : DesignTokens.textSecondary;

    return Material(
      color: isSelected ? DesignTokens.surfaceHighlight : DesignTokens.surfaceCard,
      borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        onTap: onTap,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CategoryIconBadge(
                        iconName: job.categoryIconName,
                        colorHex: job.categoryColorHex,
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    job.clientName,
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: DesignTokens.textPrimary,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: DesignTokens.primary.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Text(
                                      'Selected',
                                      style: TextStyle(
                                        fontFamily: 'Satoshi',
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: DesignTokens.primary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: <Widget>[
                                const Icon(Icons.star, size: 14, color: DesignTokens.accentGold),
                                const SizedBox(width: 4),
                                Text(
                                  job.clientRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: DesignTokens.textPrimary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(${job.reviewCount} jobs)',
                                  style: const TextStyle(
                                    fontFamily: 'Satoshi',
                                    fontSize: 12,
                                    color: DesignTokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      _RequestBadge(label: job.urgencyLabel, isAccent: job.urgency == JobUrgency.asap || job.isUrgent),
                      const SizedBox(width: 8),
                      _RequestBadge(label: job.category, isAccent: false),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: DesignTokens.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.locationLine,
                          style: const TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 13,
                            color: DesignTokens.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: DesignTokens.background,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: DesignTokens.borderSubtle),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Client estimate',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 12,
                                      color: DesignTokens.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    job.estimateDisplay,
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: DesignTokens.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    'Your quote',
                                    style: TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 12,
                                      color: DesignTokens.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    quote != null ? 'GHS ${quote.toStringAsFixed(2)}' : '—',
                                    style: const TextStyle(
                                      fontFamily: 'Satoshi',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: DesignTokens.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (difference != null) ...<Widget>[
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              Text(
                                isUnderEstimate ? '+GHS ${difference.toStringAsFixed(2)}' : 'GHS ${difference.abs().toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: diffColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isUnderEstimate ? 'saved for you' : 'above estimate',
                                style: const TextStyle(
                                  fontFamily: 'Satoshi',
                                  fontSize: 12,
                                  color: DesignTokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Accept Job',
                            style: TextStyle(
                              fontFamily: 'Satoshi',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onViewDetails,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: DesignTokens.borderSubtle),
                      ),
                      child: const Text(
                        'View details',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: DesignTokens.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestBadge extends StatelessWidget {
  const _RequestBadge({required this.label, required this.isAccent});

  final String label;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAccent ? DesignTokens.primary.withValues(alpha: 0.14) : DesignTokens.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isAccent ? DesignTokens.primary : DesignTokens.textSecondary,
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();

  String _firstName() {
    final String fullName = AppUserSession.instance.currentUser?.fullName ?? '';
    final List<String> parts = fullName.trim().split(' ');
    return parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final String firstName = _firstName();
    final String greeting = GreetingUtils.getGreeting();
    final String subtitle = GreetingUtils.getWorkerSubtitle();

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
          subtitle,
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

  String _formatCurrency(double? amount) {
    if (amount == null) return 'GH₵ 0.00';
    return 'GH₵ ${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final double rating = stats?.rating ?? 0.0;
    final int reviewCount = stats?.reviewCount ?? 0;
    final int totalJobs = stats?.totalJobs ?? 0;
    final String responseLabel = stats?.responseLabel ?? '--';
    final String earningsText = _formatCurrency(totalEarnings);

    return Container(
      padding: const EdgeInsets.all(DesignTokens.lg),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: DesignTokens.borderSubtle),
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

          Row(
            children: <Widget>[
              Expanded(
                child: _CleanStatTile(
                  label: 'Total Earnings',
                  value: earningsText,
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: DesignTokens.md),
              Expanded(
                child: _CleanStatTile(
                  label: 'Jobs Completed',
                  value: '$totalJobs',
                  icon: Icons.work_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: DesignTokens.md),
          Row(
            children: <Widget>[
              Expanded(
                child: _CleanStatTile(
                  label: 'Average Rating',
                  value: rating > 0 ? '${rating.toStringAsFixed(1)} ★' : '--',
                  subtitle: reviewCount > 0 ? '$reviewCount reviews' : null,
                  icon: Icons.star_outline_rounded,
                ),
              ),
              const SizedBox(width: DesignTokens.md),
              Expanded(
                child: _CleanStatTile(
                  label: 'Response Time',
                  value: responseLabel,
                  icon: Icons.schedule_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CleanStatTile extends StatelessWidget {
  const _CleanStatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: DesignTokens.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: DesignTokens.textPrimary,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
                color: DesignTokens.textMuted,
              ),
            ),
          ],
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
    required this.selectedJobId,
    required this.lastCheckedAt,
    required this.onGoOnline,
    required this.onStartMatching,
    required this.onSelectJob,
    required this.onOpenJob,
    required this.onViewDetails,
    required this.onAccept,
  });

  final bool isOnline;
  final bool isSearching;
  final List<WorkerJob> jobs;
  final String? selectedJobId;
  final DateTime? lastCheckedAt;
  final VoidCallback onGoOnline;
  final VoidCallback onStartMatching;
  final ValueChanged<String> onSelectJob;
  final ValueChanged<WorkerJob> onOpenJob;
  final ValueChanged<WorkerJob> onViewDetails;
  final ValueChanged<WorkerJob> onAccept;

  String get _checkedLabel {
    if (lastCheckedAt == null) return '';
    final Duration age = DateTime.now().difference(lastCheckedAt!);
    if (age.inSeconds < 5) return 'Just now';
    if (age.inSeconds < 60) return '${age.inSeconds}s ago';
    return '${age.inMinutes}m ago';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Expanded(
              child: Text(
                'Nearby Requests',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DesignTokens.textPrimary,
                ),
              ),
            ),
            if (jobs.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: DesignTokens.primary.withValues(alpha: 0.14),
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
        const SizedBox(height: DesignTokens.sm),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildState(context),
        ),
      ],
    );
  }

  Widget _buildState(BuildContext context) {
    if (!isOnline) {
      return _MinimalisticStatusCard(
        key: const ValueKey('offline'),
        title: 'Offline',
        subtitle: 'Turn on availability to receive nearby job requests.',
        isOnline: false,
        isLoading: false,
        actionLabel: 'Go online',
        onAction: onGoOnline,
      );
    }

    if (jobs.isNotEmpty) {
      final String selectedId = selectedJobId ?? jobs.first.id;
      return Column(
        key: const ValueKey('has_jobs'),
        children: <Widget>[
          JobRequestsMapPreview(
            jobs: jobs,
            selectedJobId: selectedId,
            onSelectJob: onSelectJob,
            onOpenJob: onOpenJob,
            height: 145,
          ),
          const SizedBox(height: DesignTokens.md),
          ...jobs.map(
            (WorkerJob job) => Padding(
              padding: const EdgeInsets.only(bottom: DesignTokens.md),
              child: _RequestJobCard(
                job: job,
                isSelected: job.id == selectedId,
                onTap: () => onSelectJob(job.id),
                onAccept: () => onAccept(job),
                onViewDetails: () => onViewDetails(job),
              ),
            ),
          ),
        ],
      );
    }

    if (isSearching) {
      return const _MinimalisticStatusCard(
        key: ValueKey('searching'),
        title: 'Searching nearby...',
        subtitle: 'Checking for client requests close to your location.',
        isOnline: true,
        isLoading: true,
      );
    }

    return _MinimalisticStatusCard(
      key: const ValueKey('empty'),
      title: 'Listening for requests',
      subtitle: _checkedLabel.isNotEmpty
          ? 'Last checked: $_checkedLabel'
          : 'No active requests nearby right now.',
      isOnline: true,
      isLoading: false,
      actionLabel: 'Refresh',
      onAction: onStartMatching,
    );
  }
}

class _MinimalisticStatusCard extends StatelessWidget {
  const _MinimalisticStatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isOnline,
    required this.isLoading,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final bool isOnline;
  final bool isLoading;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceCard,
        borderRadius: BorderRadius.circular(DesignTokens.radiusXl),
        border: Border.all(color: DesignTokens.borderSubtle),
      ),
      child: Row(
        children: <Widget>[
          _PulseDot(online: isOnline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: DesignTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 12,
                    color: DesignTokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: DesignTokens.primary,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
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
    final Object? budget = job['budget_fixed'] ?? job['budget_min'] ?? job['budget_max'];
    final Object? clientEstimate = job['client_estimate'] ??
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
  final NotificationService _notificationService = NotificationService.instance;
  int _unreadNotifications = 0;

  RequestsViewState _viewState = RequestsViewState.loading;
  List<WorkerJob> _jobs = <WorkerJob>[];
  String? _selectedJobId;
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
      const Duration(seconds: 30),
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
        _selectedJobId = _jobs.isNotEmpty
            ? (_selectedJobId != null && _jobs.any((job) => job.id == _selectedJobId)
                ? _selectedJobId
                : _jobs.first.id)
            : null;
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
      await Future.wait<dynamic>([
        _loadOverview(),
        _loadUnreadNotifications(),
      ]);
    } else {
      unawaited(_loadOverview(silent: true));
      unawaited(_loadUnreadNotifications());
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final int count = await _notificationService.getUnreadCount();
      if (!mounted) return;
      setState(() => _unreadNotifications = count);
    } catch (_) {
      if (!mounted) return;
      setState(() => _unreadNotifications = 0);
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
    _selectJob(job.id);
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

  Future<void> _handleQuickAccept(WorkerJob job) async {
    _selectJob(job.id);
    final String budgetStr = job.rateLabel ?? job.estimatedBudgetLabel ?? 'this job';
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Apply for ${job.title}?'),
        content: Text(
          'Do you want to send an application to client ${job.clientName} ($budgetStr)?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: DesignTokens.primary),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Submit Application'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _workersService.applyToJob(job.id);
      if (!mounted) return;
      AppToast.showSuccess(context, 'Application submitted successfully.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      AppToast.showError(context, e, fallback: 'Could not submit application.');
    }
  }

  void _selectJob(String jobId) {
    if (!mounted) return;
    setState(() {
      if (_jobs.any((job) => job.id == jobId)) {
        _selectedJobId = jobId;
      }
    });
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
        'Job Requests',
        style: TextStyle(
          fontFamily: 'Satoshi',
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: DesignTokens.primary,
          letterSpacing: 0.01,
        ),
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: () async {
            await Navigator.pushNamed(context, AppRoutes.notifications);
            if (mounted) unawaited(_loadUnreadNotifications());
          },
          child: Container(
            margin: const EdgeInsets.only(right: DesignTokens.gutter),
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: DesignTokens.surfaceCard,
              shape: BoxShape.circle,
              border: Border.all(color: DesignTokens.borderSubtle),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: DesignTokens.shadow,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                const Icon(
                  Icons.notifications_outlined,
                  color: DesignTokens.textPrimary,
                  size: 20,
                ),
                if (_unreadNotifications > 0)
                  Positioned(
                    top: 5,
                    right: 4,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 17,
                        minHeight: 17,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: DesignTokens.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: DesignTokens.surfaceCard,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _unreadNotifications > 99
                            ? '99+'
                            : '$_unreadNotifications',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
 
  // ── Body ───────────────────────────────────────────────────────────────────
 
  Widget _buildBody(WorkerSessionState session) {
    if (_viewState == RequestsViewState.loading) {
      return ListView(
        padding: const EdgeInsets.all(DesignTokens.gutter),
        children: const <Widget>[
          SkeletonBox(height: 112),
          SizedBox(height: DesignTokens.md),
          SkeletonBox(height: 145),
          SizedBox(height: DesignTokens.md),
          SkeletonBox(height: 170),
        ],
      );
    }

    if (_viewState == RequestsViewState.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          DesignTokens.gutter,
          DesignTokens.md,
          DesignTokens.gutter,
          DesignTokens.gutter,
        ),
        children: <Widget>[
          ErrorStateView(
            message: _errorMessage!,
            title: 'Could not load requests',
            onRetry: _load,
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        DesignTokens.gutter,
        DesignTokens.md,
        DesignTokens.gutter,
        DesignTokens.gutter,
      ),
      children: <Widget>[
        const _DashboardHeader(),
        const SizedBox(height: DesignTokens.md),
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
        _NearbyJobsSection(
          isOnline: session.isAvailable,
          isSearching: _isLoadingRequests,
          jobs: _jobs,
          selectedJobId: _selectedJobId,
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
          onSelectJob: _selectJob,
          onOpenJob: _openDetail,
          onViewDetails: _openDetail,
          onAccept: _handleQuickAccept,
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

