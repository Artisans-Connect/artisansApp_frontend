import 'package:artisans_app/core/theme/index.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import '../../../../core/errors/error_messages.dart';
import '../../../../core/services/workers_service.dart';
import '../../../../shared/presentation/screens/settings_screen.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../models/worker_stats.dart';
import '../state/worker_session_state.dart';
import '../../../../shared/widgets/custom_back_button.dart';

class WorkerStatsScreen extends StatefulWidget {
  const WorkerStatsScreen({super.key});

  @override
  State<WorkerStatsScreen> createState() => _WorkerStatsScreenState();
}

class _WorkerStatsScreenState extends State<WorkerStatsScreen> {
  final WorkersService _workersService = WorkersService();
  late Future<WorkerStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _loadStats();
  }

  Future<WorkerStats> _loadStats() async {
    final Map<String, dynamic> raw = await _workersService.getStats();
    return WorkerStats.fromMap(raw);
  }

  Future<void> _refresh() async {
    final Future<WorkerStats> next = _loadStats();
    setState(() {
      _statsFuture = next;
    });
    await next;
  }

  void _reload() {
    setState(() {
      _statsFuture = _loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: CustomBackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).maybePop();
              return;
            }
            WorkerScope.of(context).setProfilePage(WorkerProfilePage.earnings);
          },
        ),
        title: Text(
          'Your Stats',
          style: AppTypography.titleLarge.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.gear),
            onPressed: () {
              Navigator.pushNamed(context, SettingsScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<WorkerStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return ErrorStateView(
              title: 'Could not load stats',
              message: userMessageFor(
                snapshot.error ?? Exception('Stats unavailable'),
                fallback: 'Could not load your stats.',
              ),
              onRetry: _reload,
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: _StatsContent(stats: snapshot.data!),
          );
        },
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  const _StatsContent({required this.stats});

  final WorkerStats stats;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Performance Overview', style: AppTypography.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Track your professional growth as an artisan.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _StatCard(
                icon: PhosphorIcons.checkCircle,
                value: '${stats.totalJobs}',
                label: 'JOBS',
                iconColor: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCard(
                icon: PhosphorIcons.star,
                value: stats.reviewCount == 0
                    ? '--'
                    : stats.rating.toStringAsFixed(1),
                label: 'RATING',
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatCard(
                icon: PhosphorIcons.timer,
                value: stats.responseLabel,
                label: 'RESPONSE',
                iconColor: AppColors.secondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Text('Recent Reviews', style: AppTypography.titleLarge),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stats.reviewCount}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (stats.responseSampleCount > 0) ...[
            Text(
              'Average response based on ${stats.responseSampleCount} accepted request${stats.responseSampleCount == 1 ? '' : 's'}.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (stats.recentReviews.isEmpty)
            const _NoReviewsCard()
          else
            ...stats.recentReviews.map(
              (WorkerReviewSummary review) => _ReviewCard(review: review),
            ),
          const SizedBox(height: AppSpacing.lg),
          OutlinedButton(
            onPressed: () {
              WorkerScope.of(context).setProfilePage(WorkerProfilePage.history);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
            child: const Text('View all jobs  >'),
          ),
        ],
      ),
    );
  }
}

class _NoReviewsCard extends StatelessWidget {
  const _NoReviewsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIcons.hardHat,
            size: 64,
            color: AppColors.primary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: AppSpacing.md),
          Text('No reviews yet.', style: AppTypography.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Complete your first few jobs to receive feedback from your clients and build your profile.',
            style: AppTypography.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final WorkerReviewSummary review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIcons.star, color: AppColors.primary, size: 18),
              const SizedBox(width: 6),
              Text(review.rating.toStringAsFixed(1),
                  style: AppTypography.labelLarge),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: AppTypography.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (review.createdAt != null)
                Text(
                  _formatReviewDate(review.createdAt!),
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.comment?.trim().isNotEmpty == true
                ? review.comment!.trim()
                : 'No comment added.',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor ?? AppColors.outline),
            const SizedBox(height: AppSpacing.sm),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: AppTypography.titleLarge.copyWith(fontSize: 18),
                maxLines: 1,
              ),
            ),
            Text(label, style: AppTypography.labelCaps.copyWith(fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

String _formatReviewDate(DateTime date) {
  final Duration diff = DateTime.now().difference(date);
  if (diff.inDays <= 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.day}/${date.month}/${date.year}';
}
